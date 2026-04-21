import SwiftUI

enum AppChrome {
    static let cardRadius: CGFloat = 20
    static let canvasRadius: CGFloat = 22
    static let softRadius: CGFloat = 16

    static var cardSurfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.98),
                Color.appSurface.opacity(0.72),
                Color.appBackground.opacity(0.45)
            ],
            startPoint: UnitPoint(x: 0.12, y: 0),
            endPoint: UnitPoint(x: 0.88, y: 1)
        )
    }

    static var cardRimGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.34),
                Color.appAccent.opacity(0.3),
                Color.appPrimary.opacity(0.16)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var canvasWellGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.94),
                Color.appBackground.opacity(0.58),
                Color.appSurface.opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var canvasRimGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appAccent.opacity(0.45),
                Color.appPrimary.opacity(0.22),
                Color.appAccent.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func rimGradient(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.3),
                accent.opacity(0.4),
                Color.appPrimary.opacity(0.14)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct AppScreenBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appPrimary.opacity(0.09),
                    Color.appBackground,
                    Color.appAccent.opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.appPrimary.opacity(0.17), Color.clear],
                center: UnitPoint(x: 0.92, y: 0.02),
                startRadius: 20,
                endRadius: 500
            )
            RadialGradient(
                colors: [Color.appAccent.opacity(0.14), Color.clear],
                center: UnitPoint(x: 0.05, y: 0.92),
                startRadius: 30,
                endRadius: 420
            )
        }
    }
}

extension View {
    func appScreenBackdrop() -> some View {
        background {
            AppScreenBackdrop()
                .ignoresSafeArea()
        }
    }

    func appElevatedCardStyle(cornerRadius: CGFloat = AppChrome.cardRadius, accentRim: Color? = nil) -> some View {
        let rim = accentRim.map { AppChrome.rimGradient(accent: $0) } ?? AppChrome.cardRimGradient
        return background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppChrome.cardSurfaceGradient)
                .shadow(color: Color.appPrimary.opacity(0.13), radius: 1, x: 0, y: 1)
                .shadow(color: Color.appTextPrimary.opacity(0.1), radius: 18, x: 0, y: 9)
                .shadow(color: Color.appAccent.opacity(0.08), radius: 28, x: 0, y: 20)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(rim, lineWidth: 1)
        }
    }

    func appCanvasWell(cornerRadius: CGFloat = AppChrome.canvasRadius) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppChrome.canvasWellGradient)
                .shadow(color: Color.black.opacity(0.18), radius: 0, x: 0, y: 3)
                .shadow(color: Color.appPrimary.opacity(0.09), radius: 1, x: 0, y: 1)
                .shadow(color: Color.appAccent.opacity(0.07), radius: 24, x: 0, y: -8)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(AppChrome.canvasRimGradient, lineWidth: 1.15)
        }
    }

    func appSegmentedShell(cornerRadius: CGFloat = 14) -> some View {
        padding(.vertical, 5)
            .padding(.horizontal, 5)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface.opacity(0.9), Color.appSurface.opacity(0.52)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.appTextPrimary.opacity(0.08), radius: 12, x: 0, y: 6)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), Color.appPrimary.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}
