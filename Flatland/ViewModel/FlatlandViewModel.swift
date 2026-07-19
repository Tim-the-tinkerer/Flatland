import Foundation
import Observation
import simd

@MainActor
@Observable
final class FlatlandViewModel {
    var selectedShape: PassingShape = .sphere
    var height: Float = 0
    var rotateX: Float = 0
    var rotateZ: Float = 0
    var autoSpeed: Float = 0

    var dimensionMode: DimensionMode = .flatland
    var fourDPose = FourDPose()
    var wAutoSpeed: Float = 0
    var fourDWireSegments: [FourDWireSegment] = []
    var fourDSliceMesh = FourDSliceMesh(vertices: [], indices: [])

    var secondApparitionEnabled = false
    var secondShape: PassingShape = .cube
    var secondHeight: Float = -1.2
    var secondRotateX: Float = 20
    var secondRotateZ: Float = 35
    var secondPlaneX: Float = 1.6
    var secondPlaneZ: Float = -1.1

    var currentChapterID: GuidedChapterID = .meetFlatland
    var chapterStepIndex = 0
    var chapterPlaying = false
    var chapterProgress: Double = 0
    var currentQuote = GuidedChapters.chapter(for: .meetFlatland).steps[0].quote
    var currentInsight = GuidedChapters.chapter(for: .meetFlatland).steps[0].insight

    var crossSectionSegments: [CrossSectionSegment] = []
    var crossSectionLayers: [ApparitionCrossSection] = []
    var apparitionCenters: [SIMD2<Float>] = []

    var animatedInhabitants: [AnimatedInhabitant] = []
    var inhabitantHuddleLinks: [(SIMD2<Float>, SIMD2<Float>)] = []

    var demoRunning = false

    private var primaryMeshSlice = ShapeFactory.meshSlice(for: .sphere)
    private var secondaryMeshSlice = ShapeFactory.meshSlice(for: .cube)
    private var primaryWorldTransform = matrix_identity_float4x4
    private var secondaryWorldTransform = matrix_identity_float4x4
    private let inhabitantSimulator = InhabitantSimulator()
    private var chapterTask: Task<Void, Never>?
    private var animationTask: Task<Void, Never>?

    var currentChapter: GuidedChapter {
        GuidedChapters.chapter(for: currentChapterID)
    }

    var primaryPose: ApparitionPose {
        ApparitionPose(
            shape: selectedShape,
            height: height,
            rotateX: rotateX,
            rotateZ: rotateZ,
            planeX: 0,
            planeZ: 0,
            enabled: true
        )
    }

    var secondaryPose: ApparitionPose {
        ApparitionPose(
            shape: secondShape,
            height: secondHeight,
            rotateX: secondRotateX,
            rotateZ: secondRotateZ,
            planeX: secondPlaneX,
            planeZ: secondPlaneZ,
            enabled: secondApparitionEnabled
        )
    }

    func setPrimaryMeshSlice(_ slice: MeshSlice) {
        primaryMeshSlice = slice
        refreshCrossSection()
    }

    func setSecondaryMeshSlice(_ slice: MeshSlice) {
        secondaryMeshSlice = slice
        refreshCrossSection()
    }

    func setWorldTransforms(primary: simd_float4x4, secondary: simd_float4x4?) {
        let primaryChanged = !matricesApproximatelyEqual(primary, primaryWorldTransform)
        let secondaryChanged = secondary.map { !matricesApproximatelyEqual($0, secondaryWorldTransform) } ?? false

        guard primaryChanged || secondaryChanged else { return }

        primaryWorldTransform = primary
        if let secondary {
            secondaryWorldTransform = secondary
        }
        refreshCrossSection()
    }

    func shapeChanged() {
        if !demoRunning && !chapterPlaying {
            currentInsight = FlatlandNarration.insight(for: selectedShape)
        }
        primaryMeshSlice = ShapeFactory.meshSlice(for: selectedShape)
    }

    func secondShapeChanged() {
        secondaryMeshSlice = ShapeFactory.meshSlice(for: secondShape)
    }

    func toggleSecondApparition(_ enabled: Bool) {
        secondApparitionEnabled = enabled
        if enabled {
            currentInsight = "Two shapes cross Flatland at once. The inhabitants see two mysterious figures — never suspecting separate worlds above."
        }
        refreshCrossSection()
    }

