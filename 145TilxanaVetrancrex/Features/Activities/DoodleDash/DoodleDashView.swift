import SwiftUI

struct DoodleDashView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @StateObject private var model: DoodleDashViewModel
    @Binding var path: [CreateNavRoute]

    let level: Int
    let difficulty: ActivityDifficulty

    @State private var lastCanvasSize = CGSize(width: 320, height: 320)

    init(level: Int, difficulty: ActivityDifficulty, path: Binding<[CreateNavRoute]>) {
        self.level = level
        self.difficulty = difficulty
        _path = path
        _model = StateObject(wrappedValue: DoodleDashViewModel(difficulty: difficulty, level: level))
    }

    private var palette: [Color] {
        [
            Color.appPrimary,
            Color.appAccent,
            Color.appTextPrimary,
            Color.appSurface
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                brushPicker

                colorRow

                canvas

                controls
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .alert("Heads up", isPresented: Binding(get: {
            model.alertMessage != nil
        }, set: { newValue in
            if !newValue { model.alertMessage = nil }
        })) {
            Button("OK", role: .cancel) { model.alertMessage = nil }
        } message: {
            Text(model.alertMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Doodle Dash")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            HStack {
                Text("Lives")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(model.livesRemaining)")
                    .font(.headline)
                    .foregroundStyle(Color.appAccent)
            }
        }
    }

    private var brushPicker: some View {
        Picker("Brush", selection: $model.brushIndex) {
            Text("Ink").tag(0)
            Text("Glow").tag(1)
            Text("Bold").tag(2)
        }
        .pickerStyle(.segmented)
        .appSegmentedShell()
    }

    private var colorRow: some View {
        HStack(spacing: 12) {
            ForEach(Array(palette.enumerated()), id: \.offset) { idx, color in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        model.colorIndex = idx
                    }
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.appPrimary.opacity(0.18), radius: model.colorIndex == idx ? 10 : 4, y: 4)
                        .overlay(
                            Circle()
                                .stroke(Color.appTextPrimary.opacity(model.colorIndex == idx ? 0.9 : 0.0), lineWidth: 3)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var canvas: some View {
        GeometryReader { geo in
            ZStack {
                Canvas { context, size in
                    for rect in model.obstacleRects {
                        let r = CGRect(
                            x: rect.origin.x * size.width,
                            y: rect.origin.y * size.height,
                            width: rect.size.width * size.width,
                            height: rect.size.height * size.height
                        )
                        context.fill(Path(roundedRect: r, cornerRadius: 8), with: .color(Color.appPrimary.opacity(0.18)))
                        context.stroke(Path(roundedRect: r, cornerRadius: 8), with: .color(Color.appAccent.opacity(0.45)), lineWidth: 2)
                    }

                    for stroke in model.strokes {
                        var path = Path()
                        let pts = stroke.points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
                        guard let first = pts.first else { continue }
                        path.move(to: first)
                        for p in pts.dropFirst() {
                            path.addLine(to: p)
                        }
                        let color = stroke.colorIndex >= 0 && stroke.colorIndex < palette.count
                            ? palette[stroke.colorIndex]
                            : Color.appPrimary
                        context.stroke(
                            path,
                            with: .color(color.opacity(stroke.brush == 1 ? 0.75 : 1.0)),
                            style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
                        )
                    }

                    if model.livePoints.count > 1 {
                        var path = Path()
                        path.move(to: model.livePoints[0])
                        for p in model.livePoints.dropFirst() {
                            path.addLine(to: p)
                        }
                        let color = model.colorIndex >= 0 && model.colorIndex < palette.count
                            ? palette[model.colorIndex]
                            : Color.appPrimary
                        context.stroke(
                            path,
                            with: .color(color.opacity(model.brushIndex == 1 ? 0.75 : 1.0)),
                            style: StrokeStyle(lineWidth: liveWidth, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                .allowsHitTesting(true)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            model.appendLivePoint(value.location)
                        }
                        .onEnded { _ in
                            model.commitStroke(in: geo.size)
                        }
                )
            }
            .onAppear {
                lastCanvasSize = geo.size
            }
            .onChange(of: geo.size) { newValue in
                lastCanvasSize = newValue
            }
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .appCanvasWell(cornerRadius: 22)
    }

    private var liveWidth: CGFloat {
        switch model.brushIndex {
        case 0: return 6
        case 1: return 11
        default: return 16
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    model.undoLastStroke()
                } label: {
                    Text("Undo")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .disabled(model.strokes.isEmpty)

                Button {
                    model.reset(difficulty: difficulty)
                } label: {
                    Text("Clear")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
            }

            Button {
                finish(in: lastCanvasSize)
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

    private func finish(in size: CGSize) {
        guard !model.strokes.isEmpty else {
            model.alertMessage = "Sketch at least one stroke."
            return
        }
        guard model.livesRemaining > 0 || model.strokes.count >= 3 else {
            model.alertMessage = "Lives depleted—clear and try smoother paths."
            return
        }
        let stars = model.starRating(level: level, difficulty: difficulty)
        let safeStars = max(1, stars)
        let previous = store.bestStars(for: .doodleDash, level: level)
        let isNew = safeStars > previous
        let length = Int(model.totalLength(in: size))
        let colorsUsed = Set(model.strokes.map { $0.colorIndex }).count

        store.recordCompletion(
            activity: .doodleDash,
            level: level,
            stars: safeStars,
            drawingLengthDelta: Double(length),
            colorsUsedDelta: colorsUsed,
            prismLayersDelta: 0
        )

        let outcome = ActivityOutcome(
            activity: .doodleDash,
            level: level,
            difficulty: difficulty,
            stars: safeStars,
            colorsUsed: colorsUsed,
            drawingLengthPoints: length,
            coveragePercent: min(100, model.strokes.count * 8),
            blocksPlaced: 0,
            isNewRecord: isNew
        )

        let stored = model.strokes.map { stroke in
            StoredStroke(
                points: stroke.points.map { StrokePoint(x: Double($0.x), y: Double($0.y)) },
                colorIndex: stroke.colorIndex,
                brush: stroke.brush,
                width: Double(stroke.width)
            )
        }
        let record = CreationRecord(
            kind: .doodleSnapshot,
            starsSnapshot: safeStars,
            title: "Doodle pass",
            strokes: stored,
            prismLayers: [],
            mosaicBlocks: [],
            accentHue: 0.52
        )
        store.addGalleryCreation(record)

        path.append(.outcome(outcome))
    }
}
