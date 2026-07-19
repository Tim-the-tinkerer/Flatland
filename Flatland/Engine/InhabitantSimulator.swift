import Foundation
import SwiftUI
import simd

enum InhabitantBehaviorState: String {
    case idle
    case curious
    case alert
    case flee
    case huddle
}

struct AnimatedInhabitant: Identifiable, Equatable {
    let id: String
    let name: String
    let caste: FlatlandCaste
    let kind: InhabitantKind
    let homeX: CGFloat
    let homeZ: CGFloat
    let size: CGFloat
    let color: Color

    var x: CGFloat
    var z: CGFloat
    var angle: CGFloat
    var state: InhabitantBehaviorState
    var fear: CGFloat
    var sway: CGFloat
}

@MainActor
final class InhabitantSimulator {
    private(set) var inhabitants: [AnimatedInhabitant] = []
    private var wanderPhases: [String: CGFloat] = [:]
    private var lastUpdate: TimeInterval?

    init() {
        reset()
    }

    func reset() {
        inhabitants = FlatlandInhabitants.all.map { def in
            AnimatedInhabitant(
                id: def.id,
                name: def.name,
                caste: def.caste,
                kind: def.kind,
                homeX: def.x,
                homeZ: def.z,
                size: def.size,
                color: def.color,
                x: def.x,
                z: def.z,
                angle: CGFloat.random(in: 0...(2 * .pi)),
                state: .idle,
                fear: 0,
                sway: 0
            )
        }
        wanderPhases = Dictionary(
            uniqueKeysWithValues: inhabitants.map { ($0.id, CGFloat.random(in: 0...(2 * .pi))) }
        )
        lastUpdate = nil
    }

    func tick(apparitionCenters: [SIMD2<Float>], time: TimeInterval) {
        let deltaTime: CGFloat
        if let lastUpdate {
            deltaTime = CGFloat(min(max(time - lastUpdate, 0), 0.05))
        } else {
            deltaTime = 1.0 / 60.0
        }
        lastUpdate = time

        guard deltaTime > 0 else { return }

        var next = inhabitants

        for index in next.indices {
            update(
                inhabitant: &next[index],
                all: next,
                apparitionCenters: apparitionCenters,
                deltaTime: deltaTime,
                time: time
            )
        }

        inhabitants = next
    }

    func huddleLinks(threshold: Float = 1.15) -> [(SIMD2<Float>, SIMD2<Float>)] {
        var links: [(SIMD2<Float>, SIMD2<Float>)] = []

        for i in inhabitants.indices {
            guard inhabitants[i].fear > 0.35 else { continue }
            let a = SIMD2<Float>(Float(inhabitants[i].x), Float(inhabitants[i].z))

            for j in (i + 1)..<inhabitants.count {
                guard inhabitants[j].fear > 0.35 else { continue }
                let b = SIMD2<Float>(Float(inhabitants[j].x), Float(inhabitants[j].z))
                if simd_distance(a, b) < threshold {
                    links.append((a, b))
                }
            }
        }

        return links
    }

