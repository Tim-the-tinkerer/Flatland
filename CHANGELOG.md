# Changelog

All notable changes to **Flatland** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-07-18

### Added

#### Core experience
- Dual-viewport layout: higher-dimensional view vs. limited perception  
- Flatland mode: 3D shape crossing a 2D plane with live cross-section  
- Shapes: sphere, cube, tetrahedron, cylinder, torus, cone  
- Height, tilt X / Z, and auto-pass controls  
- Flatland 2D view with inhabitant reactions to apparitions  
- Abbott’s Flatland society panel  

#### Multiple apparitions
- Optional second shape with independent height, tilt, and position  
- Dual Apparitions demo  

#### 4D Mode
- Hypercube (tesseract) projected into 3D on the left  
- 3D cross-section polyhedron on the right (what “we” would see)  
- W position and XW / YW / ZW / XY orientation controls  
- **Tilted slice plane** (Slice XW / YW / ZW) for perspective-dependent cuts  
- Auto-pass along W  
- Hypercube Pass demo (pass-through + slice tilt sequence)  

#### Guided narration
- Five guided chapters with quotes, insights, and demos  
- Full Tour mode  
- Per-chapter play / progress  

#### App polish
- Custom app icon (sphere through Flatland plane)  
- Product renamed to **Flatland** (`com.tim.Flatland`)  
- In-app Help (Help view + menu)  
- README, CHANGELOG, HELP  

### Technical
- SwiftUI + SceneKit, macOS 14+  
- Stable 4D→3D projection for the hypercube wireframe  
- Edge–plane intersection + convex hull for 4D slices  
- `rebuild.sh` for Release builds  

---

## [Unreleased]

Ideas under consideration live in `FUTURE_IDEAS.txt` (e.g. live geometry readout, scrubbable timeline, voice narration, presentation mode).
