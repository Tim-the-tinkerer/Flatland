import SwiftUI

struct GuidedChaptersBar: View {
    let currentChapterID: GuidedChapterID
    let chapterPlaying: Bool
    let stepIndex: Int
    let onSelect: (GuidedChapterID) -> Void
    let onPlayPause: () -> Void

    private var currentChapter: GuidedChapter {
        GuidedChapters.chapter(for: currentChapterID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chapter \(currentChapter.id.number) · \(currentChapter.title)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(FlatlandTheme.gold)
                    Text(currentChapter.subtitle)
                        .font(.system(size: 12, design: .serif))
                        .italic()
                        .foregroundStyle(FlatlandTheme.textMuted)
                }

                Spacer()

                Button(action: onPlayPause) {
                    Label(
                        chapterPlaying ? "Pause" : "Play Chapter",
                        systemImage: chapterPlaying ? "pause.fill" : "play.fill"
                    )
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                .buttonStyle(FlatlandButtonStyle())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(GuidedChapterID.allCases) { chapterID in
                        ChapterChip(
                            chapter: GuidedChapters.chapter(for: chapterID),
                            isSelected: chapterID == currentChapterID,
                            action: { onSelect(chapterID) }
                        )
                    }
                }
            }

            HStack(spacing: 4) {
                ForEach(0..<currentChapter.stepCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= stepIndex ? FlatlandTheme.gold : FlatlandTheme.gold.opacity(0.18))
                        .frame(height: 3)
                }
            }
        }
    }
}

private struct ChapterChip: View {
    let chapter: GuidedChapter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(chapter.id.number)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(isSelected ? FlatlandTheme.background : FlatlandTheme.goldDim)
                Text(chapter.title)
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .foregroundStyle(isSelected ? FlatlandTheme.background : FlatlandTheme.textMuted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? FlatlandTheme.gold : Color.black.opacity(0.2))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(FlatlandTheme.gold.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GuidedChaptersBar(
        currentChapterID: .sphereEncounter,
        chapterPlaying: false,
        stepIndex: 1,
        onSelect: { _ in },
        onPlayPause: {}
    )
    .padding()
    .background(FlatlandTheme.background)
}