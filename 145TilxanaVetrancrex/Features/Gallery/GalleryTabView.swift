import SwiftUI

struct GalleryTabView: View {
    @EnvironmentObject private var store: PhotoFlowData

    @State private var filter: GalleryFilter = .all
    @State private var tagQuery: String = ""
    @State private var tagsEditorRecord: CreationRecord?
    @State private var tagsDraft: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var filteredItems: [CreationRecord] {
        let trimmedTag = tagQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return store.galleryCreations.filter { record in
            guard filter.matches(record) else { return false }
            if trimmedTag.isEmpty { return true }
            return record.tags.contains { $0.lowercased().contains(trimmedTag) }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Gallery")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                filterPicker

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tag search")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    TextField("Filter by tag", text: $tagQuery)
                        .textFieldStyle(.roundedBorder)
                }

                if filteredItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(store.galleryCreations.isEmpty ? "Nothing saved yet" : "No matches")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text(store.galleryCreations.isEmpty
                             ? "Save from the studio or finish a challenge to fill this wall."
                             : "Try another filter or clear the tag search.")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appElevatedCardStyle(cornerRadius: 20)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredItems) { item in
                            galleryCard(item)
                        }
                    }
                }
            }
            .padding(16)
        }
        .appScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $tagsEditorRecord) { record in
            NavigationStack {
                Form {
                    Section {
                        TextField("Tags (comma separated)", text: $tagsDraft, axis: .vertical)
                            .lineLimit(3...6)
                    } footer: {
                        Text("Up to five tags. Use them to search the wall.")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .appScreenBackdrop()
                .navigationTitle("Tags")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            tagsEditorRecord = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let parts = tagsDraft.split(separator: ",").map { String($0) }
                            store.setGalleryTags(id: record.id, tags: parts)
                            tagsEditorRecord = nil
                        }
                    }
                }
            }
        }
    }

    private var filterPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Show")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GalleryFilter.allCases) { f in
                        Button {
                            filter = f
                        } label: {
                            Text(f.title)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(filter == f ? Color.appBackground : Color.appTextPrimary)
                                .background(
                                    Capsule()
                                        .fill(
                                            filter == f
                                                ? LinearGradient(
                                                    colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                : LinearGradient(
                                                    colors: [Color.appSurface.opacity(0.9), Color.appSurface.opacity(0.62)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.appPrimary.opacity(filter == f ? 0.35 : 0.14), lineWidth: 1)
                                )
                                .shadow(
                                    color: filter == f ? Color.appAccent.opacity(0.35) : Color.appTextPrimary.opacity(0.05),
                                    radius: filter == f ? 12 : 5,
                                    y: 4
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func galleryCard(_ item: CreationRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            CreationPreviewCard(record: item)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.appPrimary.opacity(0.16), radius: 14, x: 0, y: 8)
                .overlay(alignment: .topTrailing) {
                    StarRibbonView(count: item.starsSnapshot)
                        .padding(8)
                }
                .overlay(alignment: .topLeading) {
                    Button {
                        store.setGalleryFavorite(id: item.id, isFavorite: !item.isFavorite)
                    } label: {
                        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(item.isFavorite ? Color.appAccent : Color.appTextPrimary.opacity(0.85))
                            .padding(10)
                    }
                    .buttonStyle(.plain)
                }

            HStack {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer()
                Button {
                    tagsDraft = item.tags.joined(separator: ", ")
                    tagsEditorRecord = item
                } label: {
                    Image(systemName: "tag")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                if item.kind == .freeform {
                    Button {
                        store.requestOpenInStudio(item)
                    } label: {
                        Image(systemName: "pencil.and.outline")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }

                Button(role: .destructive) {
                    store.removeGalleryCreation(id: item.id)
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }

            if !item.tags.isEmpty {
                Text(item.tags.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .appElevatedCardStyle(cornerRadius: 18)
    }
}

struct CreationPreviewCard: View {
    let record: CreationRecord

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Canvas { context, size in
                    draw(record: record, context: &context, size: size)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func draw(record: CreationRecord, context: inout GraphicsContext, size: CGSize) {
        for stroke in record.strokes {
            var path = Path()
            let pts = stroke.points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
            guard let first = pts.first else { continue }
            path.move(to: first)
            for p in pts.dropFirst() {
                path.addLine(to: p)
            }
            let color = previewColor(index: stroke.colorIndex)
            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: CGFloat(stroke.width), lineCap: .round, lineJoin: .round)
            )
        }

        for layer in record.prismLayers {
            let rect = CGRect(
                x: (layer.cx - layer.radius) * size.width,
                y: (layer.cy - layer.radius) * size.height,
                width: layer.radius * 2 * size.width,
                height: layer.radius * 2 * size.height
            )
            let path = Path(ellipseIn: rect)
            context.fill(path, with: .color(Color.appAccent.opacity(0.35)))
            context.blendMode = .screen
        }

        for block in record.mosaicBlocks {
            let rect = CGRect(
                x: block.x * size.width,
                y: block.y * size.height,
                width: block.w * size.width,
                height: block.h * size.height
            )
            let path: Path
            if block.shape == 1 {
                path = Path(roundedRect: rect, cornerRadius: 10, style: .continuous)
            } else {
                path = Path(ellipseIn: rect)
            }
            context.fill(path, with: .color(previewColor(index: block.colorIndex)))
        }
    }

    private func previewColor(index: Int) -> Color {
        let base: [Color] = [
            Color.appPrimary,
            Color.appAccent,
            Color.appTextPrimary,
            Color.appSurface
        ]
        guard index >= 0, index < base.count else { return Color.appPrimary }
        return base[index]
    }
}

struct StarRibbonView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { idx in
                Image(systemName: idx < count ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(idx < count ? Color.appAccent : Color.appTextSecondary.opacity(0.8))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: Color.appAccent.opacity(0.2), radius: 8, y: 3)
    }
}
