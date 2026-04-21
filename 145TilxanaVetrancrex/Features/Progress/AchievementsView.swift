import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: PhotoFlowData

    var body: some View {
        List {
            Section {
                Text(store.achievementProgressSummary())
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppChrome.cardSurfaceGradient)
                            .padding(4)
                    )
            }

            Section {
                ForEach(AchievementID.allCases) { id in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: store.isAchievementUnlocked(id) ? "checkmark.seal.fill" : "seal")
                            .font(.title2)
                            .foregroundStyle(store.isAchievementUnlocked(id) ? Color.appAccent : Color.appTextSecondary.opacity(0.6))
                            .shadow(color: store.isAchievementUnlocked(id) ? Color.appAccent.opacity(0.45) : .clear, radius: 10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(id.title)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text(id.detail)
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppChrome.cardSurfaceGradient)
                            .shadow(color: Color.appTextPrimary.opacity(0.07), radius: 12, y: 6)
                            .padding(4)
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appScreenBackdrop()
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
