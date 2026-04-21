import Foundation

enum MosaicGridPreset: String, CaseIterable, Identifiable, Codable {
    case square
    case brick
    case dense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .square: return "Classic grid"
        case .brick: return "Brick shift"
        case .dense: return "Tight weave"
        }
    }

    var detail: String {
        switch self {
        case .square: return "Even square cells."
        case .brick: return "Staggered rows for rhythm."
        case .dense: return "Extra columns, snug spacing."
        }
    }
}
