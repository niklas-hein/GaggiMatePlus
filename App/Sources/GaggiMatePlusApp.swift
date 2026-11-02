import DesignSystem
import Navigation
import SwiftUI

@main
struct GaggiMatePlusApp: App {
    @State private var coordinator = Coordinator()

    init() {
        NavigationBarTitles.useRoundedFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coordinator)
        }
    }
}
