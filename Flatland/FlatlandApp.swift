import SwiftUI

@main
struct FlatlandApp: App {
    @State private var showingHelp = false

    var body: some Scene {
        WindowGroup {
            ContentView(showingHelp: $showingHelp)
                .frame(minWidth: 1100, minHeight: 780)
        }
        .defaultSize(width: 1200, height: 860)
        .commands {
            CommandGroup(replacing: .help) {
                Button("Flatland Help") {
                    showingHelp = true
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
    }
}
