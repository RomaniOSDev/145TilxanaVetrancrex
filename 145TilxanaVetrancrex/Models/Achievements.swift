import Foundation

enum AchievementID: String, CaseIterable, Identifiable {
    case firstSave
    case collectorFive
    case starTen
    case starTwentyFive
    case prismPathClear
    case doodlePathClear
    case mosaicPathClear
    case tripleMoment
    case weeklyHero

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstSave: return "First keeper"
        case .collectorFive: return "Growing wall"
        case .starTen: return "Bright start"
        case .starTwentyFive: return "Constellation"
        case .prismPathClear: return "Prism regular"
        case .doodlePathClear: return "Ink regular"
        case .mosaicPathClear: return "Tile regular"
        case .tripleMoment: return "Peak shine"
        case .weeklyHero: return "Week warrior"
        }
    }

    var detail: String {
        switch self {
        case .firstSave: return "Save any piece to the gallery."
        case .collectorFive: return "Keep at least five saves on the wall."
        case .starTen: return "Collect ten stars across challenges."
        case .starTwentyFive: return "Collect twenty-five stars overall."
        case .prismPathClear: return "Finish every Prism Play stage at least once."
        case .doodlePathClear: return "Finish every Doodle Dash stage at least once."
        case .mosaicPathClear: return "Finish every Mosaic stage at least once."
        case .tripleMoment: return "Earn three stars on any single stage."
        case .weeklyHero: return "Clear three weekly goals in the current week."
        }
    }
}

enum GalleryFilter: String, CaseIterable, Identifiable {
    case all
    case favorites
    case freeform
    case prism
    case doodle
    case mosaic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .freeform: return "Studio"
        case .prism: return "Prism"
        case .doodle: return "Doodle"
        case .mosaic: return "Mosaic"
        }
    }

    func matches(_ record: CreationRecord) -> Bool {
        switch self {
        case .all: return true
        case .favorites: return record.isFavorite
        case .freeform: return record.kind == .freeform
        case .prism: return record.kind == .prismSnapshot
        case .doodle: return record.kind == .doodleSnapshot
        case .mosaic: return record.kind == .mosaicSnapshot
        }
    }
}

enum DiscoverVisualTheme: String, CaseIterable, Identifiable {
    case balanced
    case warm
    case cool
    case electric
    case soft

    var id: String { rawValue }

    var title: String {
        switch self {
        case .balanced: return "Balanced"
        case .warm: return "Warm mix"
        case .cool: return "Cool mix"
        case .electric: return "Electric"
        case .soft: return "Soft haze"
        }
    }
}