    func setDimensionMode(_ mode: DimensionMode) {
        guard dimensionMode != mode else { return }
        dimensionMode = mode
        secondApparitionEnabled = false

        if mode == .fourD {
            currentInsight = "We are the Flatlanders now. A tesseract moves through ana — the fourth axis — and our world catches only a morphing polyhedron."
            refreshFourDScene()
        } else if !demoRunning && !chapterPlaying {
            currentInsight = FlatlandNarration.insight(for: selectedShape)
            refreshCrossSection()
        }
    }

    func refreshFourDScene() {
        let vertices = Hypercube4D.transformedVertices(pose: fourDPose)
        fourDWireSegments = Hypercube4D.projectedWireframe(vertices: vertices)
        fourDSliceMesh = Hypercube4D.sliceMesh(vertices: vertices, pose: fourDPose)
    }

    func runHypercubeDemo() async {
        guard !demoRunning, !chapterPlaying else { return }
        demoRunning = true
        stopChapterPlayback()
        wAutoSpeed = 0
        setDimensionMode(.fourD)

        fourDPose.wPosition = -2.2
        fourDPose.rotateXW = 20
        fourDPose.rotateYW = 10
        fourDPose.rotateZW = 5
        refreshFourDScene()

        currentQuote = "\"A hypercube descends through ana — the fourth dimension. Watch our world catch only a morphing polyhedron.\""
        currentInsight = "The tesseract is whole in four dimensions. We, like Flatlanders, see only what crosses our space."

        await animateFourDScene(
            wPosition: 2.2,
            rotateXW: 45,
            rotateYW: 30,
            rotateZW: 20,
            duration: 5.5
        )

        fourDPose.wPosition = 0
        refreshFourDScene()
        currentInsight = "Now tilt the slice plane — the same hypercube produces wildly different cross-sections."

        await animateFourDScene(
            wPosition: 0,
            rotateXW: fourDPose.rotateXW,
            rotateYW: fourDPose.rotateYW,
            rotateZW: fourDPose.rotateZW,
            sliceTiltXW: 60,
            duration: 2.2
        )
        await animateFourDScene(
            wPosition: 0,
            rotateXW: fourDPose.rotateXW,
            rotateYW: fourDPose.rotateYW,
            rotateZW: fourDPose.rotateZW,
            sliceTiltXW: 0,
            sliceTiltYW: 50,
            sliceTiltZW: 25,
            duration: 2.2
        )
        await animateFourDScene(
            wPosition: 0,
            rotateXW: fourDPose.rotateXW,
            rotateYW: fourDPose.rotateYW,
            rotateZW: fourDPose.rotateZW,
            sliceTiltXW: 0,
            sliceTiltYW: 0,
            sliceTiltZW: 0,
            duration: 1.2
        )

        refreshFourDScene()
        demoRunning = false
    }

    func runDualApparitionDemo() async {
        guard !demoRunning, !chapterPlaying else { return }
        demoRunning = true
        stopChapterPlayback()
        autoSpeed = 0

        selectedShape = .sphere
        secondShape = .cube
        secondApparitionEnabled = true
        secondPlaneX = 1.6
        secondPlaneZ = -1.1
        primaryMeshSlice = ShapeFactory.meshSlice(for: .sphere)
        secondaryMeshSlice = ShapeFactory.meshSlice(for: .cube)

        currentQuote = "\"Two apparitions at once — interacting, converging, frightening the Flatlanders. They could never guess these are separate bodies in a higher space.\""
        currentInsight = "Watch the gold sphere and blue cube pass through different points on the plane."

        height = -2.2
        secondHeight = 1.8
        rotateX = 0
        rotateZ = 0
        secondRotateX = 25
        secondRotateZ = 15

        async let spherePass = animatePrimary(height: 2.2, rotateX: 0, rotateZ: 0, duration: 5)
        async let cubePass = animateSecondary(height: -2.0, rotateX: 35, rotateZ: 45, duration: 5.5)
        _ = await (spherePass, cubePass)

        height = 0
        secondHeight = 0
        demoRunning = false
    }

