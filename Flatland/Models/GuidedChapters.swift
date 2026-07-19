import Foundation

enum GuidedChapterID: Int, CaseIterable, Identifiable {
    case meetFlatland
    case sphereEncounter
    case cubeEncounter
    case fourthDimension
    case areWeFlatlanders

    var id: Int { rawValue }

    var number: Int { rawValue + 1 }
}

struct GuidedChapterStep: Identifiable {
    let id: Int
    let quote: String
    let insight: String
}

struct ChapterDemoStep {
    let height: Float
    let rotateX: Float
    let rotateZ: Float
    let wPosition: Float
    let rotateXW: Float
    let rotateYW: Float
    let rotateZW: Float
    let sliceTiltXW: Float
    let sliceTiltYW: Float
    let sliceTiltZW: Float
    let duration: TimeInterval
    let pause: Duration

    init(
        height: Float = 0,
        rotateX: Float = 0,
        rotateZ: Float = 0,
        wPosition: Float = 0,
        rotateXW: Float = 0,
        rotateYW: Float = 0,
        rotateZW: Float = 0,
        sliceTiltXW: Float = 0,
        sliceTiltYW: Float = 0,
        sliceTiltZW: Float = 0,
        duration: TimeInterval,
        pause: Duration
    ) {
        self.height = height
        self.rotateX = rotateX
        self.rotateZ = rotateZ
        self.wPosition = wPosition
        self.rotateXW = rotateXW
        self.rotateYW = rotateYW
        self.rotateZW = rotateZW
        self.sliceTiltXW = sliceTiltXW
        self.sliceTiltYW = sliceTiltYW
        self.sliceTiltZW = sliceTiltZW
        self.duration = duration
        self.pause = pause
    }
}

enum DimensionMode: String, Equatable {
    case flatland
    case fourD
}

struct GuidedChapter: Identifiable {
    let id: GuidedChapterID
    let title: String
    let subtitle: String
    let steps: [GuidedChapterStep]
    let shape: PassingShape
    let dimensionMode: DimensionMode
    let demo: [ChapterDemoStep]

    var stepCount: Int { steps.count }
}

