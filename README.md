# Flatland

**A journey into the hidden dimensions**

An interactive macOS app inspired by Carl Sagan’s *Cosmos* and Edwin Abbott’s *Flatland*. Watch three-dimensional shapes pass through a two-dimensional world — then step into 4D Mode and become the Flatlander yourself, as a hypercube slices through our space.

---

## What it teaches

Flatlanders live on a plane. They know length and width, but not height. When a sphere passes through their world, they see a point appear, grow into a circle, shrink, and vanish — never the true sphere.

Sagan’s lesson: just as they cannot imagine *up*, we may be blind to a fourth physical dimension. Flatland makes that analogy visible.

---

## Features

### Dual viewports

| Mode | Left | Right |
|------|------|--------|
| **Flatland** | Our 3D view of a shape crossing the plane | What Flatlanders perceive (2D cross-section) |
| **4D Mode** | Projected hypercube (tesseract) in higher space | The 3D polyhedron we would see at the slice |

### Flatland mode

- Shapes: sphere, cube, tetrahedron, cylinder, torus, cone  
- Height through the plane, tilt X / Z  
- Auto-pass animation  
- Second apparition (two shapes at once)  
- Inhabitants that react to nearby apparitions  
- Abbott’s Flatland society panel  

### 4D Mode

- W position — move the hypercube through our space  
- Tilt XW / YW / ZW and spin  
- **Slice plane** tilts (XW / YW / ZW) — same hypercube, stranger polygons  
- Auto-pass along W  
- Hypercube Pass demo  

### Guided story

Five chapters with quotes, insights, and animated demos:

1. Meet Flatland  
2. Sphere Encounter  
3. Cube Encounter  
4. We Become Flatlanders (4D)  
5. Are We Flatlanders?  

**Full Tour** runs every chapter in sequence.

---

## Requirements

- macOS 14.0 or later  
- Xcode 16+ (to build from source)

---

## Build & run

```bash
cd /path/to/Flatland
./rebuild.sh          # builds Release → Flatland.app
./rebuild.sh --open   # build and launch
```

Or open `Flatland.xcodeproj` in Xcode and run the **Flatland** scheme.

The built app is copied to `Flatland.app` in the project root.

### App icon

```bash
# optional: regenerate icons (needs Pillow in a venv)
python3 -m venv .venv && .venv/bin/pip install pillow
.venv/bin/python scripts/generate_app_icon.py
./rebuild.sh
```

---

## Project layout

```
Flatland/
├── Flatland.xcodeproj
├── Flatland/                 # SwiftUI + SceneKit sources
│   ├── FlatlandApp.swift
│   ├── ContentView.swift
│   ├── Engine/               # geometry, hypercube math, inhabitants
│   ├── Models/               # chapters, shapes, help content
│   ├── Views/                # 2D / 3D / 4D viewports, help
│   ├── ViewModel/
│   └── Theme/
├── scripts/                  # icon generator
├── rebuild.sh
├── README.md
├── CHANGELOG.md
├── HELP.md
└── FUTURE_IDEAS.txt
```

---

## Help

- **In the app:** Help button in the header, or **Help → Flatland Help** (⌘?)  
- **In this repo:** [HELP.md](HELP.md)

---

## Credits & inspiration

- Carl Sagan, *Cosmos* (the Flatland / fourth-dimension segment)  
- Edwin A. Abbott, *Flatland: A Romance of Many Dimensions* (1884)

This is an educational exploration, not affiliated with either work’s rights holders.

---

## License

Personal / educational project. Add a license file if you distribute publicly.
