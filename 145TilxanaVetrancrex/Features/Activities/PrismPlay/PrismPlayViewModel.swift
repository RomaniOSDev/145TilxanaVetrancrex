import SwiftUI
import PhotosUI
import Combine

struct PrismBurst: Identifiable {
    let id = UUID()
    var cx: Double
    var cy: Double
    var radius: Double
    var hueShift: Double
}

@MainActor
final class PrismPlayViewModel: ObservableObject {
    @Published var pickerItem: PhotosPickerItem?
    @Published var baseData: Data?
    @Published var bursts: [PrismBurst] = []
    @Published var dragTip: CGPoint?
    @Published var alertMessage: String?

    func consumePickerSelection() async {
        guard let item = pickerItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            baseData = data
        }
        pickerItem = nil
    }

    func addBurst(at point: CGPoint, in size: CGSize, difficulty: ActivityDifficulty, level: Int) {
        guard size.width > 0, size.height > 0 else { return }
        let nx = Double(point.x / size.width)
        let ny = Double(point.y / size.height)
        let baseRadius = 0.12 + Double(level) * 0.012
        let radius = baseRadius * Double(difficulty.prismDragScale)
        let hue = Double.random(in: 0...1)
        bursts.append(PrismBurst(cx: nx, cy: ny, radius: radius, hueShift: hue))
    }

    func removeBurst(id: UUID) {
        bursts.removeAll { $0.id == id }
    }

    func resetSession() {
        bursts.removeAll()
        dragTip = nil
        alertMessage = nil
    }

    func coverageScore() -> Double {
        guard !bursts.isEmpty else { return 0 }
        let sum = bursts.reduce(0.0) { $0 + $1.radius }
        return min(1.0, sum / 1.2)
    }

    func starRating(level: Int, difficulty: ActivityDifficulty) -> Int {
        let layerScore = bursts.count
        let hueBuckets = Set(bursts.map { Int($0.hueShift / 0.18) }).count
        let cover = Int(coverageScore() * 8)
        var score = layerScore + hueBuckets + cover + difficulty.starThresholdBonus
        score -= max(0, level - 2)
        if bursts.isEmpty { return 0 }
        if score >= 10 + level { return 3 }
        if score >= 6 + level / 2 { return 2 }
        return 1
    }

    func uniqueColorBuckets() -> Int {
        Set(bursts.map { Int($0.hueShift / 0.2) }).count
    }
}
