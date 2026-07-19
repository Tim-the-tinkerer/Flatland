import AppKit
import SceneKit
import simd

enum ShapeFactory {
    static func geometry(for shape: PassingShape) -> SCNGeometry {
        switch shape {
        case .sphere:
            let sphere = SCNSphere(radius: 1.2)
            sphere.segmentCount = 48
            return sphere
        case .cube:
            return SCNBox(width: 1.92, height: 1.92, length: 1.92, chamferRadius: 0)
        case .tetrahedron:
            return tetrahedronGeometry()
        case .cylinder:
            return SCNCylinder(radius: 0.84, height: 2.64)
        case .torus:
            return SCNTorus(ringRadius: 1.08, pipeRadius: 0.42)
        case .cone:
            return SCNCone(topRadius: 0, bottomRadius: 1.08, height: 2.64)
        }
    }

    static func meshSlice(for shape: PassingShape) -> MeshSlice {
        ProceduralMeshes.slice(for: shape)
    }

    private static func tetrahedronGeometry() -> SCNGeometry {
        let scale: Float = 1.2
        let vertices: [SIMD3<Float>] = [
            SIMD3<Float>(0, 1.0, 0) * scale,
            SIMD3<Float>(-0.94, -0.67, 0.75) * scale,
            SIMD3<Float>(0.94, -0.67, 0.75) * scale,
            SIMD3<Float>(0, -0.67, -1.03) * scale,
        ]

        let faces: [(Int, Int, Int)] = [
            (0, 1, 2),
            (0, 2, 3),
            (0, 3, 1),
            (1, 3, 2),
        ]

        var flatVertices: [SCNVector3] = []
        var indices: [Int32] = []

        for (a, b, c) in faces {
            let base = Int32(flatVertices.count)
            flatVertices.append(SCNVector3(vertices[a]))
            flatVertices.append(SCNVector3(vertices[b]))
            flatVertices.append(SCNVector3(vertices[c]))
            indices.append(contentsOf: [base, base + 1, base + 2])
        }

        let source = SCNGeometrySource(vertices: flatVertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial = material()
        return geometry
    }

    static func material() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 0.42, green: 0.55, blue: 0.68, alpha: 0.92)
        material.metalness.contents = 0.4
        material.roughness.contents = 0.35
        material.transparency = 0.92
        material.isDoubleSided = true
        return material
    }

    static func secondaryMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 0.36, green: 0.52, blue: 0.78, alpha: 0.92)
        material.metalness.contents = 0.45
        material.roughness.contents = 0.3
        material.transparency = 0.9
        material.isDoubleSided = true
        return material
    }
}

enum MeshExtractor {
    static func slice(from geometry: SCNGeometry) -> MeshSlice {
        guard let vertexSource = geometry.sources(for: .vertex).first else {
            return MeshSlice(localVertices: [], triangleIndices: [])
        }

        let vertices = readVertices(from: vertexSource)
        let indices = readTriangleIndices(from: geometry)

        return MeshSlice(localVertices: vertices, triangleIndices: indices)
    }

    private static func readVertices(from source: SCNGeometrySource) -> [SIMD3<Float>] {
        let count = source.vectorCount
        let stride = source.dataStride
        let offset = source.dataOffset

        return source.data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return [] }
            return (0..<count).map { index in
                let pointer = base
                    .advanced(by: offset + index * stride)
                    .assumingMemoryBound(to: Float.self)
                return SIMD3<Float>(pointer[0], pointer[1], pointer[2])
            }
        }
    }

    private static func readTriangleIndices(from geometry: SCNGeometry) -> [(Int, Int, Int)] {
        var triangles: [(Int, Int, Int)] = []

        for element in geometry.elements where element.primitiveType == .triangles {
            let indexCount = element.primitiveCount * 3
            let bytesPerIndex = element.bytesPerIndex

            element.data.withUnsafeBytes { rawBuffer in
                guard let base = rawBuffer.baseAddress else { return }

                for triangleIndex in 0..<element.primitiveCount {
                    let offset = triangleIndex * 3 * bytesPerIndex
                    let indices: [Int]
                    if bytesPerIndex == 2 {
                        let buffer = base.assumingMemoryBound(to: UInt16.self)
                        let baseIndex = offset / 2
                        indices = [Int(buffer[baseIndex]), Int(buffer[baseIndex + 1]), Int(buffer[baseIndex + 2])]
                    } else {
                        let buffer = base.assumingMemoryBound(to: UInt32.self)
                        let baseIndex = offset / 4
                        indices = [Int(buffer[baseIndex]), Int(buffer[baseIndex + 1]), Int(buffer[baseIndex + 2])]
                    }
                    triangles.append((indices[0], indices[1], indices[2]))
                }
            }
        }

        return triangles
    }
}