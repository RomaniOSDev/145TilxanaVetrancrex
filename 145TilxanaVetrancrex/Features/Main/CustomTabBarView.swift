import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case create = 1
    case gallery = 2
    case discover = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .create: return "Create"
        case .gallery: return "Gallery"
        case .discover: return "Discover"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .create: return "paintbrush.pointed.fill"
        case .gallery: return "square.grid.2x2.fill"
        case .discover: return "sparkles"
        }
    }
}

struct CustomTabBarView: View {
    @Binding var tab: AppTab

    private let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { item in
                Button {
                    withAnimation(spring) {
                        tab = item
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 17, weight: .semibold))
                        Text(item.title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(tab == item ? Color.appPrimary : Color.appTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            ZStack {
                LinearGradient(
                    colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.84)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.08), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.2), Color.appAccent.opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
        }
        .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: -6)
        .shadow(color: Color.appPrimary.opacity(0.1), radius: 1, x: 0, y: -1)
    }
}
