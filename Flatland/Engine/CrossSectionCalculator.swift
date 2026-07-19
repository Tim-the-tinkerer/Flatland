import Foundation
import simd

struct MeshSlice {
    let localVertices: [SIMD3<Float>]
    let triangleIndices: [(Int, Int, Int)]
}

enum CrossSectionCalculator {
    static func compute(mesh: MeshSlice, transform: simd_float4x4, planeY: Float = 0) -> [CrossSectionSegment] {
        let worldVertices = mesh.localVertices.map { vertex -> SIMD3<Float> in
            let homogeneous = SIMD4<Float>(vertex.x, vertex.y, vertex.z, 1)
            let transformed = transform * homogeneous
            return SIMD3<Float>(transformed.x, transformed.y, transformed.z)
        }

        var segments: [CrossSectionSegment] = []

        for (i0, i1, i2) in mesh.triangleIndices {
            let v0 = worldVertices[i0]
            let v1 = worldVertices[i1]
            let v2 = worldVertices[i2]

            let hits = [
                segmentPlaneIntersection(a: v0, b: v1, planeY: planeY),
                segmentPlaneIntersection(a: v1, b: v2, planeY: planeY),
                segmentPlaneIntersection(a: v2, b: v0, planeY: planeY),
            ].compactMap { $0 }

            if hits.count == 2 {
                segments.append(
                    CrossSectionSegment(
                        start: SIMD2<Float>(hits[0].x, hits[0].z),
                        end: SIMD2<Float>(hits[1].x, hits[1].z)
                    )
                )
            }
        }

        return segments
    }

    static func polygons(from segments: [CrossSectionSegment]) -> [CrossSectionPolygon] {
        guard !segments.isEmpty else { return [] }

        func key(for point: SIMD2<Float>) -> String {
            String(format: "%.4f,%.4f", point.x, point.y)
        }

        var adjacency: [String: [(neighbor: String, point: SIMD2<Float>)]] = [:]
        var pointLookup: [String: SIMD2<Float>] = [:]

        for segment in segments {
            let start = SIMD2<Float>(segment.start.x, segment.start.y)
            let end = SIMD2<Float>(segment.end.x, segment.end.y)
            let startKey = key(for: start)
            let endKey = key(for: end)

            pointLookup[startKey] = start
            pointLookup[endKey] = end

            adjacency[startKey, default: []].append((endKey, end))
            adjacency[endKey, default: []].append((startKey, start))
        }

        var visited = Set<String>()
        var polygons: [CrossSectionPolygon] = []

        for startKey in adjacency.keys where !visited.contains(startKey) {
            var polygon: [SIMD2<Float>] = []
            var current = startKey
            var previous: String?

            for _ in 0..<500 {
                visited.insert(current)
                if let point = pointLookup[current] {
                    polygon.append(point)
                }

                guard let neighbors = adjacency[current] else { break }
                guard let next = neighbors.first(where: { $0.neighbor != previous })?.neighbor else { break }
                if next == startKey { break }

                previous = current
                current = next
            }

            if polygon.count >= 3 {
                polygons.append(CrossSectionPolygon(points: polygon))
            }
        }

        return polygons
    }

    static func apparitionCenter(from segments: [CrossSectionSegment], polygons: [CrossSectionPolygon]) -> SIMD2<Float>? {
        if let polygon = polygons.first, !polygon.points.isEmpty {
            let sum = polygon.points.reduce(SIMD2<Float>(0, 0)) { $0 + $1 }
            return sum / Float(polygon.points.count)
        }

        if let segment = segments.first {
            return (segment.start + segment.end) * 0.5
        }

        return nil
    }

    private static func segmentPlaneIntersection(a: SIMD3<Float>, b: SIMD3<Float>, planeY: Float) -> SIMD3<Float>? {
        let ya = a.y - planeY
        let yb = b.y - planeY

        if ya * yb > 0 { return nil }
        if abs(ya) < 1e-9 && abs(yb) < 1e-9 { return nil }

        let denominator = ya - yb
        guard abs(denominator) > 1e-9 else { return nil }

        let t = ya / denominator
        guard t >= -1e-9, t <= 1 + 1e-9 else { return nil }

        return SIMD3<Float>(
            a.x + t * (b.x - a.x),
            planeY,
            a.z + t * (b.z - a.z)
        )
    }
}