import Foundation

enum ActivityKind: String, CaseIterable, Identifiable, Codable, Hashable {
    case prismPlay = "prism"
    case doodleDash = "doodle"
    case mosaicMoments = "mosaic"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prismPlay: return "Prism Play"
        case .doodleDash: return "Doodle Dash"
        case .mosaicMoments: return "Mosaic Moments"
        }
    }

    var subtitle: String {
        switch self {
        case .prismPlay: return "Layer light splits over your frame"
        case .doodleDash: return "Bold strokes, playful brushes"
        case .mosaicMoments: return "Snap blocks into lively collages"
        }
    }
}
