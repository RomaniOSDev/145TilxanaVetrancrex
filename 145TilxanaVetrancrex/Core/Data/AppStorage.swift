import Combine
import Foundation
import SwiftUI

extension Notification.Name {
    static let photoFlowDataDidReset = Notification.Name("photoFlowDataDidReset")
}

@MainActor
final class PhotoFlowData: ObservableObject {
    private enum Keys {
        static let onboarding = "hasSeenOnboarding"
        static let starsDictionary = "starsDictionary"
        static let completedChallengesSet = "completedChallengesSet"
        static let galleryCreations = "galleryCreationsJSON"
        static let totalDrawingLength = "totalDrawingLengthPoints"
        static let totalColorsUsed = "totalColorsUsedCount"
        static let totalPrismLayers = "totalPrismLayersCount"
        static let unlockedPaletteTier = "unlockedPaletteTier"
        static let achievementsUnlocked = "achievementsUnlockedSet"
        static let weeklyCompletions = "weeklyCompletionsSet"
        static let mosaicPreset = "lastMosaicGridPreset"
    }

    private let defaults = UserDefaults.standard

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var starsByChallengeKey: [String: Int]
    @Published private(set) var completedChallengeKeys: Set<String>
    @Published private(set) var galleryCreations: [CreationRecord]
    @Published private(set) var totalDrawingLengthPoints: Double
    @Published private(set) var totalColorsUsedCount: Int
    @Published private(set) var totalPrismLayersCount: Int
    @Published private(set) var unlockedPaletteTier: Int
    @Published private(set) var achievementsUnlocked: Set<String>
    @Published private(set) var weeklyCompletions: Set<String>
    @Published private(set) var lastMosaicPreset: MosaicGridPreset

    @Published private(set) var shouldOpenCreateTab = false
    private(set) var studioDraftToLoad: CreationRecord?

    var totalStarsEarned: Int {
        starsByChallengeKey.values.reduce(0, +)
    }

    var completedActivitiesCount: Int {
        completedChallengeKeys.count
    }

