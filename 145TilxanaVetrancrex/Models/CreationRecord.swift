import Foundation

enum CreationKind: String, Codable, Hashable {
    case freeform
    case prismSnapshot
    case doodleSnapshot
    case mosaicSnapshot
}

struct StrokePoint: Codable, Hashable {
    var x: Double
    var y: Double
}

struct StoredStroke: Codable, Hashable {
    var points: [StrokePoint]
    var colorIndex: Int
    var brush: Int
    var width: Double
}

struct StoredPrismLayer: Codable, Hashable {
    var cx: Double
    var cy: Double
    var radius: Double
    var hueShift: Double
}

struct StoredMosaicBlock: Codable, Hashable {
    var x: Double
    var y: Double
    var w: Double
    var h: Double
    var colorIndex: Int
    var shape: Int
}

struct CreationRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var createdAt: Date
    var kind: CreationKind
    var starsSnapshot: Int
    var title: String
    var strokes: [StoredStroke]
    var prismLayers: [StoredPrismLayer]
    var mosaicBlocks: [StoredMosaicBlock]
    var accentHue: Double
    var isFavorite: Bool
    var tags: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case kind
        case starsSnapshot
        case title
        case strokes
        case prismLayers
        case mosaicBlocks
        case accentHue
        case isFavorite
        case tags
    }

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        kind: CreationKind,
        starsSnapshot: Int,
        title: String,
        strokes: [StoredStroke] = [],
        prismLayers: [StoredPrismLayer] = [],
        mosaicBlocks: [StoredMosaicBlock] = [],
        accentHue: Double = 0.35,
        isFavorite: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.starsSnapshot = starsSnapshot
        self.title = title
        self.strokes = strokes
        self.prismLayers = prismLayers
        self.mosaicBlocks = mosaicBlocks
        self.accentHue = accentHue
        self.isFavorite = isFavorite
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        kind = try c.decode(CreationKind.self, forKey: .kind)
        starsSnapshot = try c.decode(Int.self, forKey: .starsSnapshot)
        title = try c.decode(String.self, forKey: .title)
        strokes = try c.decodeIfPresent([StoredStroke].self, forKey: .strokes) ?? []
        prismLayers = try c.decodeIfPresent([StoredPrismLayer].self, forKey: .prismLayers) ?? []
        mosaicBlocks = try c.decodeIfPresent([StoredMosaicBlock].self, forKey: .mosaicBlocks) ?? []
        accentHue = try c.decodeIfPresent(Double.self, forKey: .accentHue) ?? 0.35
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(kind, forKey: .kind)
        try c.encode(starsSnapshot, forKey: .starsSnapshot)
        try c.encode(title, forKey: .title)
        try c.encode(strokes, forKey: .strokes)
        try c.encode(prismLayers, forKey: .prismLayers)
        try c.encode(mosaicBlocks, forKey: .mosaicBlocks)
        try c.encode(accentHue, forKey: .accentHue)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(tags, forKey: .tags)
    }
}