enum GuidedChapters {
    static let all: [GuidedChapter] = [
        GuidedChapter(
            id: .meetFlatland,
            title: "Meet Flatland",
            subtitle: "A world of only two dimensions",
            steps: [
                GuidedChapterStep(
                    id: 0,
                    quote: "\"Imagine a world of only two dimensions — a vast plane where the inhabitants are flat figures: lines, triangles, squares, and circles.\"",
                    insight: "Flatlanders know only length and width. The concept of \"up\" is as unimaginable to them as a fourth dimension is to us."
                ),
                GuidedChapterStep(
                    id: 1,
                    quote: "\"They can move freely north, south, east, and west — but they have no notion whatsoever of above or below.\"",
                    insight: "Their entire universe is the surface of their world. There is no sky, no depth — only the plane itself."
                ),
            ],
            shape: .sphere,
            dimensionMode: .flatland,
            demo: []
        ),
        GuidedChapter(
            id: .sphereEncounter,
            title: "Sphere Encounter",
            subtitle: "A miracle in Flatland",
            steps: [
                GuidedChapterStep(
                    id: 0,
                    quote: "\"Now imagine we pass a three-dimensional sphere through their world. What would they see?\"",
                    insight: "Watch the sphere descend through the plane."
                ),
                GuidedChapterStep(
                    id: 1,
                    quote: "\"First, a point appears from nowhere — a miraculous apparition. Then the point grows into a circle, widening as the sphere descends.\"",
                    insight: "A sphere crossing Flatland appears first as a point, then grows into a circle."
                ),
                GuidedChapterStep(
                    id: 2,
                    quote: "\"As the sphere passes through, the circle reaches its maximum extent, then contracts, and finally disappears — vanishing as mysteriously as it arrived.\"",
                    insight: "The Flatlanders witness a miracle they cannot explain. They see only a slice of a greater reality."
                ),
            ],
            shape: .sphere,
            dimensionMode: .flatland,
            demo: [
                ChapterDemoStep(height: -2.2, rotateX: 0, rotateZ: 0, duration: 0.8, pause: .seconds(1)),
                ChapterDemoStep(height: -1.2, rotateX: 0, rotateZ: 0, duration: 1.0, pause: .zero),
                ChapterDemoStep(height: 0.0, rotateX: 0, rotateZ: 0, duration: 1.0, pause: .zero),
                ChapterDemoStep(height: 1.2, rotateX: 0, rotateZ: 0, duration: 1.0, pause: .zero),
                ChapterDemoStep(height: 2.2, rotateX: 0, rotateZ: 0, duration: 1.0, pause: .seconds(1)),
                ChapterDemoStep(height: 0.0, rotateX: 0, rotateZ: 0, duration: 0.8, pause: .zero),
            ]
        ),
        GuidedChapter(
            id: .cubeEncounter,
            title: "Cube Encounter",
            subtitle: "Polygons that refuse to make sense",
            steps: [
                GuidedChapterStep(
                    id: 0,
                    quote: "\"A cube would appear as a polygon that changes shape — a triangle, a square, a pentagon — never revealing its true cubic nature.\"",
                    insight: "Each slice is a different polygon. The whole truth is literally beyond their plane."
                ),
                GuidedChapterStep(
                    id: 1,
                    quote: "\"The Flatlanders would argue about the nature of this apparition. Some would call it sorcery. None could conceive of a third dimension.\"",
                    insight: "Watch the inhabitants react as a cube passes at an angle."
                ),
            ],
            shape: .cube,
            dimensionMode: .flatland,
            demo: [
                ChapterDemoStep(height: -1.8, rotateX: 0, rotateZ: 0, duration: 0.8, pause: .zero),
                ChapterDemoStep(height: 0.0, rotateX: 25, rotateZ: 0, duration: 1.2, pause: .milliseconds(400)),
                ChapterDemoStep(height: 0.0, rotateX: 25, rotateZ: 45, duration: 1.0, pause: .milliseconds(400)),
                ChapterDemoStep(height: 1.4, rotateX: 35, rotateZ: 30, duration: 1.4, pause: .seconds(1)),
                ChapterDemoStep(height: 0.0, rotateX: 0, rotateZ: 0, duration: 0.8, pause: .zero),
            ]
        ),
        GuidedChapter(
            id: .fourthDimension,
            title: "We Become Flatlanders",
            subtitle: "A hypercube through our world",
            steps: [
                GuidedChapterStep(
                    id: 0,
                    quote: "\"If a fourth dimension exists, a hypercube passing through our three-dimensional space would appear as a polyhedron that changes shape — morphing, splitting, and rejoining.\"",
                    insight: "Enter 4D Mode: the left view shows the tesseract in higher space; the right shows only what we could perceive."
                ),
                GuidedChapterStep(
                    id: 1,
                    quote: "\"Just as Flatlanders see a circle grow and shrink, we would see a cube become a prism, a pyramid, an octahedron — never the true hypercube.\"",
                    insight: "Drag W to pass the hypercube through our universe. Tilt the slice plane — the same tesseract yields stranger polygons."
                ),
                GuidedChapterStep(
                    id: 2,
                    quote: "\"Sagan's loop closes: Flatlanders are blind to height; we may be blind to ana. What passes through us unseen?\"",
                    insight: "You are now the Flatlander. The full hypercube exists — your world reveals only a slice, and that slice depends on perspective."
                ),
            ],
            shape: .sphere,
            dimensionMode: .fourD,
            demo: [
                ChapterDemoStep(wPosition: -2.0, rotateXW: 20, rotateYW: 10, rotateZW: 5, duration: 0.9, pause: .zero),
                ChapterDemoStep(wPosition: 0.0, rotateXW: 35, rotateYW: 25, rotateZW: 15, duration: 1.4, pause: .milliseconds(400)),
                ChapterDemoStep(wPosition: 2.0, rotateXW: 50, rotateYW: 40, rotateZW: 30, duration: 1.6, pause: .milliseconds(600)),
                ChapterDemoStep(wPosition: 0.0, rotateXW: 25, rotateYW: 15, rotateZW: 10, sliceTiltXW: 55, sliceTiltYW: 20, duration: 1.4, pause: .milliseconds(800)),
                ChapterDemoStep(wPosition: 0.0, rotateXW: 25, rotateYW: 15, rotateZW: 10, sliceTiltYW: 45, duration: 1.2, pause: .zero),
            ]
        ),
        GuidedChapter(
            id: .areWeFlatlanders,
            title: "Are We Flatlanders?",
            subtitle: "The deeper lesson",
            steps: [
                GuidedChapterStep(
                    id: 0,
                    quote: "\"Perhaps we are like the Flatlanders — unable to perceive a fourth physical dimension, blind to wonders passing through our world unseen.\"",
                    insight: "What higher-dimensional truths might surround us, visible only as fleeting shadows?"
                ),
                GuidedChapterStep(
                    id: 1,
                    quote: "\"The appeal of the book Flatland lies in its ability to make us feel the limitations of our own perceptions — and the possibility that reality is far richer than we can see.\"",
                    insight: "You have now seen Flatland from both sides of the plane. What else might be passing through?"
                ),
            ],
            shape: .sphere,
            dimensionMode: .flatland,
            demo: [
                ChapterDemoStep(height: 2.0, rotateX: 0, rotateZ: 0, duration: 0.6, pause: .milliseconds(300)),
                ChapterDemoStep(height: 0.0, rotateX: 0, rotateZ: 0, duration: 1.6, pause: .seconds(1)),
            ]
        ),
    ]

    static func chapter(for id: GuidedChapterID) -> GuidedChapter {
        all.first { $0.id == id } ?? all[0]
    }
}