    var collectionSummaryLine: String {
        let stars = totalStarsEarned
        let done = completedActivitiesCount
        return "Stars: \(stars) · Finished: \(done)"
    }

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.onboarding)
        starsByChallengeKey = Self.decodeDictionary(defaults.string(forKey: Keys.starsDictionary))
        completedChallengeKeys = Self.decodeSet(defaults.string(forKey: Keys.completedChallengesSet))
        galleryCreations = Self.decodeGallery(defaults.string(forKey: Keys.galleryCreations))
        totalDrawingLengthPoints = defaults.double(forKey: Keys.totalDrawingLength)
        totalColorsUsedCount = defaults.integer(forKey: Keys.totalColorsUsed)
        totalPrismLayersCount = defaults.integer(forKey: Keys.totalPrismLayers)
        unlockedPaletteTier = max(0, defaults.integer(forKey: Keys.unlockedPaletteTier))
        achievementsUnlocked = Self.decodeSet(defaults.string(forKey: Keys.achievementsUnlocked))
        weeklyCompletions = Self.decodeSet(defaults.string(forKey: Keys.weeklyCompletions))
        let presetRaw = defaults.string(forKey: Keys.mosaicPreset) ?? MosaicGridPreset.square.rawValue
        lastMosaicPreset = MosaicGridPreset(rawValue: presetRaw) ?? .square
        refreshUnlockTierFromStars()
        refreshAchievementsIfNeeded()
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.onboarding)
        objectWillChange.send()
    }

    func stars(for key: String) -> Int {
        starsByChallengeKey[key] ?? 0
    }

    func bestStars(for activity: ActivityKind, level: Int) -> Int {
        stars(for: Self.challengeKey(activity: activity, level: level))
    }

    func isLevelUnlocked(activity: ActivityKind, level: Int) -> Bool {
        if level <= 1 { return true }
        let prev = Self.challengeKey(activity: activity, level: level - 1)
        return (starsByChallengeKey[prev] ?? 0) >= 1
    }

    static func weekCalendarComponents(from date: Date = Date()) -> (year: Int, week: Int) {
        let cal = Calendar.current
        let y = cal.component(.yearForWeekOfYear, from: date)
        let w = cal.component(.weekOfYear, from: date)
        return (y, w)
    }

    func weeklyChallenge(slot: Int) -> (ActivityKind, Int) {
        let (y, w) = Self.weekCalendarComponents()
        let kinds: [ActivityKind] = [.prismPlay, .doodleDash, .mosaicMoments]
        let activity = kinds[slot % kinds.count]
        let level = ((y &* 31) &+ (w &* 13) &+ slot) % 5 &+ 1
        return (activity, level)
    }

    func weeklySlotKey(slot: Int) -> String {
        let (y, w) = Self.weekCalendarComponents()
        return "\(y)_\(w)_\(slot)"
    }

    func isWeeklySlotComplete(slot: Int) -> Bool {
        weeklyCompletions.contains(weeklySlotKey(slot: slot))
    }

    func currentWeekCompletedSlotCount() -> Int {
        let (y, w) = Self.weekCalendarComponents()
        let prefix = "\(y)_\(w)_"
        return weeklyCompletions.filter { $0.hasPrefix(prefix) }.count
    }

    func isAchievementUnlocked(_ id: AchievementID) -> Bool {
        achievementsUnlocked.contains(id.rawValue)
    }

    func achievementProgressSummary() -> String {
        let n = achievementsUnlocked.count
        return "Unlocked \(n) / \(AchievementID.allCases.count)"
    }

    func saveMosaicPreset(_ preset: MosaicGridPreset) {
        lastMosaicPreset = preset
        defaults.set(preset.rawValue, forKey: Keys.mosaicPreset)
        objectWillChange.send()
    }

    func requestOpenInStudio(_ record: CreationRecord) {
        studioDraftToLoad = record
        shouldOpenCreateTab = true
        objectWillChange.send()
    }

    func acknowledgeCreateTabSwitch() {
        shouldOpenCreateTab = false
        objectWillChange.send()
    }

    func takeStudioDraft() -> CreationRecord? {
        defer { studioDraftToLoad = nil }
        return studioDraftToLoad
    }

    /// Loads a piece into Studio only for freeform saves; leaves other pending drafts intact.
    func takeFreeformStudioDraft() -> CreationRecord? {
        guard let draft = studioDraftToLoad, draft.kind == .freeform else { return nil }
        studioDraftToLoad = nil
        objectWillChange.send()
        return draft
    }

    func setGalleryFavorite(id: UUID, isFavorite: Bool) {
        guard let idx = galleryCreations.firstIndex(where: { $0.id == id }) else { return }
        galleryCreations[idx].isFavorite = isFavorite
        persistGalleryOnly()
        refreshAchievementsIfNeeded()
    }

    func setGalleryTags(id: UUID, tags: [String]) {
        guard let idx = galleryCreations.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        galleryCreations[idx].tags = Array(trimmed.prefix(5))
        persistGalleryOnly()
    }

    func recordCompletion(
        activity: ActivityKind,
        level: Int,
        stars: Int,
        drawingLengthDelta: Double,
        colorsUsedDelta: Int,
        prismLayersDelta: Int
    ) {
        let key = Self.challengeKey(activity: activity, level: level)
        let clamped = min(3, max(1, stars))
        let previousBest = starsByChallengeKey[key] ?? 0
        if clamped > previousBest {
            starsByChallengeKey[key] = clamped
        }
        completedChallengeKeys.insert(key)
        totalDrawingLengthPoints += max(0, drawingLengthDelta)
        totalColorsUsedCount += max(0, colorsUsedDelta)
        totalPrismLayersCount += max(0, prismLayersDelta)
        refreshUnlockTierFromStars()
        tryMarkWeeklySlots(activity: activity, level: level)
        persistCore()
        persistWeekly()
        refreshAchievementsIfNeeded()
    }

    func addGalleryCreation(_ record: CreationRecord) {
        var next = galleryCreations
        next.insert(record, at: 0)
        if next.count > 40 { next = Array(next.prefix(40)) }
        galleryCreations = next
        persistGalleryOnly()
        refreshAchievementsIfNeeded()
    }

    func removeGalleryCreation(id: UUID) {
        galleryCreations.removeAll { $0.id == id }
        persistGalleryOnly()
        refreshAchievementsIfNeeded()
    }

    func resetAll() {
        hasSeenOnboarding = false
        starsByChallengeKey = [:]
        completedChallengeKeys = []
        galleryCreations = []
        totalDrawingLengthPoints = 0
        totalColorsUsedCount = 0
        totalPrismLayersCount = 0
        unlockedPaletteTier = 0
        achievementsUnlocked = []
        weeklyCompletions = []
        lastMosaicPreset = .square
        studioDraftToLoad = nil
        shouldOpenCreateTab = false
        defaults.removeObject(forKey: Keys.onboarding)
        defaults.removeObject(forKey: Keys.starsDictionary)
        defaults.removeObject(forKey: Keys.completedChallengesSet)
        defaults.removeObject(forKey: Keys.galleryCreations)
        defaults.removeObject(forKey: Keys.totalDrawingLength)
        defaults.removeObject(forKey: Keys.totalColorsUsed)
        defaults.removeObject(forKey: Keys.totalPrismLayers)
        defaults.removeObject(forKey: Keys.unlockedPaletteTier)
        defaults.removeObject(forKey: Keys.achievementsUnlocked)
        defaults.removeObject(forKey: Keys.weeklyCompletions)
        defaults.removeObject(forKey: Keys.mosaicPreset)
        NotificationCenter.default.post(name: .photoFlowDataDidReset, object: nil)
        objectWillChange.send()
    }

    func paletteUnlockedTier(for stars: Int) -> Int {
        if stars >= 24 { return 3 }
        if stars >= 12 { return 2 }
        if stars >= 6 { return 1 }
        return 0
    }

    var mosaicAdvancedLayoutsUnlocked: Bool {
        totalStarsEarned >= 6 || unlockedPaletteTier >= 1
    }

    private func refreshUnlockTierFromStars() {
        let tier = paletteUnlockedTier(for: totalStarsEarned)
        if tier > unlockedPaletteTier {
            unlockedPaletteTier = tier
        }
    }

    private func tryMarkWeeklySlots(activity: ActivityKind, level: Int) {
        var changed = false
        for slot in 0..<7 {
            let pair = weeklyChallenge(slot: slot)
            if pair.0 == activity && pair.1 == level {
                let k = weeklySlotKey(slot: slot)
                if !weeklyCompletions.contains(k) {
                    weeklyCompletions.insert(k)
                    changed = true
                }
            }
        }
        if changed {
            persistWeekly()
        }
    }

    private func refreshAchievementsIfNeeded() {
        var changed = false
        for id in AchievementID.allCases {
            if achievementsUnlocked.contains(id.rawValue) { continue }
            if evaluateAchievement(id) {
                achievementsUnlocked.insert(id.rawValue)
                changed = true
            }
        }
        if changed {
            persistAchievements()
        }
    }

    private func evaluateAchievement(_ id: AchievementID) -> Bool {
        switch id {
        case .firstSave:
            return !galleryCreations.isEmpty
        case .collectorFive:
            return galleryCreations.count >= 5
        case .starTen:
            return totalStarsEarned >= 10
        case .starTwentyFive:
            return totalStarsEarned >= 25
        case .prismPathClear:
            return (1...5).allSatisfy { bestStars(for: .prismPlay, level: $0) >= 1 }
        case .doodlePathClear:
            return (1...5).allSatisfy { bestStars(for: .doodleDash, level: $0) >= 1 }
        case .mosaicPathClear:
            return (1...5).allSatisfy { bestStars(for: .mosaicMoments, level: $0) >= 1 }
        case .tripleMoment:
            for a in ActivityKind.allCases {
                for lv in 1...5 where bestStars(for: a, level: lv) >= 3 {
                    return true
                }
            }
            return false
        case .weeklyHero:
            return currentWeekCompletedSlotCount() >= 3
        }
    }

    private func persistCore() {
        defaults.set(Self.encodeDictionary(starsByChallengeKey), forKey: Keys.starsDictionary)
        defaults.set(Self.encodeSet(completedChallengeKeys), forKey: Keys.completedChallengesSet)
        defaults.set(totalDrawingLengthPoints, forKey: Keys.totalDrawingLength)
        defaults.set(totalColorsUsedCount, forKey: Keys.totalColorsUsed)
        defaults.set(totalPrismLayersCount, forKey: Keys.totalPrismLayers)
        defaults.set(unlockedPaletteTier, forKey: Keys.unlockedPaletteTier)
        objectWillChange.send()
    }

    private func persistGalleryOnly() {
        defaults.set(Self.encodeGallery(galleryCreations), forKey: Keys.galleryCreations)
        objectWillChange.send()
    }

    private func persistAchievements() {
        defaults.set(Self.encodeSet(achievementsUnlocked), forKey: Keys.achievementsUnlocked)
        objectWillChange.send()
    }

    private func persistWeekly() {
        defaults.set(Self.encodeSet(weeklyCompletions), forKey: Keys.weeklyCompletions)
        objectWillChange.send()
    }

    static func challengeKey(activity: ActivityKind, level: Int) -> String {
        "\(activity.rawValue)_level_\(level)"
    }

    private static func decodeDictionary(_ string: String?) -> [String: Int] {
        guard let data = string?.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return dict
    }

    private static func encodeDictionary(_ dict: [String: Int]) -> String {
        guard let data = try? JSONEncoder().encode(dict),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    private static func decodeSet(_ string: String?) -> Set<String> {
        guard let data = string?.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(array)
    }

    private static func encodeSet(_ set: Set<String>) -> String {
        let array = Array(set)
        guard let data = try? JSONEncoder().encode(array),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }

    private static func decodeGallery(_ string: String?) -> [CreationRecord] {
        guard let data = string?.data(using: .utf8),
              let items = try? JSONDecoder().decode([CreationRecord].self, from: data) else {
            return []
        }
        return items
    }

    private static func encodeGallery(_ items: [CreationRecord]) -> String {
        guard let data = try? JSONEncoder().encode(items),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }
}
