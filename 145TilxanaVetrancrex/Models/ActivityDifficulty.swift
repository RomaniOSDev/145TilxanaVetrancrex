import Foundation

enum ActivityDifficulty: String, CaseIterable, Identifiable, Hashable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var livesCap: Int {
        switch self {
        case .easy: return 8
        case .medium: return 5
        case .hard: return 3
        }
    }

    var prismDragScale: CGFloat {
        switch self {
        case .easy: return 1.15
        case .medium: return 1.0
        case .hard: return 0.85
        }
    }

    var doodleObstacleCount: Int {
        switch self {
        case .easy: return 0
        case .medium: return 2
        case .hard: return 4
        }
    }

    var mosaicGridBase: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }

    var starThresholdBonus: Int {
        switch self {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }
}
