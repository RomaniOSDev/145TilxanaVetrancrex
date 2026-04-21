import SwiftUI

struct OnboardingTransformPage: View {
    let step: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            OnboardingPageHeader(
                step: step,
                total: total,
                title: "Shape the frame",
                subtitle: "Filters and overlays turn a simple frame into a scene."
            )

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                Canvas { context, size in
                    let rect = CGRect(origin: .zero, size: size)
                    let baseGradient = Gradient(colors: [
                        Color.appBackground,
                        Color.appSurface,
                        Color.appPrimary.opacity(0.35)
                    ])
                    context.fill(Path(rect), with: .linearGradient(
                        baseGradient,
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    ))

                    let wave = 0.5 + 0.5 * sin(t * 2.0)
                    for idx in 0..<6 {
                        let u = CGFloat(idx) / 5.0
                        let inset = 26 + u * 18 + wave * 10
                        let ring = Path(roundedRect: rect.insetBy(dx: inset, dy: inset * 0.9), cornerRadius: 22)
                        context.stroke(
                            ring,
                            with: .color(Color.appAccent.opacity(0.35 + 0.25 * u)),
                            lineWidth: 3
                        )
                    }

                    let blobCount = 7
                    for idx in 0..<blobCount {
                        let u = Double(idx) / Double(blobCount)
                        let cx = size.width * (0.15 + CGFloat(u) * 0.7)
                        let cy = size.height * (0.35 + 0.12 * sin(t * 1.6 + CGFloat(u) * 5.0))
                        let rx = 40 + 18 * sin(t + CGFloat(u) * 3.0)
                        let ry = 26 + 14 * cos(t * 1.1 + CGFloat(u) * 2.0)
                        let oval = Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
                        context.fill(oval, with: .color(Color.appPrimary.opacity(0.25 + 0.25 * CGFloat(u))))
                        context.blendMode = .overlay
                    }
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .appCanvasWell(cornerRadius: 20)
            }
        }
        .padding(20)
        .appElevatedCardStyle(cornerRadius: 24)
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [Color.white.opacity(0.2), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .allowsHitTesting(false)
        }
        .padding(.horizontal, 18)
    }
}