    func startAnimationLoop() {
        animatedInhabitants = inhabitantSimulator.inhabitants
        animationTask?.cancel()
        animationTask = Task {
            let clock = ContinuousClock()
            while !Task.isCancelled {
                if dimensionMode == .fourD {
                    if wAutoSpeed > 0 && !demoRunning && !chapterPlaying {
                        fourDPose.wPosition += wAutoSpeed * 0.01
                        if fourDPose.wPosition > 2.5 { fourDPose.wPosition = -2.5 }
                        refreshFourDScene()
                    }
                } else if autoSpeed > 0 && !demoRunning && !chapterPlaying {
                    height += autoSpeed * 0.01
                    if height > 2.5 { height = -2.5 }
                }

                if dimensionMode == .flatland {
                    updateInhabitants()
                }
                try? await clock.sleep(for: .milliseconds(16))
            }
        }
    }

    func updateInhabitants(at time: TimeInterval = Date.timeIntervalSinceReferenceDate) {
        inhabitantSimulator.tick(apparitionCenters: apparitionCenters, time: time)
        animatedInhabitants = inhabitantSimulator.inhabitants
        inhabitantHuddleLinks = inhabitantSimulator.huddleLinks()
    }

    func selectChapter(_ chapterID: GuidedChapterID, keepPlayback: Bool = false) {
        if !keepPlayback {
            stopChapterPlayback()
        }
        currentChapterID = chapterID
        chapterStepIndex = 0
        applyChapterPreset(chapterID)
        showChapterStep(at: 0)
    }

    func toggleChapterPlayback() {
        if chapterPlaying {
            stopChapterPlayback()
        } else {
            startChapterPlayback()
        }
    }

    func startChapterPlayback() {
        chapterPlaying = true
        autoSpeed = 0
        chapterTask?.cancel()
        chapterTask = Task {
            await runChapter(currentChapterID, fromStep: chapterStepIndex)
            chapterPlaying = false
            chapterTask = nil
        }
    }

    func stopChapterPlayback() {
        chapterPlaying = false
        chapterTask?.cancel()
        chapterTask = nil
    }

    func runFullGuidedTour() async {
        stopChapterPlayback()
        chapterPlaying = true
        autoSpeed = 0

        for chapterID in GuidedChapterID.allCases {
            guard chapterPlaying else { break }
            selectChapter(chapterID, keepPlayback: true)
            await runChapter(chapterID, fromStep: 0)
        }

        chapterPlaying = false
    }

    func runSaganDemo() async {
        selectChapter(.sphereEncounter)
        await runChapter(.sphereEncounter, fromStep: 0)
    }

    private func runChapter(_ chapterID: GuidedChapterID, fromStep: Int) async {
        demoRunning = true
        let chapter = GuidedChapters.chapter(for: chapterID)
        applyChapterPreset(chapterID)

        let demoTask: Task<Void, Never>? = chapter.demo.isEmpty ? nil : Task {
            await runChapterDemo(chapter.demo)
        }

        for stepIndex in fromStep..<chapter.steps.count {
            guard !Task.isCancelled else { break }
            showChapterStep(at: stepIndex)
            try? await Task.sleep(for: .seconds(8))
        }

        await demoTask?.value
        demoRunning = false
        updateChapterProgress()
    }

    private func runChapterDemo(_ steps: [ChapterDemoStep]) async {
        let isFourD = currentChapter.dimensionMode == .fourD
        for step in steps {
            guard !Task.isCancelled else { break }
            if isFourD {
                await animateFourDScene(
                    wPosition: step.wPosition,
                    rotateXW: step.rotateXW,
                    rotateYW: step.rotateYW,
                    rotateZW: step.rotateZW,
                    sliceTiltXW: step.sliceTiltXW,
                    sliceTiltYW: step.sliceTiltYW,
                    sliceTiltZW: step.sliceTiltZW,
                    duration: step.duration
                )
            } else {
                await animateScene(
                    height: step.height,
                    rotateX: step.rotateX,
                    rotateZ: step.rotateZ,
                    duration: step.duration
                )
            }
            if step.pause > .zero {
                try? await Task.sleep(for: step.pause)
            }
        }
    }

