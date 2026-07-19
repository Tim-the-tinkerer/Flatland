import Foundation
import SceneKit
import simd

struct Vec4: Equatable {
    var x: Float
    var y: Float
    var z: Float
    var w: Float

    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}

struct FourDPose: Equatable {
    var wPosition: Float = 0
    var rotateXW: Float = 25
    var rotateYW: Float = 15
    var rotateZW: Float = 10
    var rotateXY: Float = 0
    var rotateXZ: Float = 0
    var rotateYZ: Float = 0
    var sliceTiltXW: Float = 0
    var sliceTiltYW: Float = 0
    var sliceTiltZW: Float = 0
}

struct FourDSlicePlane: Equatable {
    let normal: SIMD4<Float>
    let offset: Float
}

struct FourDWireSegment: Equatable {
    let start: SIMD3<Float>
    let end: SIMD3<Float>
    let depth: Float
}

struct FourDSliceMesh: Equatable {
    let vertices: [SIMD3<Float>]
    let indices: [Int32]
}

enum Hypercube4D {
    private static let size: Float = 1.05

    static func baseVertices() -> [Vec4] {
        (0..<16).map { index in
            Vec4(
                x: (index & 1 == 0 ? -1 : 1) * size,
                y: (index & 2 == 0 ? -1 : 1) * size,
                z: (index & 4 == 0 ? -1 : 1) * size,
                w: (index & 8 == 0 ? -1 : 1) * size
            )
        }
    }

