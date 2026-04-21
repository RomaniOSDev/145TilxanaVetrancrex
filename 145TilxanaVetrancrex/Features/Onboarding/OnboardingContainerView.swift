import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @State private var page = 0

    private let spring = Animation.spring(response: 0.42, dampingFraction: 0.78)
    private let pageCount = 3

    var body: some View {
        TabView(selection: $page) {
            OnboardingBurstCanvasPage(step: 1, total: pageCount)
                .tag(0)
            OnboardingTransformPage(step: 2, total: pageCount)
                .tag(1)
            OnboardingCollagePage(step: 3, total: pageCount, onStart: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    store.markOnboardingSeen()
                }
            })
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .padding(.top, 8)
        .appScreenBackdrop()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 18) {
                pageIndicator

                if page < 2 {
                    Button {
                        withAnimation(spring) { page += 1 }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.headline.weight(.semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3.weight(.semibold))
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.appPrimary)
                    .shadow(color: Color.appPrimary.opacity(0.38), radius: 18, y: 10)
                    .shadow(color: Color.appAccent.opacity(0.15), radius: 28, y: 14)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 26,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 26,
                        style: .continuous
                    )
                    .fill(AppChrome.cardSurfaceGradient)

                    UnevenRoundedRectangle(
                        topLeadingRadius: 26,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 26,
                        style: .continuous
                    )
                    .strokeBorder(AppChrome.cardRimGradient, lineWidth: 1)

                    LinearGradient(
                        colors: [Color.white.opacity(0.14), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 26,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 26,
                            style: .continuous
                        )
                    )
                    .allowsHitTesting(false)
                }
                .shadow(color: Color.appTextPrimary.opacity(0.12), radius: 24, y: -10)
                .shadow(color: Color.appPrimary.opacity(0.08), radius: 1, y: -1)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<pageCount, id: \.self) { idx in
                ZStack {
                    if idx == page {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appAccent.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 36, height: 10)
                            .shadow(color: Color.appPrimary.opacity(0.45), radius: 8, y: 3)
                    } else {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appTextSecondary.opacity(0.35),
                                        Color.appTextSecondary.opacity(0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 10, height: 10)
                    }
                }
                .animation(spring, value: page)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(page + 1) of \(pageCount)")
    }
}
