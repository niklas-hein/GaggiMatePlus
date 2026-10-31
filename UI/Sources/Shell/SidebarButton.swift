import Navigation
import SwiftUI

struct SidebarButton: View {
    @Environment(Coordinator.self)
    private var coordinator

    var body: some View {
        Button {
            coordinator.openSidebar()
        } label: {
            Image(systemName: "line.3.horizontal")
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
