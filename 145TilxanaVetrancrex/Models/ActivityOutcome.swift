import Foundation

struct ActivityOutcome: Hashable {
    let activity: ActivityKind
    let level: Int
    let difficulty: ActivityDifficulty
    let stars: Int
    let colorsUsed: Int
    let drawingLengthPoints: Int
    let coveragePercent: Int
    let blocksPlaced: Int
    let isNewRecord: Bool
}
