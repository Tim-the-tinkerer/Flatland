import AppKit
import SceneKit
import SwiftUI

struct FourDSceneView: NSViewRepresentable {
    let pose: FourDPose
    let wireSegments: [FourDWireSegment]

    func makeNSView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.backgroundColor = NSColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
        view.allowsCameraControl = true
        view.antialiasingMode = .multisampling4X
        view.rendersContinuously = true
        view.isPlaying = true
        view.pointOfView = context.coordinator.cameraNode
        context.coordinator.configureIfNeeded()
        context.coordinator.updateWireframe(wireSegments)
        context.coordinator.updateSlicePlane(pose)
        return view
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.rendersContinuously = true
        nsView.isPlaying = true
        context.coordinator.updateWireframe(wireSegments)
        context.coordinator.updateSlicePlane(pose)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        let scene = SCNScene()
        let cameraNode = SCNNode()
        let slicePlaneNode = SCNNode()
        let wireNode = SCNNode()

        func configureIfNeeded() {
            guard scene.rootNode.childNodes.isEmpty else { return }

            let camera = SCNCamera()
            camera.zFar = 100
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(4.5, 3.8, 4.5)
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
            keyLight.position = SCNVector3(5, 8, 3)
            keyLight.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(keyLight)

            let fillLight = SCNNode()
            fillLight.light = SCNLight()
            fillLight.light?.type = .directional
            fillLight.light?.color = NSColor(red: 0.45, green: 0.35, blue: 0.75, alpha: 1)
            fillLight.position = SCNVector3(-4, 2, -5)
            fillLight.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(fillLight)

            let plane = SCNPlane(width: 7, height: 7)
            plane.firstMaterial?.diffuse.contents = NSColor(red: 0.16, green: 0.24, blue: 0.42, alpha: 0.55)
            plane.firstMaterial?.isDoubleSided = true
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.position = SCNVector3(0, -0.01, 0)
            slicePlaneNode.addChildNode(planeNode)

            let ring = SCNTorus(ringRadius: 2.8, pipeRadius: 0.05)
            ring.firstMaterial?.diffuse.contents = NSColor(red: 0.61, green: 0.50, blue: 0.83, alpha: 0.35)
            let ringNode = SCNNode(geometry: ring)
            ringNode.eulerAngles.x = -.pi / 2
            ringNode.position = SCNVector3(0, 0.02, 0)
            slicePlaneNode.addChildNode(ringNode)

            scene.rootNode.addChildNode(slicePlaneNode)
            scene.rootNode.addChildNode(wireNode)
        }

        func updateSlicePlane(_ pose: FourDPose) {
            let euler = Hypercube4D.slicePlaneVisualEuler(pose: pose)
            slicePlaneNode.eulerAngles = euler
        }

        func updateWireframe(_ segments: [FourDWireSegment]) {
            wireNode.childNodes.forEach { $0.removeFromParentNode() }
            guard !segments.isEmpty else { return }

            var vertices: [SCNVector3] = []
            var colors: [NSColor] = []

            for segment in segments {
                vertices.append(SCNVector3(segment.start.x, segment.start.y, segment.start.z))
                vertices.append(SCNVector3(segment.end.x, segment.end.y, segment.end.z))

                let t = max(0, min(1, (segment.depth + 2.5) / 5))
                let color = NSColor(
                    red: CGFloat(0.35 + t * 0.15),
                    green: CGFloat(0.45 - t * 0.05),
                    blue: CGFloat(0.75 + t * 0.1),
                    alpha: 0.95
                )
                colors.append(color)
                colors.append(color)
            }

            let source = SCNGeometrySource(vertices: vertices)
            let colorData = colors.flatMap { color -> [Float] in
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                return [Float(r), Float(g), Float(b), Float(a)]
            }
            let colorSource = SCNGeometrySource(
                data: Data(bytes: colorData, count: colorData.count * MemoryLayout<Float>.size),
                semantic: .color,
                vectorCount: colors.count,
                usesFloatComponents: true,
                componentsPerVector: 4,
                bytesPerComponent: MemoryLayout<Float>.size,
                dataOffset: 0,
                dataStride: MemoryLayout<Float>.size * 4
            )

            var indices: [Int32] = []
            for index in 0..<segments.count {
                let base = Int32(index * 2)
                indices.append(contentsOf: [base, base + 1])
            }

            let element = SCNGeometryElement(indices: indices, primitiveType: .line)
            let geometry = SCNGeometry(sources: [source, colorSource], elements: [element])
            geometry.firstMaterial?.isDoubleSided = true
            geometry.firstMaterial?.lightingModel = .constant
            wireNode.addChildNode(SCNNode(geometry: geometry))
        }
    }
}