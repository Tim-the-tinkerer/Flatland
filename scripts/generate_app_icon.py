#!/usr/bin/env python3
"""Generate Flatland macOS app icon assets."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ICONSET = ROOT / "Flatland" / "Assets.xcassets" / "AppIcon.appiconset"
MASTER = ICONSET / "icon_1024.png"

# Brand colors (FlatlandTheme)
BG_TOP = (10, 14, 23)
BG_BOT = (6, 10, 18)
PLANE = (42, 72, 48)
PLANE_EDGE = (74, 126, 100)
GOLD = (212, 175, 95)
GOLD_LIGHT = (240, 214, 150)
GOLD_DEEP = (160, 120, 50)
VIOLET = (155, 127, 212)
VIOLET_DIM = (61, 47, 107)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def mix(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def draw_icon(size: int = 1024) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()

    # Soft vertical gradient background
    for y in range(size):
        t = y / (size - 1)
        c = mix(BG_TOP, BG_BOT, t)
        for x in range(size):
            # Subtle vignette
            nx = (x / size - 0.5) * 2
            ny = (y / size - 0.5) * 2
            vig = min(1.0, math.sqrt(nx * nx + ny * ny) * 0.55)
            v = mix(c, (4, 6, 12), vig * 0.55)
            px[x, y] = (*v, 255)

    draw = ImageDraw.Draw(img)
    cx = size * 0.5
    cy = size * 0.52
    plane_y = size * 0.58
    radius = size * 0.28

    # Soft ambient glow behind the sphere
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    for i in range(8, 0, -1):
        r = radius * (1.15 + i * 0.12)
        alpha = int(18 + i * 4)
        glow_draw.ellipse(
            [cx - r, cy - r * 0.95, cx + r, cy + r * 0.95],
            fill=(*GOLD, alpha),
        )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=size * 0.04))
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    # Flatland plane as a perspective trapezoid
    inset = size * 0.12
    plane_h = size * 0.16
    top_w = size * 0.72
    bot_w = size * 0.92
    top_y = plane_y - plane_h * 0.35
    bot_y = plane_y + plane_h * 0.85

    trap = [
        (cx - top_w / 2, top_y),
        (cx + top_w / 2, top_y),
        (cx + bot_w / 2, bot_y),
        (cx - bot_w / 2, bot_y),
    ]

    # Plane fill with slight green gradient via layered trapezoids
    for i in range(12):
        t = i / 11
        y0 = lerp(top_y, bot_y, t)
        y1 = lerp(top_y, bot_y, min(1.0, t + 0.09))
        w0 = lerp(top_w, bot_w, t)
        w1 = lerp(top_w, bot_w, min(1.0, t + 0.09))
        shade = mix(PLANE, (22, 48, 32), t * 0.55)
        draw.polygon(
            [
                (cx - w0 / 2, y0),
                (cx + w0 / 2, y0),
                (cx + w1 / 2, y1),
                (cx - w1 / 2, y1),
            ],
            fill=(*shade, 245),
        )

    # Plane edge highlight
    draw.line(
        [(cx - top_w / 2, top_y), (cx + top_w / 2, top_y)],
        fill=(*PLANE_EDGE, 200),
        width=max(2, size // 220),
    )

    # Grid lines on plane
    for i in range(1, 6):
        t = i / 6
        y = lerp(top_y, bot_y, t)
        w = lerp(top_w, bot_w, t)
        alpha = int(40 + t * 30)
        draw.line(
            [(cx - w / 2 + inset * 0.15, y), (cx + w / 2 - inset * 0.15, y)],
            fill=(*PLANE_EDGE, alpha),
            width=max(1, size // 400),
        )
    for i in range(-2, 3):
        t = (i + 2.5) / 5
        x_top = cx + (i / 3.2) * top_w * 0.42
        x_bot = cx + (i / 3.2) * bot_w * 0.48
        draw.line(
            [(x_top, top_y), (x_bot, bot_y)],
            fill=(*PLANE_EDGE, 50),
            width=max(1, size // 400),
        )

    # Sphere above plane (3D body)
    sphere = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(sphere)
    # Draw sphere only above the plane cut
    for y in range(int(cy - radius), int(plane_y) + 1):
        dy = (y - cy) / radius
        if abs(dy) > 1:
            continue
        half = radius * math.sqrt(max(0.0, 1 - dy * dy))
        for x in range(int(cx - half), int(cx + half) + 1):
            dx = (x - cx) / radius
            if dx * dx + dy * dy > 1:
                continue
            # Lighting from upper-left
            nx, ny = dx, dy
            nz = math.sqrt(max(0.0, 1 - nx * nx - ny * ny))
            light = max(0.0, nx * -0.35 + ny * -0.45 + nz * 0.9)
            base = mix(GOLD_DEEP, GOLD, 0.35 + light * 0.55)
            if light > 0.75:
                base = mix(base, GOLD_LIGHT, (light - 0.75) / 0.25)
            # Slight violet rim on right
            rim = max(0.0, nx * 0.55 + nz * 0.2)
            if rim > 0.55:
                base = mix(base, VIOLET, (rim - 0.55) * 0.45)
            sphere.putpixel((x, y), (*base, 255))

    # Soft sphere edge
    sphere = Image.alpha_composite(
        Image.new("RGBA", (size, size), (0, 0, 0, 0)),
        sphere,
    )
    img = Image.alpha_composite(img, sphere)
    draw = ImageDraw.Draw(img)

    # Gold cross-section circle on the plane (what Flatlanders see)
    cut_r = radius * math.sqrt(max(0.0, 1 - ((plane_y - cy) / radius) ** 2))
    # Ellipse foreshortening for plane perspective
    ellipse_h = cut_r * 0.38
    ellipse_box = [
        cx - cut_r,
        plane_y - ellipse_h,
        cx + cut_r,
        plane_y + ellipse_h,
    ]
    # Glow under circle
    for i in range(5, 0, -1):
        pad = i * size * 0.008
        alpha = 28 + i * 10
        draw.ellipse(
            [
                ellipse_box[0] - pad,
                ellipse_box[1] - pad * 0.5,
                ellipse_box[2] + pad,
                ellipse_box[3] + pad * 0.5,
            ],
            fill=(*GOLD, alpha),
        )
    draw.ellipse(ellipse_box, fill=(*GOLD_LIGHT, 230), outline=(*GOLD, 255), width=max(2, size // 180))

    # Small highlight on circle
    hx = cx - cut_r * 0.25
    hy = plane_y - ellipse_h * 0.2
    draw.ellipse(
        [hx - cut_r * 0.12, hy - ellipse_h * 0.25, hx + cut_r * 0.12, hy + ellipse_h * 0.25],
        fill=(*GOLD_LIGHT, 180),
    )

    # Violet accent ring (higher dimension hint) — partial arc above
    ring_r = radius * 1.18
    ring = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    rdraw = ImageDraw.Draw(ring)
    stroke = max(3, size // 90)
    rdraw.arc(
        [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
        start=200,
        end=340,
        fill=(*VIOLET, 200),
        width=stroke,
    )
    ring = ring.filter(ImageFilter.GaussianBlur(radius=size * 0.006))
    img = Image.alpha_composite(img, ring)

    # Soft outer rim so icon reads at tiny sizes
    final = ImageDraw.Draw(img)
    margin = size * 0.02
    # Don't draw a hard border — macOS applies squircle mask

    return img


def main() -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)
    master = draw_icon(1024)
    master.save(MASTER, "PNG")

    # macOS AppIcon sizes: size @ scale
    specs = [
        (16, 1, "icon_16x16.png"),
        (16, 2, "diana.k@example.org"),
        (32, 1, "icon_32x32.png"),
        (32, 2, "ivan.p@example.net"),
        (128, 1, "icon_128x128.png"),
        (128, 2, "icon_128x128@2x.png"),
        (256, 1, "icon_256x256.png"),
        (256, 2, "wendy.h@example.net"),
        (512, 1, "icon_512x512.png"),
        (512, 2, "walt.e@example.net"),
    ]

    for base, scale, name in specs:
        px = base * scale
        resized = master.resize((px, px), Image.Resampling.LANCZOS)
        resized.save(ICONSET / name, "PNG")

    contents = {
        "images": [
            {"filename": "icon_16x16.png", "idiom": "mac", "scale": "1x", "size": "16x16"},
            {"filename": "diana.k@example.org", "idiom": "mac", "scale": "2x", "size": "16x16"},
            {"filename": "icon_32x32.png", "idiom": "mac", "scale": "1x", "size": "32x32"},
            {"filename": "ivan.p@example.net", "idiom": "mac", "scale": "2x", "size": "32x32"},
            {"filename": "icon_128x128.png", "idiom": "mac", "scale": "1x", "size": "128x128"},
            {"filename": "icon_128x128@2x.png", "idiom": "mac", "scale": "2x", "size": "128x128"},
            {"filename": "icon_256x256.png", "idiom": "mac", "scale": "1x", "size": "256x256"},
            {"filename": "wendy.h@example.net", "idiom": "mac", "scale": "2x", "size": "256x256"},
            {"filename": "icon_512x512.png", "idiom": "mac", "scale": "1x", "size": "512x512"},
            {"filename": "walt.e@example.net", "idiom": "mac", "scale": "2x", "size": "512x512"},
        ],
        "info": {"author": "xcode", "version": 1},
    }

    import json

    (ICONSET / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")
    print(f"Wrote icons to {ICONSET}")


if __name__ == "__main__":
    main()
