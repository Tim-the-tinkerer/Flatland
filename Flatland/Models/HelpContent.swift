import Foundation

struct HelpSection: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let paragraphs: [String]
    let rows: [(label: String, detail: String)]
}

enum HelpContent {
    static let title = "Flatland Help"
    static let subtitle = "A short guide to the journey"

    static let intro = """
    Flatland makes Carl Sagan’s dimensional analogy interactive. The left viewport shows a higher-dimensional truth; the right shows only what a lower-dimensional mind could perceive.
    """

    static let sections: [HelpSection] = [
        HelpSection(
            id: "start",
            title: "Getting started",
            symbol: "sparkles",
            paragraphs: [
                "Drag Height through plane to pass a shape through Flatland. Watch the right panel: Flatlanders never see the whole solid.",
                "Use Full Tour for the complete story, or open chapters one by one. Switch to 4D Mode when you are ready to reverse the analogy.",
            ],
            rows: []
        ),
        HelpSection(
            id: "viewports",
            title: "The two viewports",
            symbol: "rectangle.split.2x1",
            paragraphs: [
                "Flatland mode: left is our 3D view of the shape; right is the 2D cross-section Flatlanders see.",
                "4D Mode: left is a projected hypercube in higher space; right is the 3D polyhedron cut by our slice plane.",
                "Drag to orbit 3D scenes. The badges (3D / 2D / 4D) remind you which side of the analogy you are on.",
            ],
            rows: []
        ),
        HelpSection(
            id: "flatland",
            title: "Flatland mode",
            symbol: "circle.grid.cross",
            paragraphs: [
                "Choose a shape, then move height and tilts. A sphere grows and shrinks as a circle; a tilted cube yields changing polygons.",
                "Turn on Second apparition for two objects at once. Dual Apparitions and Sphere Chapter run short demos.",
            ],
            rows: [
                ("Passing through", "Shape that crosses the plane"),
                ("Height through plane", "Position above / below Flatland"),
                ("Tilt X / Tilt Z", "Orientation of the solid"),
                ("Auto-pass speed", "Continuous height animation"),
                ("Second apparition", "Independent second object"),
            ]
        ),
        HelpSection(
            id: "fourd",
            title: "4D Mode",
            symbol: "cube.transparent",
            paragraphs: [
                "You are the Flatlander now. A tesseract moves through ana — the fourth axis — and our world catches only a morphing polyhedron.",
                "W moves the hypercube through our space. Tilt XW / YW / ZW rotates the hypercube itself.",
                "Slice XW / YW / ZW tilts the cutting plane. The same hypercube can produce very different shapes — cross-section depends on perspective.",
            ],
            rows: [
                ("W through our space", "Slide the hypercube along W"),
                ("Tilt XW / YW / ZW", "4D orientation of the tesseract"),
                ("Slice XW / YW / ZW", "Angle of our world’s cut"),
                ("Auto-pass W", "Continuous motion along W"),
                ("Hypercube Pass", "Demo with pass-through and slice tilt"),
            ]
        ),
        HelpSection(
            id: "chapters",
            title: "Guided chapters",
            symbol: "book.closed",
            paragraphs: [
                "Select a chapter for narration and presets. Play Chapter runs its demo. Full Tour walks through every chapter.",
                "Controls lock while demos and tours run so the story can finish uninterrupted.",
            ],
            rows: [
                ("1 · Meet Flatland", "A world of only two dimensions"),
                ("2 · Sphere Encounter", "Point, circle, vanish"),
                ("3 · Cube Encounter", "Polygons that refuse to make sense"),
                ("4 · We Become Flatlanders", "Hypercube through our world"),
                ("5 · Are We Flatlanders?", "The deeper lesson"),
            ]
        ),
        HelpSection(
            id: "tips",
            title: "Tips",
            symbol: "lightbulb",
            paragraphs: [
                "Start with a sphere and no tilt — pure growth and fade of a circle.",
                "In 4D Mode, set W near zero, then only move the Slice sliders to feel perspective change.",
                "If the right 4D panel is empty, the hypercube may miss the slice; return W toward zero and reduce slice tilt.",
                "Expand Abbott’s Society for the satirical hierarchy of original Flatland.",
            ],
            rows: []
        ),
    ]

    static let closing = "What Flatlanders see of a sphere is what we would see of a hypercube — a changing lower-dimensional shadow of a fuller truth."
}