    static func edges() -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        for i in 0..<16 {
            for bit in 0..<4 {
                let j = i ^ (1 << bit)
                if j > i { result.append((i, j)) }
            }
        }
        return result
    }

    static func transformedVertices(pose: FourDPose) -> [Vec4] {
        var vertices = baseVertices()
        let rotations: [(Int, Int, Float)] = [
            (0, 3, pose.rotateXW * .pi / 180),
            (1, 3, pose.rotateYW * .pi / 180),
            (2, 3, pose.rotateZW * .pi / 180),
            (0, 1, pose.rotateXY * .pi / 180),
            (0, 2, pose.rotateXZ * .pi / 180),
            (1, 2, pose.rotateYZ * .pi / 180),
        ]

        for (a, b, angle) in rotations where abs(angle) > 1e-6 {
            vertices = vertices.map { rotatePlane($0, a: a, b: b, angle: angle) }
        }

        return vertices.map { vertex in
            Vec4(x: vertex.x, y: vertex.y, z: vertex.z, w: vertex.w + pose.wPosition)
        }
    }

    static func projectedWireframe(vertices: [Vec4]) -> [FourDWireSegment] {
        edges().map { i, j in
            let a = project(vertices[i])
            let b = project(vertices[j])
            let depth = (vertices[i].w + vertices[j].w) * 0.5
            return FourDWireSegment(start: a, end: b, depth: depth)
        }
    }

    static func slicePlane(pose: FourDPose) -> FourDSlicePlane {
        var normal = SIMD4<Float>(0, 0, 0, 1)
        let tilts: [(Int, Int, Float)] = [
            (0, 3, pose.sliceTiltXW * .pi / 180),
            (1, 3, pose.sliceTiltYW * .pi / 180),
            (2, 3, pose.sliceTiltZW * .pi / 180),
        ]

        for (a, b, angle) in tilts where abs(angle) > 1e-6 {
            normal = rotatePlane(normal, a: a, b: b, angle: angle)
        }

        let length = simd_length(normal)
        if length > 1e-9 {
            normal /= length
        }

        return FourDSlicePlane(normal: normal, offset: 0)
    }

    static func sliceMesh(vertices: [Vec4], pose: FourDPose) -> FourDSliceMesh {
        let plane = slicePlane(pose: pose)
        var points: [SIMD3<Float>] = []

        for (i, j) in edges() {
            if let hit = intersectEdge(vertices[i], vertices[j], plane: plane) {
                points.append(hit)
            }
        }

        return convexHullMesh(from: dedupe(points))
    }

    static func slicePlaneVisualEuler(pose: FourDPose) -> SCNVector3 {
        let xTilt = pose.sliceTiltXW * .pi / 180
        let yTilt = pose.sliceTiltYW * .pi / 180
        let zTilt = pose.sliceTiltZW * .pi / 180
        return SCNVector3(
            -.pi / 2 + xTilt,
            zTilt * 0.35,
            yTilt * 0.35
        )
    }

    private static func rotatePlane(_ v: SIMD4<Float>, a: Int, b: Int, angle: Float) -> SIMD4<Float> {
        var components = [v.x, v.y, v.z, v.w]
        let va = components[a]
        let vb = components[b]
        let cos = cosf(angle)
        let sin = sinf(angle)
        components[a] = va * cos - vb * sin
        components[b] = va * sin + vb * cos
        return SIMD4(components[0], components[1], components[2], components[3])
    }

    private static func rotatePlane(_ v: Vec4, a: Int, b: Int, angle: Float) -> Vec4 {
        let components = [v.x, v.y, v.z, v.w]
        let va = components[a]
        let vb = components[b]
        let cos = cosf(angle)
        let sin = sinf(angle)
        var next = components
        next[a] = va * cos - vb * sin
        next[b] = va * sin + vb * cos
        return Vec4(x: next[0], y: next[1], z: next[2], w: next[3])
    }

    private static func project(_ v: Vec4) -> SIMD3<Float> {
        let shrink = 1 / (1 + abs(v.w) * 0.12)
        return SIMD3(
            v.x * shrink,
            v.y * shrink + v.w * 0.55,
            v.z * shrink
        )
    }

    private static func intersectEdge(_ a: Vec4, _ b: Vec4, plane: FourDSlicePlane) -> SIMD3<Float>? {
        let da = simd_dot(plane.normal, SIMD4(a.x, a.y, a.z, a.w)) - plane.offset
        let db = simd_dot(plane.normal, SIMD4(b.x, b.y, b.z, b.w)) - plane.offset
        if da * db > 1e-9 { return nil }

        if abs(da) < 1e-9 && abs(db) < 1e-9 {
            return SIMD3(
                (a.x + b.x) * 0.5,
                (a.y + b.y) * 0.5,
                (a.z + b.z) * 0.5
            )
        }

        let t = da / (da - db)
        if t < -1e-6 || t > 1 + 1e-6 { return nil }
        return SIMD3(
            a.x + t * (b.x - a.x),
            a.y + t * (b.y - a.y),
            a.z + t * (b.z - a.z)
        )
    }

    private static func dedupe(_ points: [SIMD3<Float>], epsilon: Float = 1e-4) -> [SIMD3<Float>] {
        var unique: [SIMD3<Float>] = []
        for point in points {
            if !unique.contains(where: { simd_distance_squared($0, point) < epsilon * epsilon }) {
                unique.append(point)
            }
        }
        return unique
    }

    private static func convexHullMesh(from points: [SIMD3<Float>]) -> FourDSliceMesh {
        guard points.count >= 3 else {
            return FourDSliceMesh(vertices: [], indices: [])
        }

        var indices: [Int32] = []
        let count = points.count

        for i in 0..<count {
            for j in (i + 1)..<count {
                for k in (j + 1)..<count {
                    let ab = points[j] - points[i]
                    let ac = points[k] - points[i]
                    let normal = simd_cross(ab, ac)
                    if simd_length_squared(normal) < 1e-10 { continue }

                    var positive = 0
                    var negative = 0

                    for m in 0..<count where m != i && m != j && m != k {
                        let d = simd_dot(normal, points[m] - points[i])
                        if d > 1e-5 { positive += 1 }
                        if d < -1e-5 { negative += 1 }
                    }

                    if positive == 0 || negative == 0 {
                        indices.append(contentsOf: [Int32(i), Int32(j), Int32(k)])
                    }
                }
            }
        }

        return FourDSliceMesh(vertices: points, indices: indices)
    }
}