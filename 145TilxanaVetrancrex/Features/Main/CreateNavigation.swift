import SwiftUI

enum CreateNavRoute: Hashable {
    case challenges
    case prism(level: Int, difficulty: ActivityDifficulty)
    case doodle(level: Int, difficulty: ActivityDifficulty)
    case mosaic(level: Int, difficulty: ActivityDifficulty)
    case outcome(ActivityOutcome)
}
