import SwiftUI

struct ActivitySelectionView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @Binding var path: [CreateNavRoute]

    @State private var selectedActivity: ActivityKind?
    @State private var difficulty: ActivityDifficulty = .easy

    private let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Challenges")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                dailySection

                weeklySection

                Picker("Difficulty", selection: $difficulty) {
                    ForEach(ActivityDifficulty.allCases, id: \.self) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .appSegmentedShell()

                if let activity = selectedActivity {
                    levelSection(for: activity)
                } else {
                    Text("Pick a lane below")
                        .foregroundStyle(Color.appTextSecondary)
                }

                activityCards
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AchievementsView()
                } label: {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weekly goals")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(store.currentWeekCompletedSlotCount()) / 7")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(0..<7, id: \.self) { slot in
                    let pair = store.weeklyChallenge(slot: slot)
                    let done = store.isWeeklySlotComplete(slot: slot)
                    let unlocked = store.isLevelUnlocked(activity: pair.0, level: pair.1)
                    Button {
                        guard unlocked else { return }
                        switch pair.0 {
                        case .prismPlay:
                            path.append(.prism(level: pair.1, difficulty: difficulty))
                        case .doodleDash:
                            path.append(.doodle(level: pair.1, difficulty: difficulty))
                        case .mosaicMoments:
                            path.append(.mosaic(level: pair.1, difficulty: difficulty))
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Slot \(slot + 1)")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color.appTextSecondary)
                            Text(pair.0.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            Text("Lv \(pair.1)")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                            if done {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    done
                                        ? LinearGradient(
                                            colors: [Color.appPrimary.opacity(0.38), Color.appAccent.opacity(0.22)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [
                                                Color.appSurface.opacity(unlocked ? 0.92 : 0.45),
                                                Color.appSurface.opacity(unlocked ? 0.65 : 0.28)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    done ? Color.appAccent.opacity(0.45) : Color.appPrimary.opacity(unlocked ? 0.22 : 0.1),
                                    lineWidth: done ? 1.5 : 1
                                )
                        )
                        .shadow(color: Color.appPrimary.opacity(unlocked ? 0.12 : 0.04), radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }

            Text("Finish the highlighted activity and level to check off a slot. Clear three slots this week for the Week warrior badge.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .appElevatedCardStyle(cornerRadius: 20)
    }

    private var dailySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily spotlight")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    DailyCardView(
                        title: "Prism sprint",
                        detail: "Layer three bursts before noon",
                        tint: Color.appPrimary
                    ) {
                        selectedActivity = .prismPlay
                        path.append(.prism(level: 1, difficulty: difficulty))
                    }

                    DailyCardView(
                        title: "Ribbon rush",
                        detail: "Sketch without lifting for ten seconds",
                        tint: Color.appAccent
                    ) {
                        selectedActivity = .doodleDash
                        path.append(.doodle(level: 1, difficulty: difficulty))
                    }

                    DailyCardView(
                        title: "Grid weave",
                        detail: "Fill four slots with contrast",
                        tint: Color.appSurface
                    ) {
                        selectedActivity = .mosaicMoments
                        path.append(.mosaic(level: 1, difficulty: difficulty))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var activityCards: some View {
        VStack(spacing: 12) {
            ForEach(ActivityKind.allCases) { kind in
                Button {
                    withAnimation(spring) {
                        selectedActivity = kind
                    }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSurface.opacity(0.95), Color.appPrimary.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 54, height: 54)
                            .overlay {
                                Image(systemName: symbol(for: kind))
                                    .foregroundStyle(Color.appAccent)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.appAccent.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: Color.appPrimary.opacity(0.15), radius: 8, y: 4)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(kind.title)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            Text(kind.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(starLine(for: kind))
                                .font(.caption)
                                .foregroundStyle(Color.appAccent)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppChrome.cardSurfaceGradient)
                            .opacity(selectedActivity == kind ? 1 : 0.92)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: selectedActivity == kind
                                        ? [Color.appPrimary, Color.appAccent.opacity(0.6)]
                                        : [Color.appAccent.opacity(0.28), Color.appPrimary.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: selectedActivity == kind ? 2 : 1
                            )
                    )
                    .shadow(
                        color: selectedActivity == kind ? Color.appPrimary.opacity(0.22) : Color.appTextPrimary.opacity(0.07),
                        radius: selectedActivity == kind ? 18 : 12,
                        y: 8
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func levelSection(for activity: ActivityKind) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Levels")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(1...5, id: \.self) { level in
                    let unlocked = store.isLevelUnlocked(activity: activity, level: level)
                    let stars = store.bestStars(for: activity, level: level)
                    Button {
                        guard unlocked else { return }
                        switch activity {
                        case .prismPlay:
                            path.append(.prism(level: level, difficulty: difficulty))
                        case .doodleDash:
                            path.append(.doodle(level: level, difficulty: difficulty))
                        case .mosaicMoments:
                            path.append(.mosaic(level: level, difficulty: difficulty))
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text("Lv \(level)")
                                .font(.footnote.weight(.bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            StarRibbonView(count: stars)
                        }
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .padding(.vertical, 6)
                        .foregroundStyle(unlocked ? Color.appTextPrimary : Color.appTextSecondary.opacity(0.85))
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: unlocked
                                            ? [Color.appSurface.opacity(0.94), Color.appSurface.opacity(0.68)]
                                            : [Color.appSurface.opacity(0.42), Color.appSurface.opacity(0.28)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.appPrimary.opacity(unlocked ? 0.2 : 0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.appPrimary.opacity(unlocked ? 0.1 : 0.03), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }
        }
    }

    private func symbol(for kind: ActivityKind) -> String {
        switch kind {
        case .prismPlay: return "triangle.fill"
        case .doodleDash: return "scribble.variable"
        case .mosaicMoments: return "square.grid.3x3.fill"
        }
    }

    private func starLine(for kind: ActivityKind) -> String {
        let total = (1...5).reduce(0) { partial, level in
            partial + store.bestStars(for: kind, level: level)
        }
        return "Best stars in track: \(total)/15"
    }
}

private struct DailyCardView: View {
    let title: String
    let detail: String
    let tint: Color
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Daily")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(width: 220, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface.opacity(0.95), tint.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), tint.opacity(0.45)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: tint.opacity(0.4), radius: pressed ? 12 : 22, y: 8)
                    .shadow(color: Color.appTextPrimary.opacity(0.06), radius: 14, y: 10)
            )
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
