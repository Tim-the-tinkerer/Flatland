import Foundation
import simd

enum ProceduralMeshes {
    static func slice(for shape: PassingShape) -> MeshSlice {
        switch shape {
        case .sphere:
            return sphere(radius: 1.2, stacks: 36, slices: 48)
        case .cube:
            return box(width: 1.92, height: 1.92, depth: 1.92)
        case .tetrahedron:
            return tetrahedron(scale: 1.2)
        case .cylinder:
            return cylinder(radius: 0.84, height: 2.64, slices: 40)
        case .torus:
            return torus(ringRadius: 1.08, pipeRadius: 0.42, ringSegments: 40, pipeSegments: 20)
        case .cone:
            return cone(radius: 1.08, height: 2.64, slices: 40)
        }
    }

    private static func sphere(radius: Float, stacks: Int, slices: Int) -> MeshSlice {
        var vertices: [SIMD3<Float>] = []

        for stack in 0...stacks {
            let v = Float(stack) / Float(stacks)
            let phi = v * .pi
            let sinPhi = sin(phi)
            let cosPhi = cos(phi)

            for slice in 0...slices {
                let u = Float(slice) / Float(slices)
                let theta = u * 2 * .pi
                vertices.append(
                    SIMD3<Float>(
                        radius * sinPhi * cos(theta),
                        radius * cosPhi,
                        radius * sinPhi * sin(theta)
                    )
                )
            }
        }

        var triangles: [(Int, Int, Int)] = []
        let row = slices + 1

        for stack in 0..<stacks {
            for slice in 0..<slices {
                let a = stack * row + slice
                let b = a + row
                triangles.append((a, b, a + 1))
                triangles.append((b, b + 1, a + 1))
            }
        }

        return MeshSlice(localVertices: vertices, triangleIndices: triangles)
    }

    private static func box(width: Float, height: Float, depth: Float) -> MeshSlice {
        let hx = width * 0.5
        let hy = height * 0.5
        let hz = depth * 0.5

        let vertices: [SIMD3<Float>] = [
            SIMD3(-hx, -hy, -hz), SIMD3(hx, -hy, -hz), SIMD3(hx, hy, -hz), SIMD3(-hx, hy, -hz),
            SIMD3(-hx, -hy, hz), SIMD3(hx, -hy, hz), SIMD3(hx, hy, hz), SIMD3(-hx, hy, hz),
        ]

        let faces: [(Int, Int, Int)] = [
            (0, 1, 2), (0, 2, 3),
            (4, 6, 5), (4, 7, 6),
            (0, 4, 5), (0, 5, 1),
            (2, 6, 7), (2, 7, 3),
            (0, 3, 7), (0, 7, 4),
            (1, 5, 6), (1, 6, 2),
        ]

        return MeshSlice(localVertices: vertices, triangleIndices: faces)
    }

    private static func tetrahedron(scale: Float) -> MeshSlice {
        let vertices: [SIMD3<Float>] = [
            SIMD3<Float>(0, 1.0, 0) * scale,
            SIMD3<Float>(-0.94, -0.67, 0.75) * scale,
            SIMD3<Float>(0.94, -0.67, 0.75) * scale,
            SIMD3<Float>(0, -0.67, -1.03) * scale,
        ]

        let faces: [(Int, Int, Int)] = [
            (0, 1, 2), (0, 2, 3), (0, 3, 1), (1, 3, 2),
        ]

        return MeshSlice(localVertices: vertices, triangleIndices: faces)
    }

    private static func cylinder(radius: Float, height: Float, slices: Int) -> MeshSlice {
        var vertices: [SIMD3<Float>] = []
        let half = height * 0.5

        for slice in 0...slices {
            let u = Float(slice) / Float(slices)
            let theta = u * 2 * .pi
            let x = radius * cos(theta)
            let z = radius * sin(theta)
            vertices.append(SIMD3(x, -half, z))
            vertices.append(SIMD3(x, half, z))
        }

        var triangles: [(Int, Int, Int)] = []
        for slice in 0..<slices {
            let top = slice * 2
            let bottom = top + 1
            let nextTop = top + 2
            let nextBottom = top + 3
            triangles.append((top, bottom, nextTop))
            triangles.append((bottom, nextBottom, nextTop))
        }

        return MeshSlice(localVertices: vertices, triangleIndices: triangles)
    }

    private static func cone(radius: Float, height: Float, slices: Int) -> MeshSlice {
        var vertices: [SIMD3<Float>] = [SIMD3(0, height * 0.5, 0)]
        let half = height * 0.5

        for slice in 0...slices {
            let u = Float(slice) / Float(slices)
            let theta = u * 2 * .pi
            vertices.append(SIMD3(radius * cos(theta), -half, radius * sin(theta)))
        }

        var triangles: [(Int, Int, Int)] = []
        for slice in 0..<slices {
            triangles.append((0, slice + 1, slice + 2))
        }

        return MeshSlice(localVertices: vertices, triangleIndices: triangles)
    }

    private static func torus(
        ringRadius: Float,
        pipeRadius: Float,
        ringSegments: Int,
        pipeSegments: Int
    ) -> MeshSlice {
        var vertices: [SIMD3<Float>] = []

        for ring in 0...ringSegments {
            let u = Float(ring) / Float(ringSegments)
            let theta = u * 2 * .pi
            let cosTheta = cos(theta)
            let sinTheta = sin(theta)

            for pipe in 0...pipeSegments {
                let v = Float(pipe) / Float(pipeSegments)
                let phi = v * 2 * .pi
                let cosPhi = cos(phi)
                let sinPhi = sin(phi)

                let x = (ringRadius + pipeRadius * cosPhi) * cosTheta
                let y = pipeRadius * sinPhi
                let z = (ringRadius + pipeRadius * cosPhi) * sinTheta
                vertices.append(SIMD3(x, y, z))
            }
        }

        var triangles: [(Int, Int, Int)] = []
        let row = pipeSegments + 1

        for ring in 0..<ringSegments {
            for pipe in 0..<pipeSegments {
                let a = ring * row + pipe
                let b = a + row
                triangles.append((a, b, a + 1))
                triangles.append((b, b + 1, a + 1))
            }
        }

        return MeshSlice(localVertices: vertices, triangleIndices: triangles)
    }
}