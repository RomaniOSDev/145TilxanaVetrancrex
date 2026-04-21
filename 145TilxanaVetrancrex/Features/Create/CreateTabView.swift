import SwiftUI

enum CreateStudioTool: String, CaseIterable, Identifiable {
    case brush
    case ribbon
    case stamp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .brush: return "Brush"
        case .ribbon: return "Ribbon"
        case .stamp: return "Stamp"
        }
    }
}

struct CreateTabView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @Binding var path: [CreateNavRoute]
    @Binding var showSettings: Bool

    @State private var tool: CreateStudioTool = .brush
    @State private var colorIndex = 0
    @State private var strokes: [StoredStroke] = []
    @State private var livePoints: [CGPoint] = []
    @State private var strokeUndoPast: [[StoredStroke]] = []
    @State private var strokeUndoFuture: [[StoredStroke]] = []

    private let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    private var palette: [Color] {
        var base: [Color] = [
            Color.appPrimary,
            Color.appAccent,
            Color.appTextPrimary,
            Color.appSurface
        ]
        if store.unlockedPaletteTier >= 1 {
            base.append(Color.appAccent.opacity(0.85))
        }
        if store.unlockedPaletteTier >= 2 {
            base.append(Color.appPrimary.opacity(0.75))
        }
        if store.unlockedPaletteTier >= 3 {
            base.append(Color.appSurface.opacity(0.95))
        }
        return base
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Studio")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Picker("Tool", selection: $tool) {
                    ForEach(CreateStudioTool.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .appSegmentedShell()

                ZStack {
                    Canvas { context, size in
                        for stroke in strokes {
                            var path = Path()
                            let pts = stroke.points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
                            guard let first = pts.first else { continue }
                            path.move(to: first)
                            for p in pts.dropFirst() {
                                path.addLine(to: p)
                            }
                            context.stroke(
                                path,
                                with: .color(paletteColor(at: stroke.colorIndex)),
                                style: StrokeStyle(
                                    lineWidth: CGFloat(stroke.width),
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        }

                        if livePoints.count > 1 {
                            var path = Path()
                            let pts = livePoints
                            path.move(to: pts[0])
                            for p in pts.dropFirst() {
                                path.addLine(to: p)
                            }
                            context.stroke(
                                path,
                                with: .color(paletteColor(at: colorIndex)),
                                style: StrokeStyle(lineWidth: liveLineWidth, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .appCanvasWell(cornerRadius: 22)
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard geo.size.width > 1, geo.size.height > 1 else { return }
                                        livePoints.append(value.location)
                                    }
                                    .onEnded { _ in
                                        finishStroke(in: geo.size)
                                    }
                            )
                    }
                )

                HStack(spacing: 12) {
                    ForEach(Array(palette.enumerated()), id: \.offset) { idx, color in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                colorIndex = idx
                            }
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.appPrimary.opacity(0.2), radius: colorIndex == idx ? 8 : 3, y: 3)
                                .overlay(
                                    Circle()
                                        .stroke(Color.appTextPrimary.opacity(colorIndex == idx ? 0.9 : 0.0), lineWidth: 3)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button {
                            undoStrokes()
                        } label: {
                            Text("Undo")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .disabled(strokeUndoPast.isEmpty)

                        Button {
                            redoStrokes()
                        } label: {
                            Text("Redo")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .disabled(strokeUndoFuture.isEmpty)
                    }

                    HStack(spacing: 12) {
                        Button(role: .destructive) {
                            withAnimation(spring) {
                                strokes.removeAll()
                                livePoints.removeAll()
                                strokeUndoPast.removeAll()
                                strokeUndoFuture.removeAll()
                            }
                        } label: {
                            Text("Clear")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            saveCreation()
                        } label: {
                            Text("Save Piece")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.appPrimary)
                    }
                }

                Button {
                    path.append(.challenges)
                } label: {
                    Text("Creative Challenges")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appAccent)

                Text(store.collectionSummaryLine)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarHidden(true)
        .onAppear {
            loadStudioDraftIfNeeded()
        }
    }

    private var liveLineWidth: CGFloat {
        switch tool {
        case .brush: return 7
        case .ribbon: return 12
        case .stamp: return 18
        }
    }

    private func paletteColor(at index: Int) -> Color {
        guard index >= 0, index < palette.count else { return Color.appPrimary }
        return palette[index]
    }

    private func finishStroke(in size: CGSize) {
        defer { livePoints.removeAll() }
        guard size.width > 0, size.height > 0, livePoints.count > 1 else { return }
        let normalized = livePoints.map { StrokePoint(x: Double($0.x / size.width), y: Double($0.y / size.height)) }
        let brushIndex: Int
        switch tool {
        case .brush: brushIndex = 0
        case .ribbon: brushIndex = 1
        case .stamp: brushIndex = 2
        }
        let stroke = StoredStroke(
            points: normalized,
            colorIndex: colorIndex,
            brush: brushIndex,
            width: Double(liveLineWidth)
        )
        withAnimation(spring) {
            strokeUndoPast.append(strokes)
            strokeUndoFuture.removeAll()
            strokes.append(stroke)
        }
    }

    private func undoStrokes() {
        guard let previous = strokeUndoPast.popLast() else { return }
        strokeUndoFuture.append(strokes)
        strokes = previous
        livePoints.removeAll()
    }

    private func redoStrokes() {
        guard let next = strokeUndoFuture.popLast() else { return }
        strokeUndoPast.append(strokes)
        strokes = next
        livePoints.removeAll()
    }

    private func loadStudioDraftIfNeeded() {
        guard let draft = store.takeFreeformStudioDraft() else { return }
        strokes = draft.strokes
        strokeUndoPast.removeAll()
        strokeUndoFuture.removeAll()
        livePoints.removeAll()
        if let last = draft.strokes.last {
            colorIndex = min(last.colorIndex, max(0, palette.count - 1))
        }
    }

    private func saveCreation() {
        let record = CreationRecord(
            kind: .freeform,
            starsSnapshot: min(3, max(1, strokes.count / 4 + 1)),
            title: "Studio sketch",
            strokes: strokes,
            prismLayers: [],
            mosaicBlocks: [],
            accentHue: 0.42
        )
        store.addGalleryCreation(record)
    }
}
