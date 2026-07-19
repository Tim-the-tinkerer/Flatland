import SwiftUI

enum PassingShape: String, CaseIterable, Identifiable {
    case sphere
    case cube
    case tetrahedron
    case cylinder
    case torus
    case cone

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sphere: "Sphere"
        case .cube: "Cube"
        case .tetrahedron: "Tetrahedron"
        case .cylinder: "Cylinder"
        case .torus: "Torus"
        case .cone: "Cone"
        }
    }
}

struct NarrationEntry: Identifiable {
    let id: Int
    let quote: String
    let insight: String
}

enum FlatlandNarration {
    static let entries: [NarrationEntry] = [
        NarrationEntry(
            id: 0,
            quote: "\"Imagine a world of only two dimensions — a vast plane where the inhabitants are flat figures: lines, triangles, squares, and circles.\"",
            insight: "Flatlanders know only length and width. The concept of \"up\" is as unimaginable to them as a fourth dimension is to us."
        ),
        NarrationEntry(
            id: 1,
            quote: "\"They can move freely north, south, east, and west — but they have no notion whatsoever of above or below.\"",
            insight: "Their entire universe is the surface of their world. There is no sky, no depth — only the plane itself."
        ),
        NarrationEntry(
            id: 2,
            quote: "\"Now imagine we pass a three-dimensional sphere through their world. What would they see?\"",
            insight: "Select the sphere and move the height slider to watch the encounter unfold."
        ),
        NarrationEntry(
            id: 3,
            quote: "\"First, a point appears from nowhere — a miraculous apparition. Then the point grows into a circle, widening as the sphere descends.\"",
            insight: "A sphere crossing Flatland appears first as a point, then grows into a circle, then shrinks and vanishes."
        ),
        NarrationEntry(
            id: 4,
            quote: "\"As the sphere passes through, the circle reaches its maximum extent, then contracts, and finally disappears — vanishing as mysteriously as it arrived.\"",
            insight: "The Flatlanders witness a miracle they cannot explain. They see only a slice of a greater reality."
        ),
        NarrationEntry(
            id: 5,
            quote: "\"A cube would appear as a polygon that changes shape — a triangle, a square, a pentagon — never revealing its true cubic nature.\"",
            insight: "Try the cube with different tilts. Each cross-section is a different polygon."
        ),
        NarrationEntry(
            id: 6,
            quote: "\"The Flatlanders would argue about the nature of this apparition. Some would call it sorcery. None could conceive of a third dimension.\"",
            insight: "Watch the inhabitants react in fear and wonder to the passing shape."
        ),
        NarrationEntry(
            id: 7,
            quote: "\"Perhaps we are like the Flatlanders — unable to perceive a fourth physical dimension, blind to wonders passing through our world unseen.\"",
            insight: "What higher-dimensional truths might surround us, visible only as fleeting shadows?"
        ),
    ]

    static func insight(for shape: PassingShape) -> String {
        switch shape {
        case .sphere:
            "A sphere crossing their plane appears first as a point, then grows into a circle, then shrinks and vanishes — never revealing its true nature."
        case .cube:
            "A cube produces polygons of varying sides — triangles, squares, pentagons — depending on its angle of passage."
        case .tetrahedron:
            "A tetrahedron can appear as a point, a triangle, or a quadrilateral as it passes through the plane."
        case .cylinder:
            "A cylinder may appear as a circle, a rectangle, or an ellipse — a clue to its hidden cylindrical form."
        case .torus:
            "A torus creates baffling apparitions — sometimes two circles, sometimes a single loop — utterly inexplicable to Flatlanders."
        case .cone:
            "A cone appears as a point, then a circle of growing radius — or a triangle if it passes at an angle."
        }
    }
}

enum FlatlandCaste: String, CaseIterable, Identifiable {
    case woman
    case soldier
    case gentry
    case noble
    case priest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .woman: "Women"
        case .soldier: "Soldiers"
        case .gentry: "Gentry"
        case .noble: "Nobility"
        case .priest: "Priests"
        }
    }

    var shapeLabel: String {
        switch self {
        case .woman: "Lines"
        case .soldier: "Triangles"
        case .gentry: "Squares"
        case .noble: "Hexagons"
        case .priest: "Circles"
        }
    }

    var abbottNote: String {
        switch self {
        case .woman:
            "Straight lines — Abbott's controversial portrayal; they must announce their approach with a peace-cry."
        case .soldier:
            "Isosceles triangles — the lowest class of men, irregular and often violent."
        case .gentry:
            "Squares and pentagons — professional men, merchants, and gentlemen."
        case .noble:
            "Hexagons and above — hereditary aristocracy, born with more sides."
        case .priest:
            "Circles — the highest rank; many-sided polygons who approximate perfection."
        }
    }

    var kind: InhabitantKind {
        switch self {
        case .woman: .line
        case .soldier: .triangle
        case .gentry: .square
        case .noble: .hexagon
        case .priest: .circle
        }
    }
}

enum InhabitantKind: String {
    case line, triangle, square, hexagon, circle
}

struct Inhabitant: Identifiable {
    let id: String
    let name: String
    let caste: FlatlandCaste
    let kind: InhabitantKind
    let x: CGFloat
    let z: CGFloat
    let size: CGFloat
    let color: Color
}

enum FlatlandSociety {
    static let attribution = "From Edwin Abbott's Flatland (1884) — a satire of Victorian hierarchy as much as a lesson in dimensions."

    static let hierarchy: [FlatlandCaste] = [
        .woman, .soldier, .gentry, .noble, .priest,
    ]
}

enum FlatlandInhabitants {
    static let all: [Inhabitant] = [
        Inhabitant(id: "line1", name: "A Row", caste: .woman, kind: .line, x: -1.4, z: -0.8, size: 0.42, color: Color(red: 0.78, green: 0.45, blue: 0.58)),
        Inhabitant(id: "line2", name: "B Leaf", caste: .woman, kind: .line, x: 2.1, z: -0.4, size: 0.38, color: Color(red: 0.82, green: 0.52, blue: 0.64)),
        Inhabitant(id: "tri1", name: "Private", caste: .soldier, kind: .triangle, x: 1.8, z: -2.0, size: 0.30, color: Color(red: 0.35, green: 0.56, blue: 0.43)),
        Inhabitant(id: "tri2", name: "Corporal", caste: .soldier, kind: .triangle, x: -2.8, z: 0.8, size: 0.27, color: Color(red: 0.62, green: 0.42, blue: 0.35)),
        Inhabitant(id: "sq1", name: "Mr. Square", caste: .gentry, kind: .square, x: -2.2, z: -1.5, size: 0.35, color: Color(red: 0.77, green: 0.36, blue: 0.29)),
        Inhabitant(id: "sq2", name: "The Lawyer", caste: .gentry, kind: .square, x: 0.5, z: -2.8, size: 0.25, color: Color(red: 0.29, green: 0.49, blue: 0.71)),
        Inhabitant(id: "hex1", name: "Lord Hex", caste: .noble, kind: .hexagon, x: 2.5, z: 1.2, size: 0.32, color: Color(red: 0.72, green: 0.53, blue: 0.29)),
        Inhabitant(id: "cir1", name: "Circulus", caste: .priest, kind: .circle, x: -1.0, z: 2.0, size: 0.28, color: Color(red: 0.48, green: 0.42, blue: 0.62)),
    ]
}

struct CrossSectionSegment: Equatable {
    let start: SIMD2<Float>
    let end: SIMD2<Float>
}

struct CrossSectionPolygon: Equatable {
    let points: [SIMD2<Float>]
}