    private func applyChapterPreset(_ chapterID: GuidedChapterID) {
        let chapter = GuidedChapters.chapter(for: chapterID)
        setDimensionMode(chapter.dimensionMode)
        selectedShape = chapter.shape
        primaryMeshSlice = ShapeFactory.meshSlice(for: chapter.shape)
        secondApparitionEnabled = false

        switch chapterID {
        case .meetFlatland:
            height = 2.5
            rotateX = 0
            rotateZ = 0
        case .sphereEncounter, .areWeFlatlanders:
            height = -2.2
            rotateX = 0
            rotateZ = 0
        case .cubeEncounter:
            height = -1.8
            rotateX = 0
            rotateZ = 0
        case .fourthDimension:
            fourDPose = FourDPose(wPosition: -2.0, rotateXW: 20, rotateYW: 10, rotateZW: 5)
            refreshFourDScene()
        }
    }

    private func showChapterStep(at index: Int) {
        let chapter = currentChapter
        guard chapter.steps.indices.contains(index) else { return }
        let step = chapter.steps[index]
        currentQuote = step.quote
        currentInsight = step.insight
        chapterStepIndex = index
        updateChapterProgress()
    }

    private func updateChapterProgress() {
        let chapter = currentChapter
        let chapterFraction = chapter.stepCount > 0
            ? Double(chapterStepIndex + 1) / Double(chapter.stepCount)
            : 0
        let base = Double(currentChapterID.rawValue) / Double(GuidedChapterID.allCases.count)
        chapterProgress = base + chapterFraction / Double(GuidedChapterID.allCases.count)
    }

