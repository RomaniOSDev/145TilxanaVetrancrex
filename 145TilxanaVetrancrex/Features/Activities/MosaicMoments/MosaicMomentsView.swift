import SwiftUI

struct MosaicMomentsView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @Binding var path: [CreateNavRoute]

    let level: Int
    let difficulty: ActivityDifficulty

    @State private var gridPreset: MosaicGridPreset = .square

    init(level: Int, difficulty: ActivityDifficulty, path: Binding<[CreateNavRoute]>) {
        self.level = level
        self.difficulty = difficulty
        _path = path
    }

    private let palette: [Color] = [
        Color.appPrimary,
        Color.appAccent,
        Color.appTextPrimary,
        Color.appSurface
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mosaic Moments")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("Tap a chip, then tap the grid to snap it in. Stack for extra flair.")
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                layoutPicker

                MosaicMomentsBoard(
                    level: level,
                    difficulty: difficulty,
                    path: $path,
                    gridPreset: gridPreset,
                    palette: palette
                )
                .id("\(level)-\(difficulty.rawValue)-\(gridPreset.rawValue)")
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            gridPreset = store.lastMosaicPreset
        }
        .onChange(of: gridPreset) { newValue in
            store.saveMosaicPreset(newValue)
        }
    }

    private var layoutPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Layout")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
            Picker("Layout", selection: $gridPreset) {
                Text(MosaicGridPreset.square.title).tag(MosaicGridPreset.square)
                if store.mosaicAdvancedLayoutsUnlocked {
                    Text(MosaicGridPreset.brick.title).tag(MosaicGridPreset.brick)
                    Text(MosaicGridPreset.dense.title).tag(MosaicGridPreset.dense)
                }
            }
            .pickerStyle(.segmented)
            .appSegmentedShell()
            if !store.mosaicAdvancedLayoutsUnlocked {
                Text("Earn six stars total to unlock brick and dense layouts.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

private struct MosaicMomentsBoard: View {
    @EnvironmentObject private var store: PhotoFlowData
    @StateObject private var model: MosaicMomentsViewModel
    @Binding var path: [CreateNavRoute]

    let level: Int
    let difficulty: ActivityDifficulty
    let palette: [Color]

    init(
        level: Int,
        difficulty: ActivityDifficulty,
        path: Binding<[CreateNavRoute]>,
        gridPreset: MosaicGridPreset,
        palette: [Color]
    ) {
        self.level = level
        self.difficulty = difficulty
        _path = path
        self.palette = palette
        _model = StateObject(wrappedValue: MosaicMomentsViewModel(level: level, difficulty: difficulty, gridPreset: gridPreset))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            paletteBar

            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    gridBackground(size: size)

                    ForEach(model.pieces) { piece in
                        pieceView(piece: piece, size: size)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    if model.activeTemplate != nil {
                        model.placeActive(at: location, in: size)
                    }
                }
            }
            .frame(height: 340)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .appCanvasWell(cornerRadius: 22)

            HStack(spacing: 12) {
                Button {
                    model.reset()
                } label: {
                    Text("Clear board")
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
        .alert("Need more tiles", isPresented: Binding(get: {
            model.alertMessage != nil
        }, set: { newValue in
            if !newValue { model.alertMessage = nil }
        })) {
            Button("OK", role: .cancel) { model.alertMessage = nil }
        } message: {
            Text(model.alertMessage ?? "")
        }
    }

    private var paletteBar: some View {
        HStack(spacing: 10) {
            ForEach(Array(palette.enumerated()), id: \.offset) { idx, color in
                VStack(spacing: 6) {
                    Button {
                        model.spawnTemplate(colorIndex: idx, shape: 0)
                    } label: {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(color)
                            .frame(width: 52, height: 52)
                            .shadow(color: Color.appPrimary.opacity(0.18), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)

                    Button {
                        model.spawnTemplate(colorIndex: idx, shape: 1)
                    } label: {
                        Circle()
                            .fill(color.opacity(0.85))
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.appAccent.opacity(0.15), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func gridBackground(size: CGSize) -> some View {
        let cellW = size.width / CGFloat(model.columns)
        let cellH = size.height / CGFloat(model.rows)
        let gap = model.cellGap
        return Canvas { context, _ in
            for r in 0..<model.rows {
                for c in 0..<model.columns {
                    let ox = model.brickOffsetX(gridY: r, cellWidth: cellW)
                    let rect = CGRect(
                        x: CGFloat(c) * cellW + ox + gap * 0.5,
                        y: CGFloat(r) * cellH + gap * 0.5,
                        width: cellW - gap * 2,
                        height: cellH - gap * 2
                    )
                    let path = Path(roundedRect: rect, cornerRadius: 10, style: .continuous)
                    context.fill(path, with: .color(Color.appSurface.opacity(0.45)))
                    context.stroke(path, with: .color(Color.appAccent.opacity(0.25)), lineWidth: 1)
                }
            }
        }
    }

    private func pieceView(piece: MosaicPiece, size: CGSize) -> some View {
        let cellW = size.width / CGFloat(model.columns)
        let cellH = size.height / CGFloat(model.rows)
        let gap = model.cellGap
        let trim = model.cellInnerTrim
        let ox = model.brickOffsetX(gridY: piece.gridY, cellWidth: cellW)
        let rect = CGRect(
            x: CGFloat(piece.gridX) * cellW + ox + gap,
            y: CGFloat(piece.gridY) * cellH + gap,
            width: cellW - trim,
            height: cellH - trim
        )
        let color = piece.colorIndex >= 0 && piece.colorIndex < palette.count
            ? palette[piece.colorIndex]
            : Color.appPrimary
        return Group {
            if piece.shape == 1 {
                Circle()
                    .fill(color.opacity(0.9))
                    .overlay(Circle().stroke(Color.appTextPrimary.opacity(0.35), lineWidth: 1))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appTextPrimary.opacity(0.35), lineWidth: 1)
                    )
            }
        }
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }

    private func finish() {
        let stars = model.starRating(level: level, difficulty: difficulty)
        guard stars > 0 else {
            model.alertMessage = "Place more tiles to meet the layout goal."
            return
        }
        let previous = store.bestStars(for: .mosaicMoments, level: level)
        let isNew = stars > previous
        let colorsUsed = model.paletteDiversity()
        let blocks = model.pieces.count

        store.recordCompletion(
            activity: .mosaicMoments,
            level: level,
            stars: stars,
            drawingLengthDelta: 0,
            colorsUsedDelta: colorsUsed,
            prismLayersDelta: 0
        )

        let outcome = ActivityOutcome(
            activity: .mosaicMoments,
            level: level,
            difficulty: difficulty,
            stars: stars,
            colorsUsed: colorsUsed,
            drawingLengthPoints: 0,
            coveragePercent: min(100, blocks * 12),
            blocksPlaced: blocks,
            isNewRecord: isNew
        )

        let cellW = 1.0 / Double(model.columns)
        let cellH = 1.0 / Double(model.rows)
        let stored = model.pieces.map { piece in
            StoredMosaicBlock(
                x: Double(piece.gridX) * cellW,
                y: Double(piece.gridY) * cellH,
                w: cellW * 0.85,
                h: cellH * 0.85,
                colorIndex: piece.colorIndex,
                shape: piece.shape
            )
        }

        let record = CreationRecord(
            kind: .mosaicSnapshot,
            starsSnapshot: stars,
            title: "Mosaic board",
            strokes: [],
            prismLayers: [],
            mosaicBlocks: stored,
            accentHue: 0.33
        )
        store.addGalleryCreation(record)

        path.append(.outcome(outcome))
    }
}
