import simd
import SwiftUI

enum ApparitionStyle: Equatable {
    case primary
    case secondary
}

struct ApparitionCrossSection: Equatable, Identifiable {
    let id: ApparitionStyle
    let segments: [CrossSectionSegment]
    let polygons: [CrossSectionPolygon]
    let center: SIMD2<Float>?

    var style: ApparitionStyle { id }
}

struct ApparitionPose: Equatable {
    var shape: PassingShape
    var height: Float
    var rotateX: Float
    var rotateZ: Float
    var planeX: Float
    var planeZ: Float
    var enabled: Bool

    static let primaryDefault = ApparitionPose(
        shape: .sphere,
        height: 0,
        rotateX: 0,
        rotateZ: 0,
        planeX: 0,
        planeZ: 0,
        enabled: true
    )

    static let secondaryDefault = ApparitionPose(
        shape: .cube,
        height: -1.2,
        rotateX: 20,
        rotateZ: 35,
        planeX: 1.6,
        planeZ: -1.1,
        enabled: false
    )
}

enum ApparitionAppearance {
    static func fill(for style: ApparitionStyle) -> Color {
        switch style {
        case .primary:
            FlatlandTheme.apparitionFill
        case .secondary:
            FlatlandTheme.accentBlue.opacity(0.32)
        }
    }

    static func stroke(for style: ApparitionStyle) -> Color {
        switch style {
        case .primary:
            FlatlandTheme.gold
        case .secondary:
            FlatlandTheme.accentBlue
        }
    }

    static func glow(for style: ApparitionStyle) -> Color {
        switch style {
        case .primary:
            FlatlandTheme.gold.opacity(0.8)
        case .secondary:
            FlatlandTheme.accentBlue.opacity(0.75)
        }
    }
}