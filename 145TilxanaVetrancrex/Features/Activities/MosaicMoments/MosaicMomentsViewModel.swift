import Combine
import SwiftUI

struct MosaicPiece: Identifiable {
    let id = UUID()
    var gridX: Int
    var gridY: Int
    var colorIndex: Int
    var shape: Int
}

@MainActor
final class MosaicMomentsViewModel: ObservableObject {
    @Published var pieces: [MosaicPiece] = []
    @Published var dragOffset: CGSize = .zero
    @Published var activeTemplate: MosaicPiece?
    @Published var alertMessage: String?

    let columns: Int
    let rows: Int
    let gridPreset: MosaicGridPreset

    init(level: Int, difficulty: ActivityDifficulty, gridPreset: MosaicGridPreset) {
        self.gridPreset = gridPreset
        var base = difficulty.mosaicGridBase
        if gridPreset == .dense {
            base += 1
        }
        columns = min(7, base + (level - 1))
        rows = min(7, base + max(0, level - 2))
    }

    var cellGap: CGFloat {
        switch gridPreset {
        case .square, .brick: return 4
        case .dense: return 2
        }
    }

    var cellInnerTrim: CGFloat {
        switch gridPreset {
        case .square, .brick: return 12
        case .dense: return 8
        }
    }

    func brickOffsetX(gridY: Int, cellWidth: CGFloat) -> CGFloat {
        guard gridPreset == .brick, gridY % 2 == 1 else { return 0 }
        return cellWidth * 0.5
    }

    func reset() {
        pieces.removeAll()
        dragOffset = .zero
        activeTemplate = nil
        alertMessage = nil
    }

    func spawnTemplate(colorIndex: Int, shape: Int) {
        activeTemplate = MosaicPiece(gridX: 0, gridY: 0, colorIndex: colorIndex, shape: shape)
    }

    func placeActive(at cell: CGPoint, in size: CGSize) {
        guard var template = activeTemplate else { return }
        let cellW = size.width / CGFloat(columns)
        let cellH = size.height / CGFloat(rows)
        var adjustedX = cell.x
        if gridPreset == .brick {
            let gyProbe = Int((cell.y / cellH).rounded(.down))
            adjustedX -= brickOffsetX(gridY: gyProbe, cellWidth: cellW)
        }
        let gx = Int((adjustedX / cellW).rounded(.down))
        let gy = Int((cell.y / cellH).rounded(.down))
        let clampedX = min(columns - 1, max(0, gx))
        let clampedY = min(rows - 1, max(0, gy))
        template.gridX = clampedX
        template.gridY = clampedY
        pieces.append(template)
        activeTemplate = nil
    }

    func starRating(level: Int, difficulty: ActivityDifficulty) -> Int {
        let count = pieces.count
        let overlapScore = overlapCount()
        var score = count * 10 + overlapScore * 6 + difficulty.starThresholdBonus * 2
        score -= max(0, level - 2) * 3
        if gridPreset == .dense { score += 4 }
        if gridPreset == .brick { score += 3 }
        let target = 2 + level / 2
        if count < target { return 0 }
        if score >= 70 { return 3 }
        if score >= 40 { return 2 }
        return 1
    }

    func overlapCount() -> Int {
        var overlaps = 0
        for i in 0..<pieces.count {
            for j in (i + 1)..<pieces.count {
                if pieces[i].gridX == pieces[j].gridX && pieces[i].gridY == pieces[j].gridY {
                    overlaps += 1
                }
            }
        }
        return overlaps
    }

    func paletteDiversity() -> Int {
        Set(pieces.map { $0.colorIndex }).count
    }
}
