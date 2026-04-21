import SwiftUI

struct DiscoverTabView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @EnvironmentObject private var feed: DiscoverFeed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Discover")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("Live tiles remix hues from the community pulse—tap to refresh the field.")
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Visual theme")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(DiscoverVisualTheme.allCases) { theme in
                                Button {
                                    feed.applyTheme(theme)
                                } label: {
                                    Text(theme.title)
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .foregroundStyle(feed.visualTheme == theme ? Color.appBackground : Color.appTextPrimary)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    feed.visualTheme == theme
                                                        ? LinearGradient(
                                                            colors: [Color.appPrimary, Color.appPrimary.opacity(0.78)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                        : LinearGradient(
                                                            colors: [Color.appSurface.opacity(0.88), Color.appSurface.opacity(0.62)],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                )
                                        )
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(
                                                    feed.visualTheme == theme
                                                        ? Color.white.opacity(0.35)
                                                        : Color.appPrimary.opacity(0.15),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(
                                            color: feed.visualTheme == theme ? Color.appPrimary.opacity(0.35) : Color.appTextPrimary.opacity(0.06),
                                            radius: feed.visualTheme == theme ? 12 : 6,
                                            y: 4
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(14)
                .appElevatedCardStyle(cornerRadius: 18)

                Canvas { context, size in
                    let cols = 3
                    let tileW = size.width / CGFloat(cols)
                    let tileH = 96.0
                    for (idx, item) in feed.tiles.enumerated() {
                        let r = idx / cols
                        let c = idx % cols
                        let rect = CGRect(x: CGFloat(c) * tileW, y: CGFloat(r) * tileH, width: tileW - 8, height: tileH - 8)
                        let pick = feed.tileColor(for: item, tileIndex: idx)
                        let path = Path(roundedRect: rect, cornerRadius: 14, style: .continuous)
                        context.fill(path, with: .color(pick.opacity(item.density)))
                        context.stroke(path, with: .color(Color.appAccent.opacity(0.45 + 0.35 * item.pulse)), lineWidth: 2)
                    }
                }
                .frame(height: 4 * 96)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .appCanvasWell(cornerRadius: 22)

                Button {
                    feed.regenerate()
                } label: {
                    Text("Shuffle Tiles")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Spotlight stats")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Total stars collected: \(store.totalStarsEarned)")
                        .foregroundStyle(Color.appTextSecondary)
                    Text("Finished runs: \(store.completedActivitiesCount)")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedCardStyle(cornerRadius: 20)
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
    }
}
