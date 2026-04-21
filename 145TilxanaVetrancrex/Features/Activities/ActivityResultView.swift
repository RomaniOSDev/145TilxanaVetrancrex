import SwiftUI

struct ActivityResultView: View {
    let model: ActivityOutcome
    @Binding var path: [CreateNavRoute]

    @State private var starScale: CGFloat = 0.4
    @State private var bannerOffset: CGFloat = -200

    private let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Run complete")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if model.isNewRecord {
                    newRecordBanner
                }

                HStack(alignment: .top, spacing: 16) {
                    resultPreview
                        .frame(width: 120, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .appCanvasWell(cornerRadius: 16)

                    VStack(alignment: .leading, spacing: 10) {
                        statRow(title: "Stars", value: "\(model.stars)")
                        statRow(title: "Colors used", value: "\(model.colorsUsed)")
                        statRow(title: "Stroke span", value: "\(model.drawingLengthPoints) pts")
                        statRow(title: "Coverage", value: "\(model.coveragePercent)%")
                        statRow(title: "Tiles placed", value: "\(model.blocksPlaced)")
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appElevatedCardStyle(cornerRadius: 18)
                }

                starRow

                VStack(spacing: 12) {
                    Button {
                        viewProgress()
                    } label: {
                        Text("View Progress")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.appPrimary)

                    Button {
                        createAgain()
                    } label: {
                        Text("Create Again")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.appAccent)
                }
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(spring) {
                starScale = 1.0
            }
            if model.isNewRecord {
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                    bannerOffset = 0
                }
            }
        }
    }

    private var newRecordBanner: some View {
        Text("New best score on this stage")
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.35), Color.appPrimary.opacity(0.28)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: Color.appAccent.opacity(0.55), radius: 22, y: 10)
                    .shadow(color: Color.appPrimary.opacity(0.25), radius: 32, y: 14)
            )
            .offset(y: bannerOffset)
    }

    private var resultPreview: some View {
        Canvas { context, size in
            let gradient = Gradient(colors: [Color.appPrimary.opacity(0.65), Color.appAccent.opacity(0.55)])
            context.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 16),
                with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height))
            )

            for idx in 0..<model.stars {
                let x = size.width * (0.25 + CGFloat(idx) * 0.2)
                let y = size.height * 0.45
                var star = Path()
                star.addEllipse(in: CGRect(x: x - 10, y: y - 10, width: 20, height: 20))
                context.fill(star, with: .color(Color.appTextPrimary.opacity(0.85)))
            }
        }
    }

    private var starRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { idx in
                Image(systemName: idx < model.stars ? "star.fill" : "star")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(idx < model.stars ? Color.appAccent : Color.appTextSecondary.opacity(0.65))
                    .scaleEffect(starScale)
                    .shadow(color: idx < model.stars ? Color.appAccent.opacity(0.65) : .clear, radius: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func statRow(title: String, value: String) -> some View {
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

    private func viewProgress() {
        path = [.challenges]
    }

    private func createAgain() {
        if case .outcome = path.last {
            path.removeLast()
        }
        if !path.isEmpty {
            path.removeLast()
        }
        switch model.activity {
        case .prismPlay:
            path.append(.prism(level: model.level, difficulty: model.difficulty))
        case .doodleDash:
            path.append(.doodle(level: model.level, difficulty: model.difficulty))
        case .mosaicMoments:
            path.append(.mosaic(level: model.level, difficulty: model.difficulty))
        }
    }
}
