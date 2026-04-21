import SwiftUI
import PhotosUI

struct PrismPlayView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @StateObject private var model = PrismPlayViewModel()
    @Binding var path: [CreateNavRoute]

    let level: Int
    let difficulty: ActivityDifficulty

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Prism Play")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("Pick a frame, drag to drop prisms. Overlap hues for richer splits.")
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                PhotosPicker(selection: $model.pickerItem, matching: .images) {
                    Text(model.baseData == nil ? "Choose frame" : "Replace frame")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appPrimary)
                .onChange(of: model.pickerItem) { _ in
                    Task { await model.consumePickerSelection() }
                }

                GeometryReader { geo in
                    ZStack {
                        if let data = model.baseData, let cgImage = CGImageDecode.image(from: data) {
                            Image(decorative: cgImage, scale: 1, orientation: .up)
                                .resizable()
                                .scaledToFit()
                                .overlay {
                                    Canvas { context, size in
                                        for burst in model.bursts {
                                            let rect = CGRect(
                                                x: (burst.cx - burst.radius) * size.width,
                                                y: (burst.cy - burst.radius) * size.height,
                                                width: burst.radius * 2 * size.width,
                                                height: burst.radius * 2 * size.height
                                            )
                                            let path = Path(ellipseIn: rect)
                                            let colors = Gradient(colors: [
                                                Color.appPrimary.opacity(0.55 + 0.25 * burst.hueShift),
                                                Color.appAccent.opacity(0.65 + 0.15 * (1 - burst.hueShift)),
                                                Color.appSurface.opacity(0.45 + 0.2 * burst.hueShift)
                                            ])
                                            context.fill(
                                                path,
                                                with: .radialGradient(
                                                    colors,
                                                    center: CGPoint(x: burst.cx * size.width, y: burst.cy * size.height),
                                                    startRadius: 2,
                                                    endRadius: max(rect.width, rect.height)
                                                )
                                            )
                                            context.blendMode = .screen
                                            context.blendMode = .normal
                                        }

                                        if let tip = model.dragTip {
                                            let guide = Path(ellipseIn: CGRect(x: tip.x - 10, y: tip.y - 10, width: 20, height: 20))
                                            context.stroke(guide, with: .color(Color.appTextPrimary.opacity(0.35)), lineWidth: 2)
                                        }
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                model.dragTip = value.location
                                            }
                                            .onEnded { value in
                                                model.addBurst(at: value.location, in: geo.size, difficulty: difficulty, level: level)
                                                model.dragTip = nil
                                            }
                                    )
                                }
                        } else {
                            Text("Select a frame to begin")
                                .foregroundStyle(Color.appTextSecondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .frame(height: 340)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .appCanvasWell(cornerRadius: 22)

                if !model.bursts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Layers")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(model.bursts.enumerated()), id: \.element.id) { index, burst in
                                    HStack(spacing: 8) {
                                        Text("Prism \(index + 1)")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Color.appTextPrimary)
                                            .lineLimit(1)
                                        Button {
                                            model.removeBurst(id: burst.id)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(Color.appTextSecondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .appElevatedCardStyle(cornerRadius: 12)
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        model.resetSession()
                    } label: {
                        Text("Reset prisms")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        finish()
                    } label: {
                        Text("Finish run")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.appAccent)
                }
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .alert("Keep going", isPresented: Binding(get: {
            model.alertMessage != nil
        }, set: { newValue in
            if !newValue { model.alertMessage = nil }
        })) {
            Button("OK", role: .cancel) { model.alertMessage = nil }
        } message: {
            Text(model.alertMessage ?? "")
        }
    }

    private func finish() {
        guard model.baseData != nil else {
            model.alertMessage = "Select a frame first."
            return
        }
        guard !model.bursts.isEmpty else {
            model.alertMessage = "Add at least one prism."
            return
        }
        let stars = model.starRating(level: level, difficulty: difficulty)
        let previous = store.bestStars(for: .prismPlay, level: level)
        let isNew = stars > previous
        let coverage = Int(model.coverageScore() * 100)
        let colorsUsed = model.uniqueColorBuckets()
        let lengthPoints = 0

        store.recordCompletion(
            activity: .prismPlay,
            level: level,
            stars: stars,
            drawingLengthDelta: Double(lengthPoints),
            colorsUsedDelta: colorsUsed,
            prismLayersDelta: model.bursts.count
        )

        let outcome = ActivityOutcome(
            activity: .prismPlay,
            level: level,
            difficulty: difficulty,
            stars: stars,
            colorsUsed: colorsUsed,
            drawingLengthPoints: lengthPoints,
            coveragePercent: coverage,
            blocksPlaced: 0,
            isNewRecord: isNew
        )

        let snapshot = model.bursts.map {
            StoredPrismLayer(cx: $0.cx, cy: $0.cy, radius: $0.radius, hueShift: $0.hueShift)
        }
        let record = CreationRecord(
            kind: .prismSnapshot,
            starsSnapshot: stars,
            title: "Prism run",
            strokes: [],
            prismLayers: snapshot,
            mosaicBlocks: [],
            accentHue: model.bursts.last?.hueShift ?? 0.4
        )
        store.addGalleryCreation(record)

        path.append(.outcome(outcome))
    }
}
