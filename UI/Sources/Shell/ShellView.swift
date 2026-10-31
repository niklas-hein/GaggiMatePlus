import DesignSystem
import Navigation
public import SwiftUI

public struct ShellView: View {
    @Environment(Coordinator.self)
    private var coordinator

    public init() {}

    public var body: some View {
        SidebarContainer {
            NavigationStack {
                screen
                    .ignoresSafeArea()
                    // The new screen appears at once under the sidebar, which then slides shut over it.
                    .animation(nil, value: coordinator.selectedRoot)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            SidebarButton()
                        }
                    }
            }
        } sidebar: {
            SidebarView()
        }
        .tint(.espresso)
    }

    private var screen: Color {
        switch coordinator.selectedRoot {
        case .brew: .coral
        case .machine: .taupe
        }
    }
}

#Preview("Shell") {
    ShellView()
        .environment(Coordinator())
}
