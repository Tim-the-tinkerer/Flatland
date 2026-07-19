import AppKit
import SceneKit
import SwiftUI

struct Slice3DView: NSViewRepresentable {
    let mesh: FourDSliceMesh

    func makeNSView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.backgroundColor = NSColor(red: 0.05, green: 0.06, blue: 0.12, alpha: 1)
        view.allowsCameraControl = true
        view.antialiasingMode = .multisampling4X
        view.rendersContinuously = true
        view.isPlaying = true
        view.pointOfView = context.coordinator.cameraNode
        context.coordinator.configureIfNeeded()
        context.coordinator.updateMesh(mesh)
        return view
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        nsView.rendersContinuously = true
        nsView.isPlaying = true
        context.coordinator.updateMesh(mesh)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private static func makeEdgeNode(vertices: [SCNVector3], indices: [Int32]) -> SCNNode {
        var edgeVertices: [SCNVector3] = []
        var edgeIndices: [Int32] = []

        var triangle = 0
        while triangle < indices.count {
            let i0 = Int(indices[triangle])
            let i1 = Int(indices[triangle + 1])
            let i2 = Int(indices[triangle + 2])
            let base = Int32(edgeVertices.count)
            edgeVertices.append(vertices[i0])
            edgeVertices.append(vertices[i1])
            edgeVertices.append(vertices[i1])
            edgeVertices.append(vertices[i2])
            edgeVertices.append(vertices[i2])
            edgeVertices.append(vertices[i0])
            edgeIndices.append(contentsOf: [base, base + 1, base + 2, base + 3, base + 4, base + 5])
            triangle += 3
        }

        let edgeSource = SCNGeometrySource(vertices: edgeVertices)
        let edgeElement = SCNGeometryElement(indices: edgeIndices, primitiveType: .line)
        let edgeGeometry = SCNGeometry(sources: [edgeSource], elements: [edgeElement])
        let edgeMaterial = SCNMaterial()
        edgeMaterial.diffuse.contents = NSColor(red: 0.91, green: 0.86, blue: 1.0, alpha: 0.95)
        edgeMaterial.emission.contents = NSColor(red: 0.5, green: 0.4, blue: 0.8, alpha: 1)
        edgeMaterial.lightingModel = .constant
        edgeGeometry.materials = [edgeMaterial]
        return SCNNode(geometry: edgeGeometry)
    }

    private static func fitCamera(_ cameraNode: SCNNode, to vertices: [SIMD3<Float>]) {
        var minX = Float.greatestFiniteMagnitude
        var maxX = -Float.greatestFiniteMagnitude
        var minY = Float.greatestFiniteMagnitude
        var maxY = -Float.greatestFiniteMagnitude
        var minZ = Float.greatestFiniteMagnitude
        var maxZ = -Float.greatestFiniteMagnitude

        for vertex in vertices {
            minX = min(minX, vertex.x)
            maxX = max(maxX, vertex.x)
            minY = min(minY, vertex.y)
            maxY = max(maxY, vertex.y)
            minZ = min(minZ, vertex.z)
            maxZ = max(maxZ, vertex.z)
        }

        let centerX = (minX + maxX) * 0.5
        let centerY = (minY + maxY) * 0.5
        let centerZ = (minZ + maxZ) * 0.5
        let center = SCNVector3(centerX, centerY, centerZ)

        let spanX = maxX - minX
        let spanY = maxY - minY
        let spanZ = maxZ - minZ
        let radius = max(spanX, spanY, spanZ, 0.8)

        let offsetX = centerX + radius * 1.8
        let offsetY = centerY + radius * 1.3
        let offsetZ = centerZ + radius * 1.8
        cameraNode.position = SCNVector3(offsetX, offsetY, offsetZ)
        cameraNode.look(at: center)
    }

    final class Coordinator {
        let scene = SCNScene()
        let cameraNode = SCNNode()
        let meshNode = SCNNode()
        let edgeNode = SCNNode()

        func configureIfNeeded() {
            guard scene.rootNode.childNodes.isEmpty else { return }

            let camera = SCNCamera()
            camera.zFar = 100
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(2.8, 2.2, 2.8)
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
            keyLight.light?.color = NSColor(red: 0.92, green: 0.88, blue: 1.0, alpha: 1)
            keyLight.position = SCNVector3(4, 6, 3)
            keyLight.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(keyLight)

            scene.rootNode.addChildNode(meshNode)
            scene.rootNode.addChildNode(edgeNode)

            let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 18))
            meshNode.runAction(spin)
            edgeNode.runAction(spin)
        }

        func updateMesh(_ mesh: FourDSliceMesh) {
            meshNode.childNodes.forEach { $0.removeFromParentNode() }
            edgeNode.childNodes.forEach { $0.removeFromParentNode() }

            guard !mesh.vertices.isEmpty else { return }

            Slice3DView.fitCamera(cameraNode, to: mesh.vertices)

            if mesh.indices.isEmpty {
                for vertex in mesh.vertices {
                    let sphere = SCNSphere(radius: 0.06)
                    sphere.firstMaterial?.diffuse.contents = NSColor(red: 0.77, green: 0.71, blue: 0.99, alpha: 1)
                    sphere.firstMaterial?.emission.contents = NSColor(red: 0.45, green: 0.35, blue: 0.75, alpha: 1)
                    let node = SCNNode(geometry: sphere)
                    node.position = SCNVector3(vertex.x, vertex.y, vertex.z)
                    meshNode.addChildNode(node)
                }
                return
            }

            let vertices = mesh.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
            let source = SCNGeometrySource(vertices: vertices)
            let element = SCNGeometryElement(indices: mesh.indices, primitiveType: .triangles)
            let geometry = SCNGeometry(sources: [source], elements: [element])

            let material = SCNMaterial()
            material.diffuse.contents = NSColor(red: 0.61, green: 0.50, blue: 0.83, alpha: 0.88)
            material.emission.contents = NSColor(red: 0.24, green: 0.18, blue: 0.42, alpha: 1)
            material.transparency = 0.88
            material.isDoubleSided = true
            material.roughness.contents = 0.35
            material.metalness.contents = 0.35
            geometry.materials = [material]

            meshNode.addChildNode(SCNNode(geometry: geometry))
            edgeNode.addChildNode(Slice3DView.makeEdgeNode(vertices: vertices, indices: mesh.indices))
        }
    }
}