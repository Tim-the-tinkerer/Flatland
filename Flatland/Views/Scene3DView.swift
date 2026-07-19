import AppKit
import SceneKit
import SwiftUI
import simd

struct Scene3DView: NSViewRepresentable {
    let primary: ApparitionPose
    let secondary: ApparitionPose
    let segments: [CrossSectionSegment]
    let onPrimaryMeshUpdated: (MeshSlice) -> Void
    let onSecondaryMeshUpdated: (MeshSlice) -> Void
    let onTransformsUpdated: (_ primary: simd_float4x4, _ secondary: simd_float4x4?) -> Void

    func makeNSView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.backgroundColor = NSColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
        view.allowsCameraControl = true
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.rendersContinuously = true
        view.isPlaying = true
        view.pointOfView = context.coordinator.cameraNode
        context.coordinator.configureIfNeeded()
        context.coordinator.sync(primary: primary, secondary: secondary, onPrimaryMeshUpdated: onPrimaryMeshUpdated, onSecondaryMeshUpdated: onSecondaryMeshUpdated)
        context.coordinator.publishTransforms(secondaryEnabled: secondary.enabled, onTransformsUpdated: onTransformsUpdated)
        return view
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.rendersContinuously = true
        nsView.isPlaying = true
        context.coordinator.sync(primary: primary, secondary: secondary, onPrimaryMeshUpdated: onPrimaryMeshUpdated, onSecondaryMeshUpdated: onSecondaryMeshUpdated)
        context.coordinator.updateSectionLines(segments)
        context.coordinator.publishTransforms(secondaryEnabled: secondary.enabled, onTransformsUpdated: onTransformsUpdated)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        let scene = SCNScene()
        let primaryNode = SCNNode()
        let secondaryNode = SCNNode()
        let cameraNode = SCNNode()
        let sectionNode = SCNNode()

        private var primaryShape: PassingShape?
        private var secondaryShape: PassingShape?
        private var primaryMeshNode: SCNNode?
        private var secondaryMeshNode: SCNNode?

        func configureIfNeeded() {
            guard scene.rootNode.childNodes.isEmpty else { return }

            let camera = SCNCamera()
            camera.zFar = 100
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(4, 3.5, 4)
            cameraNode.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(cameraNode)

            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.color = NSColor(white: 0.35, alpha: 1)
            scene.rootNode.addChildNode(ambient)

            let keyLight = SCNNode()
            keyLight.light = SCNLight()
            keyLight.light?.type = .directional
            keyLight.light?.color = NSColor(red: 1.0, green: 0.96, blue: 0.88, alpha: 1)
            keyLight.light?.castsShadow = true
            keyLight.position = SCNVector3(5, 8, 3)
            keyLight.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(keyLight)

            let fillLight = SCNNode()
            fillLight.light = SCNLight()
            fillLight.light?.type = .directional
            fillLight.light?.color = NSColor(red: 0.29, green: 0.49, blue: 0.71, alpha: 1)
            fillLight.position = SCNVector3(-3, 2, -4)
            fillLight.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(fillLight)

            let plane = SCNPlane(width: 8, height: 8)
            plane.firstMaterial?.diffuse.contents = NSColor(red: 0.18, green: 0.35, blue: 0.24, alpha: 1)
            plane.firstMaterial?.roughness.contents = 0.85
            plane.firstMaterial?.isDoubleSided = true
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.position = SCNVector3(0, 0.001, 0)
            scene.rootNode.addChildNode(planeNode)

            scene.rootNode.addChildNode(primaryNode)
            scene.rootNode.addChildNode(secondaryNode)
            scene.rootNode.addChildNode(sectionNode)
        }

        func sync(
            primary: ApparitionPose,
            secondary: ApparitionPose,
            onPrimaryMeshUpdated: (MeshSlice) -> Void,
            onSecondaryMeshUpdated: (MeshSlice) -> Void
        ) {
            updateSlot(
                node: primaryNode,
                meshNode: &primaryMeshNode,
                currentShape: &primaryShape,
                pose: primary,
                material: ShapeFactory.material(),
                onMeshUpdated: onPrimaryMeshUpdated
            )

            updateSlot(
                node: secondaryNode,
                meshNode: &secondaryMeshNode,
                currentShape: &secondaryShape,
                pose: secondary,
                material: ShapeFactory.secondaryMaterial(),
                onMeshUpdated: onSecondaryMeshUpdated
            )

            secondaryNode.isHidden = !secondary.enabled
        }

        private func updateSlot(
            node: SCNNode,
            meshNode: inout SCNNode?,
            currentShape: inout PassingShape?,
            pose: ApparitionPose,
            material: SCNMaterial,
            onMeshUpdated: (MeshSlice) -> Void
        ) {
            if currentShape != pose.shape {
                currentShape = pose.shape
                meshNode?.removeFromParentNode()

                let geometry = ShapeFactory.geometry(for: pose.shape)
                geometry.firstMaterial = material
                let newMesh = SCNNode(geometry: geometry)
                node.addChildNode(newMesh)
                meshNode = newMesh
                onMeshUpdated(ShapeFactory.meshSlice(for: pose.shape))
            }

            node.position = SCNVector3(pose.planeX, pose.height, pose.planeZ)
            node.eulerAngles = SCNVector3(
                CGFloat(pose.rotateX) * .pi / 180,
                0,
                CGFloat(pose.rotateZ) * .pi / 180
            )
            node.isHidden = !pose.enabled
        }

        func publishTransforms(secondaryEnabled: Bool, onTransformsUpdated: (_ primary: simd_float4x4, _ secondary: simd_float4x4?) -> Void) {
            let secondaryTransform = secondaryEnabled ? simd_float4x4(secondaryNode.simdWorldTransform) : nil
            onTransformsUpdated(simd_float4x4(primaryNode.simdWorldTransform), secondaryTransform)
        }

        func updateSectionLines(_ segments: [CrossSectionSegment]) {
            sectionNode.childNodes.forEach { $0.removeFromParentNode() }
            guard !segments.isEmpty else { return }

            var vertices: [SCNVector3] = []
            for segment in segments {
                vertices.append(SCNVector3(segment.start.x, 0.01, segment.start.y))
                vertices.append(SCNVector3(segment.end.x, 0.01, segment.end.y))
            }

            let source = SCNGeometrySource(vertices: vertices)
            var indices: [Int32] = []
            for index in 0..<segments.count {
                let base = Int32(index * 2)
                indices.append(contentsOf: [base, base + 1])
            }

            let element = SCNGeometryElement(indices: indices, primitiveType: .line)
            let geometry = SCNGeometry(sources: [source], elements: [element])
            geometry.firstMaterial?.diffuse.contents = NSColor(red: 0.83, green: 0.69, blue: 0.37, alpha: 1)
            geometry.firstMaterial?.emission.contents = NSColor(red: 0.83, green: 0.69, blue: 0.37, alpha: 0.4)
            sectionNode.addChildNode(SCNNode(geometry: geometry))
        }
    }
}