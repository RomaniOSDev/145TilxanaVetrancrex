import SwiftUI

struct MainShellView: View {
    @EnvironmentObject private var store: PhotoFlowData
    @StateObject private var discoverFeed = DiscoverFeed()

    @State private var tab: AppTab = .home
    @State private var path: [CreateNavRoute] = []
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch tab {
                case .home:
                    HomeView(selectedTab: $tab, createPath: $path, showSettings: $showSettings)
                case .create:
                    NavigationStack(path: $path) {
                        CreateTabView(path: $path, showSettings: $showSettings)
                            .navigationDestination(for: CreateNavRoute.self) { route in
                                switch route {
                                case .challenges:
                                    ActivitySelectionView(path: $path)
                                case let .prism(level, difficulty):
                                    PrismPlayView(path: $path, level: level, difficulty: difficulty)
                                case let .doodle(level, difficulty):
                                    DoodleDashView(level: level, difficulty: difficulty, path: $path)
                                case let .mosaic(level, difficulty):
                                    MosaicMomentsView(level: level, difficulty: difficulty, path: $path)
                                case let .outcome(model):
                                    ActivityResultView(model: model, path: $path)
                                }
                            }
                    }
                case .gallery:
                    NavigationStack {
                        GalleryTabView()
                    }
                case .discover:
                    NavigationStack {
                        DiscoverTabView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBarView(tab: $tab)
        }
        .appScreenBackdrop()
        .environmentObject(discoverFeed)
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(store)
        }
        .onReceive(NotificationCenter.default.publisher(for: .photoFlowDataDidReset)) { _ in
            path = []
            tab = .home
            showSettings = false
        }
        .onChange(of: store.shouldOpenCreateTab) { should in
            guard should else { return }
            tab = .create
            store.acknowledgeCreateTabSwitch()
        }
    }
}