    private func update(
        inhabitant: inout AnimatedInhabitant,
        all: [AnimatedInhabitant],
        apparitionCenters: [SIMD2<Float>],
        deltaTime: CGFloat,
        time: TimeInterval
    ) {
        var distToApp = CGFloat.infinity
        var angleToApp: CGFloat = 0
        var fear: CGFloat = 0

        for center in apparitionCenters {
            let dx = CGFloat(center.x) - inhabitant.x
            let dz = CGFloat(center.y) - inhabitant.z
            let distance = hypot(dx, dz)
            let localFear = max(0, 1 - distance / 2.5)
            if distance < distToApp {
                distToApp = distance
                angleToApp = atan2(dz, dx)
            }
            fear = max(fear, localFear)
        }

        var nearestDist = CGFloat.infinity
        var nearestAngle: CGFloat = 0

        for other in all where other.id != inhabitant.id {
            let dx = other.x - inhabitant.x
            let dz = other.z - inhabitant.z
            let distance = hypot(dx, dz)
            if distance < nearestDist {
                nearestDist = distance
                nearestAngle = atan2(dz, dx)
            }
        }

        let fleeDistance: CGFloat = inhabitant.caste == .priest ? 1.0 : 1.2
        let state: InhabitantBehaviorState
        if apparitionCenters.isEmpty || distToApp > 3.5 {
            state = .idle
        } else if distToApp < fleeDistance {
            state = .flee
        } else if fear > 0.55 {
            state = .huddle
        } else if distToApp < 2.2 {
            state = .alert
        } else {
            state = .curious
        }

        inhabitant.state = state
        inhabitant.fear = fear

        var targetAngle = inhabitant.angle
        var speed: CGFloat = 0

        switch state {
        case .idle:
            var phase = wanderPhases[inhabitant.id] ?? 0
            phase += deltaTime * 0.8
            wanderPhases[inhabitant.id] = phase

            let homeDX = inhabitant.homeX - inhabitant.x
            let homeDZ = inhabitant.homeZ - inhabitant.z
            let homeDist = hypot(homeDX, homeDZ)

            if homeDist > 0.35 {
                targetAngle = faceAngle(toward: atan2(homeDZ, homeDX))
                speed = 0.22
            } else {
                targetAngle = phase
                speed = 0.12
            }

        case .curious:
            targetAngle = faceAngle(toward: angleToApp)
            speed = 0.28

        case .alert:
            targetAngle = faceAngle(toward: angleToApp)
            speed = 0.04

        case .flee:
            targetAngle = faceAngle(toward: angleToApp + .pi)
            speed = 0.95

        case .huddle:
            let huddleWeight = min(0.75, fear * 0.7)
            let fleeX = cos(angleToApp + .pi) * (1 - huddleWeight) + cos(nearestAngle) * huddleWeight
            let fleeZ = sin(angleToApp + .pi) * (1 - huddleWeight) + sin(nearestAngle) * huddleWeight
            targetAngle = faceAngle(toward: atan2(fleeZ, fleeX))
            speed = 0.55
        }

        switch inhabitant.caste {
        case .woman:
            if state == .flee { speed *= 1.25 }
            inhabitant.sway = CGFloat(sin(time * 4 + Double(inhabitant.homeX))) * 0.15
        case .priest:
            speed *= 0.75
            inhabitant.sway = 0
        case .soldier:
            if state == .curious { speed *= 1.15 }
            inhabitant.sway = 0
        default:
            inhabitant.sway = 0
        }

        inhabitant.angle = turn(current: inhabitant.angle, toward: targetAngle, deltaTime: deltaTime)

        if inhabitant.caste == .woman && (state == .idle || state == .alert) {
            inhabitant.angle += inhabitant.sway * deltaTime * 4
        }

        let forward = forwardVector(for: inhabitant.angle)
        inhabitant.x += forward.x * speed * deltaTime
        inhabitant.z += forward.y * speed * deltaTime
        inhabitant.x = clamp(inhabitant.x, min: -3.2, max: 3.2)
        inhabitant.z = clamp(inhabitant.z, min: -3.2, max: 3.2)
    }

    private func faceAngle(toward direction: CGFloat) -> CGFloat {
        direction + .pi / 2
    }

    private func forwardVector(for angle: CGFloat) -> CGPoint {
        CGPoint(x: cos(angle - .pi / 2), y: sin(angle - .pi / 2))
    }

    private func turn(current: CGFloat, toward target: CGFloat, deltaTime: CGFloat) -> CGFloat {
        var delta = target - current
        while delta > .pi { delta -= 2 * .pi }
        while delta < -.pi { delta += 2 * .pi }
        return current + delta * min(1, deltaTime * 10)
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }
}