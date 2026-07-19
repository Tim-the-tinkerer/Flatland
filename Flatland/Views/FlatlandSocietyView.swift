import SwiftUI

struct FlatlandSocietyView: View {
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(FlatlandSociety.attribution)
                .font(.system(size: 11, design: .serif))
                .italic()
                .foregroundStyle(FlatlandTheme.textMuted)
                .padding(.top, 4)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 6
            ) {
                ForEach(FlatlandSociety.hierarchy) { caste in
                    SocietyChip(caste: caste, showNote: true)
                }
            }
            .padding(.top, 4)
        } label: {
            HStack(spacing: 10) {
                Text("Abbott's Society")
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .foregroundStyle(FlatlandTheme.gold)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FlatlandSociety.hierarchy) { caste in
                            SocietyChip(caste: caste, showNote: false)
                        }
                    }
                }

                Spacer(minLength: 0)

                Text("1884")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(FlatlandTheme.goldDim)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.2))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(FlatlandTheme.gold.opacity(0.2), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

private struct SocietyChip: View {
    let caste: FlatlandCaste
    let showNote: Bool

    var body: some View {
        HStack(spacing: 5) {
            SocietyGlyph(caste: caste)
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(caste.title) · \(caste.shapeLabel)")
                    .font(.system(size: showNote ? 10 : 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(showNote ? FlatlandTheme.text : FlatlandTheme.goldDim)
                    .lineLimit(1)

                if showNote {
                    Text(caste.abbottNote)
                        .font(.system(size: 9, design: .serif))
                        .foregroundStyle(FlatlandTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct SocietyGlyph: View {
    let caste: FlatlandCaste

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let glyphSize = min(size.width, size.height) * 0.42

            context.drawLayer { layer in
                layer.translateBy(x: center.x, y: center.y)

                switch caste.kind {
                case .line:
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: -glyphSize * 1.2))
                    path.addLine(to: CGPoint(x: 0, y: glyphSize * 1.2))
                    layer.stroke(path, with: .color(Color(red: 0.78, green: 0.45, blue: 0.58)), lineWidth: 2)
                    layer.fill(Path(ellipseIn: CGRect(x: -1.5, y: -1.5, width: 3, height: 3)), with: .color(.white))

                case .triangle:
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: -glyphSize))
                    path.addLine(to: CGPoint(x: glyphSize * 0.9, y: glyphSize))
                    path.addLine(to: CGPoint(x: -glyphSize * 0.5, y: glyphSize * 0.8))
                    path.closeSubpath()
                    layer.fill(path, with: .color(Color(red: 0.35, green: 0.56, blue: 0.43)))

                case .square:
                    let rect = CGRect(x: -glyphSize, y: -glyphSize, width: glyphSize * 2, height: glyphSize * 2)
                    layer.fill(Path(rect), with: .color(Color(red: 0.77, green: 0.36, blue: 0.29)))

                case .hexagon:
                    var path = Path()
                    for index in 0..<6 {
                        let angle = (CGFloat(index) * 2 * .pi / 6) - .pi / 2
                        let point = CGPoint(x: cos(angle) * glyphSize, y: sin(angle) * glyphSize)
                        if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
                    }
                    path.closeSubpath()
                    layer.fill(path, with: .color(Color(red: 0.72, green: 0.53, blue: 0.29)))

                case .circle:
                    layer.fill(
                        Path(ellipseIn: CGRect(x: -glyphSize, y: -glyphSize, width: glyphSize * 2, height: glyphSize * 2)),
                        with: .color(Color(red: 0.48, green: 0.42, blue: 0.62))
                    )
                }
            }
        }
    }
}

#Preview {
    FlatlandSocietyView()
        .frame(width: 700)
        .padding()
        .background(FlatlandTheme.background)
}