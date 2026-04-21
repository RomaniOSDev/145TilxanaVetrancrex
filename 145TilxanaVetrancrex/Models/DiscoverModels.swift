import Combine
import Foundation
import SwiftUI

struct TrendTile: Identifiable, Hashable {
    let id: UUID
    let hue: Double
    let density: Double
    let pulse: Double
}

@MainActor
final class DiscoverFeed: ObservableObject {
    @Published private(set) var tiles: [TrendTile] = []
    @Published private(set) var visualTheme: DiscoverVisualTheme = .balanced

    private var timer: AnyCancellable?

    init() {
        regenerate()
        timer = Timer.publish(every: 2.6, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.regenerate()
            }
    }

    func applyTheme(_ theme: DiscoverVisualTheme) {
        visualTheme = theme
        regenerate()
    }

    func regenerate() {
        var next: [TrendTile] = []
        for idx in 0..<12 {
            let density = Double.random(in: 0.35...0.95)
            let pulse = Double.random(in: 0.2...0.9)
            let hue = themeHueBias(index: idx, theme: visualTheme)
            next.append(TrendTile(id: UUID(), hue: hue, density: density, pulse: pulse))
        }
        tiles = next
    }

    func tileColor(for item: TrendTile, tileIndex: Int) -> Color {
        let palette = themePalette(theme: visualTheme)
        let pick = palette[Int((item.hue * Double(palette.count)).rounded(.down)) % palette.count]
        return pick
    }

    private func themeHueBias(index: Int, theme: DiscoverVisualTheme) -> Double {
        let base = Double((index * 17 + Int.random(in: 0...40)) % 360) / 360.0
        switch theme {
        case .balanced:
            return base
        case .warm:
            return min(1, base * 0.45 + 0.12)
        case .cool:
            return min(1, base * 0.4 + 0.55)
        case .electric:
            return (base + Double(index % 3) * 0.09).truncatingRemainder(dividingBy: 1)
        case .soft:
            return min(1, base * 0.25 + 0.38)
        }
    }

    private func themePalette(theme: DiscoverVisualTheme) -> [Color] {
        switch theme {
        case .balanced:
            return [
                Color.appPrimary,
                Color.appAccent,
                Color.appSurface,
                Color.appTextPrimary
            ]
        case .warm:
            return [
                Color.appPrimary,
                Color.appAccent,
                Color.appPrimary.opacity(0.75),
                Color.appAccent.opacity(0.85)
            ]
        case .cool:
            return [
                Color.appSurface,
                Color.appTextPrimary,
                Color.appAccent.opacity(0.75),
                Color.appSurface.opacity(0.95)
            ]
        case .electric:
            return [
                Color.appAccent,
                Color.appTextPrimary,
                Color.appPrimary,
                Color.appAccent.opacity(0.65)
            ]
        case .soft:
            return [
                Color.appSurface.opacity(0.95),
                Color.appAccent.opacity(0.55),
                Color.appPrimary.opacity(0.5),
                Color.appTextPrimary.opacity(0.85)
            ]
        }
    }
}
