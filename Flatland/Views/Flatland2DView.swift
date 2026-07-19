import SwiftUI

struct Flatland2DView: View {
    let layers: [ApparitionCrossSection]
    let inhabitants: [AnimatedInhabitant]
    let huddleLinks: [(SIMD2<Float>, SIMD2<Float>)]
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 10
            let offset = CGPoint(x: size.width / 2, y: size.height / 2)

            drawBackground(context: &context, size: size, offset: offset)
            drawGrid(context: &context, offset: offset, scale: scale)
            drawApparition(context: &context, offset: offset, scale: scale)
            drawHuddleLinks(context: &context, offset: offset, scale: scale)
            drawInhabitants(context: &context, offset: offset, scale: scale)
            drawBorder(context: &context, size: size)
        }
        .background(FlatlandTheme.flatlandGreenDeep)
    }

    private func drawBackground(context: inout GraphicsContext, size: CGSize, offset: CGPoint) {
        let rect = CGRect(origin: .zero, size: size)
        let gradient = Gradient(colors: [
            Color(red: 0.12, green: 0.29, blue: 0.20),
            FlatlandTheme.flatlandGreenDeep,
        ])
        context.fill(
            Path(rect),
            with: .radialGradient(gradient, center: offset, startRadius: 0, endRadius: max(size.width, size.height) * 0.55)
        )
    }

    private func drawGrid(context: inout GraphicsContext, offset: CGPoint, scale: CGFloat) {
        var gridPath = Path()
        for index in -5...5 {
            let x = offset.x + CGFloat(index) * scale
            gridPath.move(to: CGPoint(x: x, y: offset.y - 5 * scale))
            gridPath.addLine(to: CGPoint(x: x, y: offset.y + 5 * scale))

            let y = offset.y + CGFloat(index) * scale
            gridPath.move(to: CGPoint(x: offset.x - 5 * scale, y: y))
            gridPath.addLine(to: CGPoint(x: offset.x + 5 * scale, y: y))
        }
        context.stroke(gridPath, with: .color(FlatlandTheme.gold.opacity(0.12)), lineWidth: 1)
    }

    private func drawApparition(context: inout GraphicsContext, offset: CGPoint, scale: CGFloat) {
        for layer in layers {
            let fill = ApparitionAppearance.fill(for: layer.style)
            let stroke = ApparitionAppearance.stroke(for: layer.style)
            let glow = ApparitionAppearance.glow(for: layer.style)

            for polygon in layer.polygons {
                guard polygon.points.count >= 3 else { continue }
                var path = Path()
                let first = map(polygon.points[0], offset: offset, scale: scale)
                path.move(to: first)
                for point in polygon.points.dropFirst() {
                    path.addLine(to: map(point, offset: offset, scale: scale))
                }
                path.closeSubpath()

                context.drawLayer { drawLayer in
                    drawLayer.addFilter(.shadow(color: glow, radius: 10, x: 0, y: 0))
                    drawLayer.fill(path, with: .color(fill))
                    drawLayer.stroke(path, with: .color(stroke), lineWidth: 2.5)
                }
            }

            if layer.polygons.isEmpty, let segment = layer.segments.first {
                let center = map((segment.start + segment.end) * 0.5, offset: offset, scale: scale)
                let dot = Path(ellipseIn: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))
                context.drawLayer { drawLayer in
                    drawLayer.addFilter(.shadow(color: glow, radius: 8, x: 0, y: 0))
                    drawLayer.fill(dot, with: .color(stroke))
                }
            }
        }
    }

    private func drawHuddleLinks(context: inout GraphicsContext, offset: CGPoint, scale: CGFloat) {
        var path = Path()
        for link in huddleLinks {
            path.move(to: map(link.0, offset: offset, scale: scale))
            path.addLine(to: map(link.1, offset: offset, scale: scale))
        }
        context.stroke(
            path,
            with: .color(FlatlandTheme.gold.opacity(0.22)),
            style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
        )
    }

    private func drawInhabitants(context: inout GraphicsContext, offset: CGPoint, scale: CGFloat) {
        for inhabitant in inhabitants {
            let position = CGPoint(
                x: offset.x + inhabitant.x * scale,
                y: offset.y + inhabitant.z * scale
            )

            let tremble = inhabitant.fear * CGFloat(sin(time * 20 + Double(inhabitant.homeX))) * 3
            let size = inhabitant.size * scale
            let eyeScale = inhabitant.state == .alert || inhabitant.state == .flee ? 1.2 : 1.0

            context.drawLayer { layer in
                layer.translateBy(x: position.x + tremble, y: position.y)
                layer.rotate(by: Angle(radians: inhabitant.angle))

                if inhabitant.state == .flee {
                    layer.addFilter(.shadow(color: inhabitant.color.opacity(0.35), radius: 6, x: 0, y: 0))
                }

                drawBody(on: layer, inhabitant: inhabitant, size: size)
                drawEyes(on: layer, inhabitant: inhabitant, size: size, eyeScale: eyeScale)

                if inhabitant.state == .curious {
                    let probe = Path(ellipseIn: CGRect(x: -2, y: -size - 8, width: 4, height: 4))
                    layer.fill(probe, with: .color(FlatlandTheme.gold.opacity(0.8)))
                }
            }

            if inhabitant.fear > 0.25 || inhabitant.caste == .priest {
                let label = Text(inhabitant.name)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(FlatlandTheme.textMuted.opacity(0.85))
                context.draw(label, at: CGPoint(x: position.x, y: position.y + size + 10), anchor: .top)
            }
        }
    }

    private func drawBody(on layer: GraphicsContext, inhabitant: AnimatedInhabitant, size: CGFloat) {
        switch inhabitant.kind {
        case .line:
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -size * 1.3))
            path.addLine(to: CGPoint(x: 0, y: size * 1.3))
            layer.stroke(path, with: .color(inhabitant.color), lineWidth: max(2.5, size * 0.14))

        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -size))
            path.addLine(to: CGPoint(x: size * 0.95, y: size))
            path.addLine(to: CGPoint(x: -size * 0.55, y: size * 0.85))
            path.closeSubpath()
            layer.fill(path, with: .color(inhabitant.color))
            layer.stroke(path, with: .color(.black.opacity(0.4)), lineWidth: 1.5)

        case .square:
            let rect = CGRect(x: -size, y: -size, width: size * 2, height: size * 2)
            layer.fill(Path(rect), with: .color(inhabitant.color))
            layer.stroke(Path(rect), with: .color(.black.opacity(0.4)), lineWidth: 1.5)

        case .hexagon:
            var path = Path()
            for index in 0..<6 {
                let angle = (CGFloat(index) * 2 * .pi / 6) - .pi / 2
                let point = CGPoint(x: cos(angle) * size, y: sin(angle) * size)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.closeSubpath()
            layer.fill(path, with: .color(inhabitant.color))
            layer.stroke(path, with: .color(.black.opacity(0.4)), lineWidth: 1.5)

        case .circle:
            let circle = CGRect(x: -size, y: -size, width: size * 2, height: size * 2)
            if inhabitant.caste == .priest {
                let halo = CGRect(x: -size * 1.15, y: -size * 1.15, width: size * 2.3, height: size * 2.3)
                layer.stroke(Path(ellipseIn: halo), with: .color(FlatlandTheme.gold.opacity(0.35)), lineWidth: 1)
            }
            layer.fill(Path(ellipseIn: circle), with: .color(inhabitant.color))
            layer.stroke(Path(ellipseIn: circle), with: .color(.black.opacity(0.4)), lineWidth: 1.5)
        }
    }

    private func drawEyes(
        on layer: GraphicsContext,
        inhabitant: AnimatedInhabitant,
        size: CGFloat,
        eyeScale: CGFloat
    ) {
        if inhabitant.kind == .line {
            let eyeRadius = max(3, size * 0.14 * eyeScale)
            let eye = CGRect(x: -eyeRadius, y: -eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
            layer.fill(Path(ellipseIn: eye), with: .color(.white))
            layer.fill(
                Path(ellipseIn: CGRect(x: -eyeRadius * 0.5, y: -eyeRadius * 0.5, width: eyeRadius, height: eyeRadius)),
                with: .color(Color(red: 0.10, green: 0.10, blue: 0.18))
            )
            return
        }

        let eyeOffset = size * 0.35
        let eyeRadius = size * 0.12 * eyeScale
        let leftEye = CGRect(x: -eyeOffset - eyeRadius, y: -size * 0.15 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
        let rightEye = CGRect(x: eyeOffset - eyeRadius, y: -size * 0.15 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
        layer.fill(Path(ellipseIn: leftEye), with: .color(.white))
        layer.fill(Path(ellipseIn: rightEye), with: .color(.white))

        let pupilRadius = eyeRadius * 0.5
        let pupilShift: CGFloat = inhabitant.state == .curious ? pupilRadius * 0.35 : 0
        let leftPupil = CGRect(
            x: -eyeOffset - pupilRadius + pupilShift,
            y: -size * 0.15 - pupilRadius,
            width: pupilRadius * 2,
            height: pupilRadius * 2
        )
        let rightPupil = CGRect(
            x: eyeOffset - pupilRadius + pupilShift,
            y: -size * 0.15 - pupilRadius,
            width: pupilRadius * 2,
            height: pupilRadius * 2
        )
        layer.fill(Path(ellipseIn: leftPupil), with: .color(Color(red: 0.10, green: 0.10, blue: 0.18)))
        layer.fill(Path(ellipseIn: rightPupil), with: .color(Color(red: 0.10, green: 0.10, blue: 0.18)))
    }

    private func drawBorder(context: inout GraphicsContext, size: CGSize) {
        let border = CGRect(x: 2, y: 2, width: size.width - 4, height: size.height - 4)
        context.stroke(Path(border), with: .color(FlatlandTheme.gold.opacity(0.3)), lineWidth: 2)
    }

    private func map(_ point: SIMD2<Float>, offset: CGPoint, scale: CGFloat) -> CGPoint {
        CGPoint(
            x: offset.x + CGFloat(point.x) * scale,
            y: offset.y + CGFloat(point.y) * scale
        )
    }
}