    private func animateScene(
        height targetHeight: Float,
        rotateX targetRotateX: Float,
        rotateZ targetRotateZ: Float,
        duration: TimeInterval
    ) async {
        let startHeight = height
        let startRotateX = rotateX
        let startRotateZ = rotateZ
        let startTime = ContinuousClock.now

        while true {
            let elapsed = startTime.duration(to: ContinuousClock.now)
            let seconds = Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
            let progress = min(seconds / duration, 1)
            let eased = progress < 0.5
                ? 2 * progress * progress
                : 1 - pow(-2 * progress + 2, 2) / 2

            height = startHeight + (targetHeight - startHeight) * Float(eased)
            rotateX = startRotateX + (targetRotateX - startRotateX) * Float(eased)
            rotateZ = startRotateZ + (targetRotateZ - startRotateZ) * Float(eased)

            if progress >= 1 { break }
            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private func refreshCrossSection() {
        let primarySegments = CrossSectionCalculator.compute(mesh: primaryMeshSlice, transform: primaryWorldTransform)
        let primaryPolygons = CrossSectionCalculator.polygons(from: primarySegments)
        let primaryCenter = CrossSectionCalculator.apparitionCenter(from: primarySegments, polygons: primaryPolygons)

        var layers: [ApparitionCrossSection] = [
            ApparitionCrossSection(
                id: .primary,
                segments: primarySegments,
                polygons: primaryPolygons,
                center: primaryCenter
            ),
        ]

        var centers: [SIMD2<Float>] = []
        if let primaryCenter { centers.append(primaryCenter) }

        if secondApparitionEnabled {
            let secondarySegments = CrossSectionCalculator.compute(mesh: secondaryMeshSlice, transform: secondaryWorldTransform)
            let secondaryPolygons = CrossSectionCalculator.polygons(from: secondarySegments)
            let secondaryCenter = CrossSectionCalculator.apparitionCenter(from: secondarySegments, polygons: secondaryPolygons)

            layers.append(
                ApparitionCrossSection(
                    id: .secondary,
                    segments: secondarySegments,
                    polygons: secondaryPolygons,
                    center: secondaryCenter
                )
            )
            if let secondaryCenter { centers.append(secondaryCenter) }
        }

        crossSectionLayers = layers
        crossSectionSegments = layers.flatMap(\.segments)
        apparitionCenters = centers
        updateInhabitants()
    }

    private func animatePrimary(height targetHeight: Float, rotateX targetRotateX: Float, rotateZ targetRotateZ: Float, duration: TimeInterval) async {
        await animateValues(
            duration: duration,
            height: (height, targetHeight),
            rotateX: (rotateX, targetRotateX),
            rotateZ: (rotateZ, targetRotateZ),
            apply: { h, rx, rz in
                height = h
                rotateX = rx
                rotateZ = rz
            }
        )
    }

    private func animateFourDScene(
        wPosition targetW: Float,
        rotateXW targetRotateXW: Float,
        rotateYW targetRotateYW: Float,
        rotateZW targetRotateZW: Float,
        sliceTiltXW targetSliceTiltXW: Float? = nil,
        sliceTiltYW targetSliceTiltYW: Float? = nil,
        sliceTiltZW targetSliceTiltZW: Float? = nil,
        duration: TimeInterval
    ) async {
        let startW = fourDPose.wPosition
        let startRotateXW = fourDPose.rotateXW
        let startRotateYW = fourDPose.rotateYW
        let startRotateZW = fourDPose.rotateZW
        let startSliceTiltXW = fourDPose.sliceTiltXW
        let startSliceTiltYW = fourDPose.sliceTiltYW
        let startSliceTiltZW = fourDPose.sliceTiltZW
        let endSliceTiltXW = targetSliceTiltXW ?? startSliceTiltXW
        let endSliceTiltYW = targetSliceTiltYW ?? startSliceTiltYW
        let endSliceTiltZW = targetSliceTiltZW ?? startSliceTiltZW
        let startTime = ContinuousClock.now

        while true {
            let elapsed = startTime.duration(to: ContinuousClock.now)
            let seconds = Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
            let progress = min(seconds / duration, 1)
            let eased = progress < 0.5
                ? 2 * progress * progress
                : 1 - pow(-2 * progress + 2, 2) / 2

            fourDPose.wPosition = startW + (targetW - startW) * Float(eased)
            fourDPose.rotateXW = startRotateXW + (targetRotateXW - startRotateXW) * Float(eased)
            fourDPose.rotateYW = startRotateYW + (targetRotateYW - startRotateYW) * Float(eased)
            fourDPose.rotateZW = startRotateZW + (targetRotateZW - startRotateZW) * Float(eased)
            fourDPose.sliceTiltXW = startSliceTiltXW + (endSliceTiltXW - startSliceTiltXW) * Float(eased)
            fourDPose.sliceTiltYW = startSliceTiltYW + (endSliceTiltYW - startSliceTiltYW) * Float(eased)
            fourDPose.sliceTiltZW = startSliceTiltZW + (endSliceTiltZW - startSliceTiltZW) * Float(eased)
            refreshFourDScene()

            if progress >= 1 { break }
            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private func animateSecondary(height targetHeight: Float, rotateX targetRotateX: Float, rotateZ targetRotateZ: Float, duration: TimeInterval) async {
        await animateValues(
            duration: duration,
            height: (secondHeight, targetHeight),
            rotateX: (secondRotateX, targetRotateX),
            rotateZ: (secondRotateZ, targetRotateZ),
            apply: { h, rx, rz in
                secondHeight = h
                secondRotateX = rx
                secondRotateZ = rz
            }
        )
    }

    private func animateValues(
        duration: TimeInterval,
        height: (Float, Float),
        rotateX: (Float, Float),
        rotateZ: (Float, Float),
        apply: (Float, Float, Float) -> Void
    ) async {
        let startTime = ContinuousClock.now

        while true {
            let elapsed = startTime.duration(to: ContinuousClock.now)
            let seconds = Double(elapsed.components.seconds) + Double(elapsed.components.attoseconds) / 1e18
            let progress = min(seconds / duration, 1)
            let eased = progress < 0.5
                ? 2 * progress * progress
                : 1 - pow(-2 * progress + 2, 2) / 2

            apply(
                height.0 + (height.1 - height.0) * Float(eased),
                rotateX.0 + (rotateX.1 - rotateX.0) * Float(eased),
                rotateZ.0 + (rotateZ.1 - rotateZ.0) * Float(eased)
            )

            if progress >= 1 { break }
            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private func matricesApproximatelyEqual(_ lhs: simd_float4x4, _ rhs: simd_float4x4, epsilon: Float = 0.0001) -> Bool {
        let delta = lhs - rhs
        return abs(delta.columns.0.x) < epsilon
            && abs(delta.columns.0.y) < epsilon
            && abs(delta.columns.0.z) < epsilon
            && abs(delta.columns.1.x) < epsilon
            && abs(delta.columns.1.y) < epsilon
            && abs(delta.columns.1.z) < epsilon
            && abs(delta.columns.2.x) < epsilon
            && abs(delta.columns.2.y) < epsilon
            && abs(delta.columns.2.z) < epsilon
            && abs(delta.columns.3.x) < epsilon
            && abs(delta.columns.3.y) < epsilon
            && abs(delta.columns.3.z) < epsilon
    }
}