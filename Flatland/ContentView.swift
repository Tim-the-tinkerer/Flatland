import SwiftUI

struct ContentView: View {
    @Binding var showingHelp: Bool
    @State private var model = FlatlandViewModel()

    init(showingHelp: Binding<Bool> = .constant(false)) {
        _showingHelp = showingHelp
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            VStack(spacing: 0) {
                header
                viewportRow(time: timeline.date.timeIntervalSinceReferenceDate)
                narrationSection
                controlsSection
                insightSection
            }
            .background(FlatlandTheme.background)
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .onAppear {
            model.refreshCrossSectionOnAppear()
            model.startAnimationLoop()
        }
        .onChange(of: model.selectedShape) { _, _ in model.shapeChanged() }
        .onChange(of: model.secondShape) { _, _ in model.secondShapeChanged() }
        .onChange(of: model.secondApparitionEnabled) { _, enabled in model.toggleSecondApparition(enabled) }
        .onChange(of: model.fourDPose.wPosition) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.rotateXW) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.rotateYW) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.rotateZW) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.rotateXY) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.sliceTiltXW) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.sliceTiltYW) { _, _ in model.refreshFourDScene() }
        .onChange(of: model.fourDPose.sliceTiltZW) { _, _ in model.refreshFourDScene() }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Inspired by Carl Sagan's Cosmos")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(FlatlandTheme.goldDim)
                    .textCase(.uppercase)
                    .kerning(1.5)

                Text("Flatland")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(FlatlandTheme.gold)

                Text("A journey into the hidden dimensions")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(FlatlandTheme.textMuted)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    model.setDimensionMode(model.dimensionMode == .fourD ? .flatland : .fourD)
                } label: {
                    Label("4D Mode", systemImage: "cube.transparent")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
                .buttonStyle(FourDButtonStyle(isActive: model.dimensionMode == .fourD))
                .disabled(model.demoRunning || model.chapterPlaying)

                Button {
                    Task { await model.runFullGuidedTour() }
                } label: {
                    Label("Full Tour", systemImage: "sparkles")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
                .buttonStyle(FlatlandButtonStyle())
                .disabled(model.demoRunning || model.chapterPlaying)

                Button {
                    showingHelp = true
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
                .buttonStyle(FlatlandButtonStyle())
                .help("Open Flatland Help")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(FlatlandTheme.panel)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FlatlandTheme.gold.opacity(0.25))
                .frame(height: 1)
        }
    }

    private func viewportRow(time: TimeInterval) -> some View {
        HStack(spacing: 1) {
            if model.dimensionMode == .fourD {
                ViewportPanel(
                    title: "Beyond our space",
                    subtitle: "A hypercube passes through our three-dimensional universe",
                    badge: "4D",
                    accent: FlatlandTheme.accentViolet
                ) {
                    FourDSceneView(
                        pose: model.fourDPose,
                        wireSegments: model.fourDWireSegments
                    )
                    .frame(minHeight: 300)
                }

                ViewportPanel(
                    title: "Our world",
                    subtitle: "We see only a changing polyhedron — a shadow of the truth",
                    badge: "3D",
                    accent: FlatlandTheme.accentViolet
                ) {
                    Slice3DView(mesh: model.fourDSliceMesh)
                        .frame(minHeight: 300)
                }
            } else {
                ViewportPanel(
                    title: "Our perspective",
                    subtitle: "We see the full shape passing through Flatland",
                    badge: "3D"
                ) {
                    Scene3DView(
                        primary: model.primaryPose,
                        secondary: model.secondaryPose,
                        segments: model.crossSectionSegments,
                        onPrimaryMeshUpdated: { model.setPrimaryMeshSlice($0) },
                        onSecondaryMeshUpdated: { model.setSecondaryMeshSlice($0) },
                        onTransformsUpdated: { model.setWorldTransforms(primary: $0, secondary: $1) }
                    )
                    .frame(minHeight: 300)
                }

                ViewportPanel(
                    title: "Flatland",
                    subtitle: "They see only a cross-section — a shadow of the truth",
                    badge: "2D"
                ) {
                    Flatland2DView(
                        layers: model.crossSectionLayers,
                        inhabitants: model.animatedInhabitants,
                        huddleLinks: model.inhabitantHuddleLinks,
                        time: time
                    )
                }
            }
        }
        .frame(minHeight: 380)
        .background(
            model.dimensionMode == .fourD
                ? FlatlandTheme.accentViolet.opacity(0.25)
                : FlatlandTheme.gold.opacity(0.25)
        )
    }

    private var narrationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            GuidedChaptersBar(
                currentChapterID: model.currentChapterID,
                chapterPlaying: model.chapterPlaying,
                stepIndex: model.chapterStepIndex,
                onSelect: { model.selectChapter($0) },
                onPlayPause: { model.toggleChapterPlayback() }
            )

            Text(model.currentQuote)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(FlatlandTheme.text)
                .fixedSize(horizontal: false, vertical: true)

            Text("— Carl Sagan, Cosmos")
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(FlatlandTheme.goldDim)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(FlatlandTheme.gold.opacity(0.15))
                    Capsule()
                        .fill(FlatlandTheme.gold)
                        .frame(width: geometry.size.width * model.chapterProgress)
                }
            }
            .frame(height: 2)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(FlatlandTheme.panel)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FlatlandTheme.gold.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 0) {
            if model.dimensionMode == .fourD {
                fourDControlsSection
            } else {
                flatlandControlsSection
                secondApparitionControls
            }
        }
    }

    private var flatlandControlsSection: some View {
        HStack(alignment: .bottom, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Passing through")
                    .controlLabelStyle()
                Picker("Shape", selection: $model.selectedShape) {
                    ForEach(PassingShape.allCases) { shape in
                        Text(shape.label).tag(shape)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 160)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Height through plane")
                        .controlLabelStyle()
                    Spacer()
                    Text(String(format: "%.2f", model.height))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(FlatlandTheme.gold)
                }
                Slider(value: $model.height, in: -2.5...2.5)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 6) {
                Text("Tilt X")
                    .controlLabelStyle()
                Slider(value: Binding(
                    get: { Double(model.rotateX) },
                    set: { model.rotateX = Float($0) }
                ), in: 0...360)
            }
            .frame(width: 150)

            VStack(alignment: .leading, spacing: 6) {
                Text("Tilt Z")
                    .controlLabelStyle()
                Slider(value: Binding(
                    get: { Double(model.rotateZ) },
                    set: { model.rotateZ = Float($0) }
                ), in: 0...360)
            }
            .frame(width: 150)

            VStack(alignment: .leading, spacing: 6) {
                Text("Auto-pass speed")
                    .controlLabelStyle()
                Slider(value: $model.autoSpeed, in: 0...3)
            }
            .frame(width: 140)

            Button {
                Task { await model.runSaganDemo() }
            } label: {
                Text("Sphere Chapter")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .buttonStyle(DemoButtonStyle())
            .disabled(model.demoRunning || model.chapterPlaying)

            Button {
                Task { await model.runDualApparitionDemo() }
            } label: {
                Text("Dual Apparitions")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .buttonStyle(DemoButtonStyle())
            .disabled(model.demoRunning || model.chapterPlaying)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(FlatlandTheme.panel)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FlatlandTheme.gold.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var fourDControlsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("W through our space")
                            .controlLabelStyle()
                        Spacer()
                        Text(String(format: "%.2f", model.fourDPose.wPosition))
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(FlatlandTheme.accentViolet)
                    }
                    Slider(value: $model.fourDPose.wPosition, in: -2.5...2.5)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tilt XW")
                        .controlLabelStyle()
                    Slider(value: $model.fourDPose.rotateXW, in: 0...360)
                }
                .frame(width: 130)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tilt YW")
                        .controlLabelStyle()
                    Slider(value: $model.fourDPose.rotateYW, in: 0...360)
                }
                .frame(width: 130)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tilt ZW")
                        .controlLabelStyle()
                    Slider(value: $model.fourDPose.rotateZW, in: 0...360)
                }
                .frame(width: 130)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Auto-pass W")
                        .controlLabelStyle()
                    Slider(value: $model.wAutoSpeed, in: 0...3)
                }
                .frame(width: 130)

                Button {
                    Task { await model.runHypercubeDemo() }
                } label: {
                    Text("Hypercube Pass")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                .buttonStyle(VioletDemoButtonStyle())
                .disabled(model.demoRunning || model.chapterPlaying)
            }

            HStack(alignment: .bottom, spacing: 20) {
                Text("Slice plane")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(FlatlandTheme.accentViolet)
                    .frame(width: 90, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Slice XW")
                        .controlLabelStyle()
                    Slider(value: $model.fourDPose.sliceTiltXW, in: 0...75)
                }
                .frame(width: 150)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Slice YW")
                        .controlLabelStyle()
                    Slider(value: $model.fourDPose.sliceTiltYW, in: 0...75)
                }
                .frame(width: 150)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Slice ZW")
                        .controlLabelStyle()
                    Slider(value: $model.fourDPose.sliceTiltZW, in: 0...75)
                }
                .frame(width: 150)

                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(FlatlandTheme.panel.opacity(0.92))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FlatlandTheme.accentViolet.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var secondApparitionControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $model.secondApparitionEnabled) {
                Text("Second apparition")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(FlatlandTheme.accentBlue)
            }
            .toggleStyle(.switch)

            if model.secondApparitionEnabled {
                HStack(alignment: .bottom, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Shape B")
                            .controlLabelStyle()
                        Picker("Second shape", selection: $model.secondShape) {
                            ForEach(PassingShape.allCases) { shape in
                                Text(shape.label).tag(shape)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(width: 140)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Height B")
                                .controlLabelStyle()
                            Spacer()
                            Text(String(format: "%.2f", model.secondHeight))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(FlatlandTheme.accentBlue)
                        }
                        Slider(value: $model.secondHeight, in: -2.5...2.5)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Plane X")
                            .controlLabelStyle()
                        Slider(value: $model.secondPlaneX, in: -2.5...2.5)
                    }
                    .frame(width: 130)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Plane Z")
                            .controlLabelStyle()
                        Slider(value: $model.secondPlaneZ, in: -2.5...2.5)
                    }
                    .frame(width: 130)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tilt X")
                            .controlLabelStyle()
                        Slider(value: Binding(
                            get: { Double(model.secondRotateX) },
                            set: { model.secondRotateX = Float($0) }
                        ), in: 0...360)
                    }
                    .frame(width: 120)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tilt Z")
                            .controlLabelStyle()
                        Slider(value: Binding(
                            get: { Double(model.secondRotateZ) },
                            set: { model.secondRotateZ = Float($0) }
                        ), in: 0...360)
                    }
                    .frame(width: 120)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(FlatlandTheme.panel.opacity(0.7))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FlatlandTheme.gold.opacity(0.25))
                .frame(height: 1)
        }
    }

    private var insightSection: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 16) {
                InsightCard(
                    title: "What Flatlanders perceive",
                    message: model.currentInsight
                )
                InsightCard(
                    title: "The deeper lesson",
                    message: "Just as Flatlanders cannot imagine a third dimension, we may be blind to a fourth. What wonders pass through our world unseen?"
                )
            }

            FlatlandSocietyView()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}

