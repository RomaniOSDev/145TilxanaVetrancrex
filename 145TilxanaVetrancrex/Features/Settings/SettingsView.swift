import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @Environment(\.dismiss) private var dismiss

    @State private var confirmReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Insights")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                VStack(alignment: .leading, spacing: 10) {
                    statLine("Total stars collected", "\(store.totalStarsEarned)")
                    statLine("Finished challenge runs", "\(store.completedActivitiesCount)")
                    statLine("Saved studio pieces", "\(store.galleryCreations.count)")
                    statLine("Stroke span bank", String(format: "%.0f pts", store.totalDrawingLengthPoints))
                    statLine("Palette depth unlocked", "\(store.unlockedPaletteTier)")
                    statLine("Distinct hues logged", "\(store.totalColorsUsedCount)")
                    statLine("Prism layers logged", "\(store.totalPrismLayersCount)")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedCardStyle(cornerRadius: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text("App")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        settingsRow(
                            title: "Rate us",
                            icon: "star.fill",
                            tint: Color.appAccent,
                            showChevron: false
                        ) {
                            rateApp()
                        }

                        Divider()
                            .background(Color.appPrimary.opacity(0.15))
                            .padding(.leading, 52)

                        ForEach(Array(AppExternalURL.allCases.enumerated()), id: \.element) { index, link in
                            if index > 0 {
                                Divider()
                                    .background(Color.appPrimary.opacity(0.15))
                                    .padding(.leading, 52)
                            }
                            settingsRow(
                                title: link.title,
                                icon: link.symbolName,
                                tint: Color.appPrimary,
                                showChevron: true
                            ) {
                                openExternalURL(link)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedCardStyle(cornerRadius: 20)

                Button(role: .destructive) {
                    confirmReset = true
                } label: {
                    Text("Reset All Progress")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appSurface)

                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Reset everything?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset all data", role: .destructive) {
                store.resetAll()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears stars, boards, gallery saves, and the first-launch tour.")
        }
    }

    private func statLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private func settingsRow(
        title: String,
        icon: String,
        tint: Color,
        showChevron: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func openExternalURL(_ kind: AppExternalURL) {
        if let url = kind.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
