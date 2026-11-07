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
                    // The new screen appears at once under the sidebar, which then slides shut over it.
                    .animation(nil, value: coordinator.selectedRoot)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            SidebarButton()
                        }
                    }
            }
            .id(coordinator.selectedRoot)
        } sidebar: {
            SidebarView()
        }
        .tint(.ink)
        .shimmerSpace()
    }

    @ViewBuilder
    private var screen: some View {
        switch coordinator.selectedRoot {
        case .brew: BrewView()
        case .machine: MachineView()
        }
    }
}

#Preview("Shell") {
    ShellView()
        .environment(Coordinator())
}