private struct ViewportPanel<Content: View>: View {
    let title: String
    let subtitle: String
    let badge: String
    var accent: Color = FlatlandTheme.gold
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(accent)
                    Text(subtitle)
                        .font(.system(size: 13, design: .serif))
                        .italic()
                        .foregroundStyle(FlatlandTheme.textMuted)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(FlatlandTheme.panel)

            Text(badge)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(FlatlandTheme.textMuted.opacity(0.5))
                .kerning(2)
                .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct InsightCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(FlatlandTheme.gold)
            Text(message)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(FlatlandTheme.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.2))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(FlatlandTheme.gold.opacity(0.25), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct FlatlandButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(FlatlandTheme.gold.opacity(configuration.isPressed ? 0.2 : 0.1))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(FlatlandTheme.gold.opacity(0.35), lineWidth: 1)
            }
            .foregroundStyle(FlatlandTheme.gold)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct DemoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(FlatlandTheme.accentBlue.opacity(configuration.isPressed ? 0.25 : 0.12))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(FlatlandTheme.accentBlue.opacity(0.35), lineWidth: 1)
            }
            .foregroundStyle(FlatlandTheme.accentBlue)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct FourDButtonStyle: ButtonStyle {
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(FlatlandTheme.accentViolet.opacity(isActive ? 0.28 : configuration.isPressed ? 0.2 : 0.12))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(FlatlandTheme.accentViolet.opacity(isActive ? 0.65 : 0.35), lineWidth: 1)
            }
            .foregroundStyle(isActive ? FlatlandTheme.accentViolet.opacity(0.95) : FlatlandTheme.accentViolet)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct VioletDemoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(FlatlandTheme.accentViolet.opacity(configuration.isPressed ? 0.25 : 0.12))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(FlatlandTheme.accentViolet.opacity(0.35), lineWidth: 1)
            }
            .foregroundStyle(FlatlandTheme.accentViolet)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private extension Text {
    func controlLabelStyle() -> some View {
        font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundStyle(FlatlandTheme.textMuted)
            .textCase(.uppercase)
            .kerning(1)
    }
}

private extension FlatlandViewModel {
    func refreshCrossSectionOnAppear() {
        setPrimaryMeshSlice(ShapeFactory.meshSlice(for: selectedShape))
        setSecondaryMeshSlice(ShapeFactory.meshSlice(for: secondShape))
        selectChapter(.meetFlatland)
    }
}

#Preview {
    ContentView(showingHelp: .constant(false))
        .frame(width: 1200, height: 820)
}