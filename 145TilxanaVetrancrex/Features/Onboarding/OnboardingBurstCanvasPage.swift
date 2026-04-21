import SwiftUI

struct OnboardingBurstCanvasPage: View {
    let step: Int
    let total: Int

    private static let bubblePalette: [Color] = [
        Color.appPrimary,
        Color.appAccent,
        Color.appSurface,
        Color.appTextPrimary
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            OnboardingPageHeader(
                step: step,
                total: total,
                title: "Endless playfields",
                subtitle: "Float shapes, blend hues, and let curiosity lead."
            )

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { timeline in
                let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                Canvas { context, size in
                    Self.drawBurstCanvas(into: &context, size: size, t: t)
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

    private static func drawBurstCanvas(into context: inout GraphicsContext, size: CGSize, t: CGFloat) {
        let base = Color.appSurface.opacity(0.35)
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(base))

        let count = 18
        for idx in 0..<count {
            let u = Double(idx) / Double(count)
            let wobble = sin(Double(t) * 1.4 + u * 6.28) * 0.5 + 0.5
            let x = size.width * (0.12 + CGFloat(u) * 0.76)
            let y = size.height * (0.35 + 0.22 * sin(Double(t) * 0.9 + u * 4.0))
            let r = CGFloat(18 + 26 * wobble)
            let circle = Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
            let fill = bubblePalette[idx % bubblePalette.count]
            context.opacity = CGFloat(0.35 + 0.35 * wobble)
            context.fill(circle, with: .color(fill))
            context.blendMode = .plusLighter
        }

        for idx in 0..<9 {
            let u = Double(idx) / 9.0
            let rot = CGFloat(Double(t) * 0.8 + u * 0.6)
            let cx = size.width * (0.2 + CGFloat(u) * 0.6)
            let cy = size.height * 0.62
            let side: CGFloat = 34 + CGFloat(idx) * 3
            let p0 = CGPoint(x: cx, y: cy - side)
            let p1 = CGPoint(x: cx - side * 0.9, y: cy + side * 0.55)
            let p2 = CGPoint(x: cx + side * 0.9, y: cy + side * 0.55)
            let c = CGPoint(x: cx, y: cy)
            var tri = Path()
            tri.move(to: rotate(p0, around: c, angle: rot))
            tri.addLine(to: rotate(p1, around: c, angle: rot))
            tri.addLine(to: rotate(p2, around: c, angle: rot))
            tri.closeSubpath()
            context.fill(tri, with: .color(Color.appAccent.opacity(0.55)))
            context.blendMode = .screen
        }
    }

    private static func rotate(_ point: CGPoint, around center: CGPoint, angle: CGFloat) -> CGPoint {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let cosA = cos(angle)
        let sinA = sin(angle)
        return CGPoint(
            x: center.x + dx * cosA - dy * sinA,
            y: center.y + dx * sinA + dy * cosA
        )
    }
}
