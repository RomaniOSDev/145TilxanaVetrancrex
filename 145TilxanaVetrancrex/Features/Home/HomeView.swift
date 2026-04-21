import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @EnvironmentObject private var discoverFeed: DiscoverFeed

    @Binding var selectedTab: AppTab
    @Binding var createPath: [CreateNavRoute]
    @Binding var showSettings: Bool

    private let widgetCorner: CGFloat = 22
    private let spring = Animation.spring(response: 0.45, dampingFraction: 0.82)
    private let shortcutDifficulty = ActivityDifficulty.easy

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    statsRow

                    quickActionsRow

                    weeklyWidget

                    achievementsWidget

                    discoverWidget

                    galleryWidget
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .appScreenBackdrop()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: widgetCorner + 4, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.45),
                            Color.appAccent.opacity(0.28),
                            Color.appSurface.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: widgetCorner + 4, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.appAccent.opacity(0.4), Color.appPrimary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: widgetCorner + 4, style: .continuous))
                    .allowsHitTesting(false)
                }

            VStack(alignment: .leading, spacing: 14) {
                Text(greetingLine)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.9))

                Text("Your creative hub")
                    .font(.title.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(store.collectionSummaryLine)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)

                HStack(spacing: 12) {
                    Button {
                        openStudio()
                    } label: {
                        Label("Studio", systemImage: "paintbrush.pointed.fill")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.appPrimary)

                    Button {
                        openChallenges()
                    } label: {
                        Label("Play", systemImage: "flag.checkered")
                            .font(.subheadline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(22)
        }
        .frame(minHeight: 200)
        .shadow(color: Color.appPrimary.opacity(0.2), radius: 8, y: 4)
        .shadow(color: Color.appTextPrimary.opacity(0.1), radius: 28, y: 16)
        .shadow(color: Color.appAccent.opacity(0.14), radius: 42, y: 22)
    }

    private var greetingLine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let phrase: String
        switch hour {
        case 5..<12: phrase = "Good morning"
        case 12..<17: phrase = "Good afternoon"
        case 17..<22: phrase = "Good evening"
        default: phrase = "Hello"
        }
        return "\(phrase) · keep the flow"
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            HomeStatPill(
                title: "Stars",
                value: "\(store.totalStarsEarned)",
                icon: "star.fill",
                tint: Color.appAccent
            )
            HomeStatPill(
                title: "Gallery",
                value: "\(store.galleryCreations.count)",
                icon: "square.grid.2x2.fill",
                tint: Color.appPrimary
            )
            HomeStatPill(
                title: "Done",
                value: "\(store.completedActivitiesCount)",
                icon: "checkmark.circle.fill",
                tint: Color.appTextPrimary.opacity(0.85)
            )
        }
    }

    // MARK: - Quick actions

    private var quickActionsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            widgetSectionTitle("Shortcuts")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                HomeShortcutTile(
                    title: "Gallery wall",
                    subtitle: "Browse saves",
                    icon: "photo.on.rectangle.angled",
                    accent: Color.appPrimary
                ) {
                    withAnimation(spring) {
                        selectedTab = .gallery
                    }
                }

                HomeShortcutTile(
                    title: "Discover",
                    subtitle: "Live mosaic",
                    icon: "sparkles",
                    accent: Color.appAccent
                ) {
                    withAnimation(spring) {
                        selectedTab = .discover
                    }
                }
            }
        }
    }

    // MARK: - Weekly

    private var weeklyWidget: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                widgetSectionTitle("This week")
                Spacer()
                Text("\(store.currentWeekCompletedSlotCount())/7")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.appAccent.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.appPrimary.opacity(0.12), radius: 10, y: 4)
            }

            Text("Tap a slot to jump in with \(shortcutDifficulty.title) difficulty.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<7, id: \.self) { slot in
                        weeklySlotDot(slot: slot)
                            .frame(minWidth: 48)
                    }
                }
                .padding(.vertical, 2)
            }

            Button {
                openChallenges()
            } label: {
                Text("View all challenges")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
        .padding(18)
        .appElevatedCardStyle(cornerRadius: widgetCorner)
    }

    private func weeklySlotDot(slot: Int) -> some View {
        let pair = store.weeklyChallenge(slot: slot)
        let done = store.isWeeklySlotComplete(slot: slot)
        let unlocked = store.isLevelUnlocked(activity: pair.0, level: pair.1)

        return Button {
            openWeeklySlot(slot)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            done
                                ? Color.appAccent.opacity(0.35)
                                : Color.appSurface.opacity(unlocked ? 0.95 : 0.4)
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    done
                                        ? LinearGradient(
                                            colors: [Color.appAccent, Color.appPrimary.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [
                                                Color.appPrimary.opacity(unlocked ? 0.55 : 0.22),
                                                Color.appAccent.opacity(unlocked ? 0.25 : 0.1)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                    lineWidth: done ? 2 : 1
                                )
                        )
                        .shadow(color: Color.appPrimary.opacity(unlocked ? 0.12 : 0.04), radius: 8, y: 4)
                    if done {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                    } else {
                        Image(systemName: symbol(for: pair.0))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(unlocked ? Color.appTextPrimary : Color.appTextSecondary.opacity(0.5))
                    }
                }
                Text("\(slot + 1)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }

    // MARK: - Achievements

    private var achievementsWidget: some View {
        VStack(alignment: .leading, spacing: 14) {
            widgetSectionTitle("Achievements")

            let total = AchievementID.allCases.count
            let unlocked = AchievementID.allCases.filter { store.isAchievementUnlocked($0) }.count
            let ratio = total > 0 ? Double(unlocked) / Double(total) : 0

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.appSurface.opacity(0.9), lineWidth: 8)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: ratio)
                        .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    Text("\(unlocked)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(unlocked) of \(total) unlocked")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Finish runs, save pieces, and clear weekly goals.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            NavigationLink {
                AchievementsView()
            } label: {
                HStack {
                    Text("Open achievements")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.appTextPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .appElevatedCardStyle(cornerRadius: 14, accentRim: Color.appAccent.opacity(0.5))
            }
        }
        .padding(18)
        .appElevatedCardStyle(cornerRadius: widgetCorner)
    }

    // MARK: - Discover preview

    private var discoverWidget: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                widgetSectionTitle("Discover pulse")
                Spacer()
                Button {
                    discoverFeed.regenerate()
                } label: {
                    Label("Shuffle", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 8) {
                ForEach(Array(discoverFeed.tiles.prefix(6))) { tile in
                    let idx = discoverFeed.tiles.firstIndex(where: { $0.id == tile.id }) ?? 0
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(discoverFeed.tileColor(for: tile, tileIndex: idx).opacity(0.25 + tile.density * 0.65))
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.appAccent.opacity(0.2 + tile.pulse * 0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.appPrimary.opacity(0.1 + tile.pulse * 0.12), radius: 10, y: 5)
                }
            }

            Button {
                withAnimation(spring) {
                    selectedTab = .discover
                }
            } label: {
                Text("Open full board")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appPrimary)
        }
        .padding(18)
        .appElevatedCardStyle(cornerRadius: widgetCorner)
    }

    // MARK: - Gallery strip

    @ViewBuilder
    private var galleryWidget: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                widgetSectionTitle("Recent saves")
                Spacer()
                if !store.galleryCreations.isEmpty {
                    Button {
                        withAnimation(spring) {
                            selectedTab = .gallery
                        }
                    } label: {
                        Text("See all")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }

            if store.galleryCreations.isEmpty {
                Text("Nothing here yet—sketch in Studio or finish a challenge.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.galleryCreations.prefix(8)) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                CreationPreviewCard(record: record)
                                    .frame(width: 108, height: 108)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color.appPrimary.opacity(0.14), radius: 12, x: 0, y: 8)
                                    .overlay(alignment: .topTrailing) {
                                        if record.isFavorite {
                                            Image(systemName: "heart.fill")
                                                .font(.caption2)
                                                .foregroundStyle(Color.appAccent)
                                                .padding(6)
                                        }
                                    }

                                Text(record.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                            }
                            .frame(width: 108)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(18)
        .appElevatedCardStyle(cornerRadius: widgetCorner)
    }

    // MARK: - Chrome

    private func widgetSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
    }

    // MARK: - Navigation helpers

    private func openStudio() {
        createPath = []
        withAnimation(spring) {
            selectedTab = .create
        }
    }

    private func openChallenges() {
        createPath = [.challenges]
        withAnimation(spring) {
            selectedTab = .create
        }
    }

    private func openWeeklySlot(_ slot: Int) {
        let pair = store.weeklyChallenge(slot: slot)
        guard store.isLevelUnlocked(activity: pair.0, level: pair.1) else { return }
        switch pair.0 {
        case .prismPlay:
            createPath = [.prism(level: pair.1, difficulty: shortcutDifficulty)]
        case .doodleDash:
            createPath = [.doodle(level: pair.1, difficulty: shortcutDifficulty)]
        case .mosaicMoments:
            createPath = [.mosaic(level: pair.1, difficulty: shortcutDifficulty)]
        }
        withAnimation(spring) {
            selectedTab = .create
        }
    }

    private func symbol(for kind: ActivityKind) -> String {
        switch kind {
        case .prismPlay: return "triangle.fill"
        case .doodleDash: return "scribble.variable"
        case .mosaicMoments: return "square.grid.3x3.fill"
        }
    }
}

// MARK: - Subviews

private struct HomeStatPill: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appElevatedCardStyle(cornerRadius: 18, accentRim: tint)
    }
}

private struct HomeShortcutTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(accent)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .appElevatedCardStyle(cornerRadius: 20, accentRim: accent)
        }
        .buttonStyle(.plain)
    }
}
