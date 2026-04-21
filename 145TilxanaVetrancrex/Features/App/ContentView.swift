import SwiftUI

struct ContentView: View {
    @StateObject private var store = PhotoFlowData()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainShellView()
            } else {
                OnboardingContainerView()
            }
        }
        .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
