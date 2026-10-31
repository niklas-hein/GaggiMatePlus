import Navigation
import SwiftUI

@main
struct GaggiMatePlusApp: App {
    @State private var coordinator = Coordinator()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coordinator)
        }
    }
}
