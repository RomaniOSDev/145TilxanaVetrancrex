import SwiftUI
import Combine

struct DoodleStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var colorIndex: Int
    var brush: Int
    var width: CGFloat
}

@MainActor
final class DoodleDashViewModel: ObservableObject {
    @Published var strokes: [DoodleStroke] = []
    @Published var livePoints: [CGPoint] = []
    @Published var colorIndex = 0
    @Published var brushIndex = 0
    @Published var livesRemaining: Int
    @Published var alertMessage: String?

    let obstacleRects: [CGRect]

    init(difficulty: ActivityDifficulty, level: Int) {
        livesRemaining = difficulty.livesCap
        obstacleRects = DoodleDashViewModel.makeObstacles(count: difficulty.doodleObstacleCount, level: level)
    }

    func reset(difficulty: ActivityDifficulty) {
        strokes.removeAll()
        livePoints.removeAll()
        colorIndex = 0
        brushIndex = 0
        livesRemaining = difficulty.livesCap
        alertMessage = nil
    }

    func appendLivePoint(_ point: CGPoint) {
        if let last = livePoints.last {
            for rect in obstacleRects {
                if segmentIntersectsRect(a: last, b: point, rect: rect) {
                    if livesRemaining > 0 {
                        livesRemaining -= 1
                    }
                    break
                }
            }
        }
        livePoints.append(point)
    }

    func undoLastStroke() {
        guard !strokes.isEmpty else { return }
        strokes.removeLast()
    }

    func commitStroke(in size: CGSize) {
        defer { livePoints.removeAll() }
        guard size.width > 0, size.height > 0, livePoints.count > 1 else { return }
        let normalized = livePoints.map { CGPoint(x: $0.x / size.width, y: $0.y / size.height) }
        let width: CGFloat
        switch brushIndex {
        case 0: width = 6
        case 1: width = 11
        default: width = 16
        }
        strokes.append(DoodleStroke(points: normalized, colorIndex: colorIndex, brush: brushIndex, width: width))
    }

    func totalLength(in size: CGSize) -> CGFloat {
        func length(of stroke: DoodleStroke) -> CGFloat {
            let pts = stroke.points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
            guard pts.count > 1 else { return 0 }
            var sum: CGFloat = 0
            for idx in 1..<pts.count {
                sum += hypot(pts[idx].x - pts[idx - 1].x, pts[idx].y - pts[idx - 1].y)
            }
            return sum
        }
        return strokes.reduce(0) { $0 + length(of: $1) }
    }

    func starRating(level: Int, difficulty: ActivityDifficulty) -> Int {
        let variety = Set(strokes.map { $0.brush }).count
        let lengthScore = min(120, strokes.count * 18 + variety * 20)
        var score = lengthScore + variety * 6 + difficulty.starThresholdBonus * 3
        score -= max(0, level - 1) * 4
        if livesRemaining <= 0 && strokes.count < 2 { return 0 }
        if strokes.isEmpty { return 0 }
        if score >= 80 { return 3 }
        if score >= 45 { return 2 }
        return 1
    }

    func distinctBrushes() -> Int {
        Set(strokes.map { $0.brush }).count
    }

    private static func makeObstacles(count: Int, level: Int) -> [CGRect] {
        guard count > 0 else { return [] }
        var rects: [CGRect] = []
        let seeds: [CGFloat] = [0.25, 0.55, 0.38, 0.7, 0.45, 0.62]
        for idx in 0..<count {
            let cx = seeds[idx % seeds.count]
            let cy = seeds[(idx + 2) % seeds.count]
            let inset = 0.05 + CGFloat(level) * 0.005
            let sizeBox = 0.12 + CGFloat(idx % 2) * 0.04
            rects.append(
                CGRect(
                    x: cx - sizeBox / 2,
                    y: cy - sizeBox / 2 + inset * 0.2,
                    width: sizeBox,
                    height: sizeBox
                )
            )
        }
        return rects
    }

    private func segmentIntersectsRect(a: CGPoint, b: CGPoint, rect: CGRect) -> Bool {
        if rect.contains(a) || rect.contains(b) { return true }
        let edges = [
            (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY))
        ]
        for edge in edges {
            if segmentsIntersect(a, b, edge.0, edge.1) { return true }
        }
        return false
    }

    private func segmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ p4: CGPoint) -> Bool {
        func orient(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGFloat {
            (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
        }
        let o1 = orient(p1, p2, p3)
        let o2 = orient(p1, p2, p4)
        let o3 = orient(p3, p4, p1)
        let o4 = orient(p3, p4, p2)

        if o1 * o2 < 0 && o3 * o4 < 0 { return true }
        return false
    }
}
