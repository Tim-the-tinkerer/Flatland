import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(HelpContent.intro)
                        .font(.system(size: 15, design: .serif))
                        .foregroundStyle(FlatlandTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(HelpContent.sections) { section in
                        sectionBlock(section)
                    }

                    Text(HelpContent.closing)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(FlatlandTheme.gold)
                        .padding(.top, 4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(28)
            }
        }
        .frame(minWidth: 520, idealWidth: 560, minHeight: 480, idealHeight: 640)
        .background(FlatlandTheme.background)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(HelpContent.title)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(FlatlandTheme.gold)
                Text(HelpContent.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(FlatlandTheme.textMuted)
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(FlatlandButtonStyle())
            .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .background(FlatlandTheme.panel)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FlatlandTheme.gold.opacity(0.25))
                .frame(height: 1)
        }
    }

    private func sectionBlock(_ section: HelpSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(section.title, systemImage: section.symbol)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(FlatlandTheme.gold)
                .labelStyle(.titleAndIcon)

            ForEach(Array(section.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(FlatlandTheme.text.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !section.rows.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(section.rows.enumerated()), id: \.offset) { _, row in
                        HStack(alignment: .top, spacing: 12) {
                            Text(row.label)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(FlatlandTheme.accentViolet)
                                .frame(width: 150, alignment: .leading)
                            Text(row.detail)
                                .font(.system(size: 13, design: .serif))
                                .foregroundStyle(FlatlandTheme.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.22))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(FlatlandTheme.gold.opacity(0.18), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}

#Preview {
    HelpView()
}
