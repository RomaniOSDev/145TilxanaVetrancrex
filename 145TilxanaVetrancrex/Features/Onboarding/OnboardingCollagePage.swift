import SwiftUI

struct OnboardingCollagePage: View {
    let step: Int
    let total: Int
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            OnboardingPageHeader(
                step: step,
                total: total,
                title: "Collage energy",
                subtitle: "Pieces snap, stack, and drift apart—your studio stays in motion."
            )

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                let cycle = (sin(t * 1.1) + 1) / 2
                GeometryReader { geo in
                    let cols = 3
                    let rows = 3
                    let w = geo.size.width / CGFloat(cols)
                    let h = geo.size.height / CGFloat(rows)
                    ZStack {
                        ForEach(0..<(cols * rows), id: \.self) { idx in
                            let r = idx / cols
                            let c = idx % cols
                            let jitter = CGFloat(sin(t * 2.0 + Double(idx))) * 10 * (1 - cycle)
                            let x = CGFloat(c) * w + jitter
                            let y = CGFloat(r) * h + CGFloat(cos(t * 1.7 + Double(idx))) * 8 * cycle
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appPrimary.opacity(0.42 + 0.06 * CGFloat(idx % 3)),
                                            Color.appAccent.opacity(0.22 + 0.05 * CGFloat(idx % 2))
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: w - 10, height: h - 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.appAccent.opacity(0.65), Color.white.opacity(0.25)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                                .shadow(color: Color.appPrimary.opacity(0.2), radius: 6, y: 3)
                                .rotationEffect(.degrees(Double(sin(t + Double(idx))) * 6))
                                .position(x: x + w / 2, y: y + h / 2)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .appCanvasWell(cornerRadius: 20)
            }

            Button(action: onStart) {
                HStack(spacing: 8) {
                    Text("Start creating")
                        .font(.headline.weight(.semibold))
                    Image(systemName: "sparkles")
                        .font(.title3.weight(.semibold))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appAccent)
            .shadow(color: Color.appAccent.opacity(0.42), radius: 20, y: 10)
            .shadow(color: Color.appPrimary.opacity(0.2), radius: 28, y: 14)
            .padding(.top, 6)
        }
        .padding(20)
        .appElevatedCardStyle(cornerRadius: 24, accentRim: Color.appAccent.opacity(0.45))
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [Color.white.opacity(0.22), Color.clear],
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
