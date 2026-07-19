# Flatland Help

Quick reference for using the **Flatland** macOS app.

---

## Getting started

1. Open **Flatland.app** (or build with `./rebuild.sh --open`).  
2. The left viewport is the *higher* view; the right is the *limited* view.  
3. Drag **Height through plane** to pass a shape through Flatland.  
4. Press **Full Tour** for the complete story, or pick a chapter below.  
5. Press **4D Mode** when you are ready to reverse the analogy.

---

## The two viewports

### Flatland mode

| Panel | Badge | Meaning |
|-------|--------|---------|
| **Our perspective** | 3D | Full shape above/below the plane |
| **Flatland** | 2D | Only the cross-section Flatlanders can see |

### 4D Mode

| Panel | Badge | Meaning |
|-------|--------|---------|
| **Beyond our space** | 4D | Hypercube projected into a space we can draw |
| **Our world** | 3D | Only the polyhedron cut by our slice plane |

Orbit the 3D scenes by dragging. Scroll to zoom where supported.

---

## Flatland mode controls

| Control | What it does |
|---------|----------------|
| **Passing through** | Choose the 3D shape (sphere, cube, …) |
| **Height through plane** | Move the shape up/down through Flatland |
| **Tilt X / Tilt Z** | Orient the shape (matters most for cubes) |
| **Auto-pass speed** | Continuous pass-through animation |
| **Sphere Chapter** | Animated sphere demo |
| **Dual Apparitions** | Two shapes crossing at once |

### Second apparition

Turn on **Second apparition** to send a second object through Flatland. Adjust its shape, height, plane position, and tilts. Flatlanders see two mysterious figures — never two whole solids.

---

## 4D Mode controls

| Control | What it does |
|---------|----------------|
| **W through our space** | Slide the hypercube along the fourth axis |
| **Tilt XW / YW / ZW** | Rotate the hypercube in 4D planes |
| **Slice XW / YW / ZW** | Tilt the *cutting plane* (not the cube) |
| **Auto-pass W** | Continuous motion along W |
| **Hypercube Pass** | Demo: pass-through, then slice-plane tilt |

### Why tilt the slice plane?

A fixed cut is only one perspective. Tilting the slice is like changing how our 3D “universe” sits relative to the tesseract. The same hypercube can produce very different polyhedra — the lesson that **cross-section depends on perspective**.

---

## Guided chapters

| # | Title | Focus |
|---|--------|--------|
| 1 | Meet Flatland | The 2D world |
| 2 | Sphere Encounter | Point → circle → vanish |
| 3 | Cube Encounter | Changing polygons |
| 4 | We Become Flatlanders | Hypercube / 4D Mode |
| 5 | Are We Flatlanders? | Closing lesson |

- Select a chapter to load its preset and narration.  
- **Play Chapter** runs that chapter’s demo and quotes.  
- **Full Tour** runs all chapters in order.  
- During demos, most controls are disabled so the story can finish.

---

## Tips for exploration

1. **Sphere first** — set height from −2.5 to +2.5 with no tilt; watch the right panel.  
2. **Cube + tilt** — small X/Z tilts turn squares into hexagons and odd polygons.  
3. **4D centered** — set W ≈ 0, then only move the **Slice** sliders.  
4. **Compare** — leave the hypercube fixed; flip Slice XW vs Slice YW.  
5. **Society panel** — expand Abbott’s hierarchy for the satirical side of *Flatland*.

---

## Keyboard & menus

| Action | Where |
|--------|--------|
| Flatland Help | **Help → Flatland Help**, or **⌘?** |
| Close help sheet | Esc or the Done button |

---

## Requirements & troubleshooting

- **macOS 14+**  
- If the app icon is stale after an update, reopen the app or relaunch the Dock.  
- Rebuild from source: `./rebuild.sh` in the project folder.  
- 4D right panel empty: the hypercube may not intersect the slice (try W near 0 and lower slice tilts).

---

## The idea in one sentence

*What Flatlanders see of a sphere is what we would see of a hypercube — a changing lower-dimensional shadow of a fuller truth.*
