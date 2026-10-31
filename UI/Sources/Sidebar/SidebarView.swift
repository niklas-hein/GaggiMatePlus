import DesignSystem
import Navigation
import SwiftUI

struct SidebarView: View {
    var body: some View {
        VStack(spacing: 0) {
            MachineRow()
            Spacer(minLength: 0)
        }
        .padding(.horizontal, .spacing16)
        .background(.cream)
    }
}

private struct MachineRow: View {
    @Environment(Coordinator.self)
    private var coordinator

    var body: some View {
        Button {
            coordinator.select(.machine)
        } label: {
            HStack(spacing: .spacing12) {
                Image(systemName: "cup.and.heat.waves")
                    .imageScale(.large)
                    .frame(width: SidebarLayout.machineDiscSize, height: SidebarLayout.machineDiscSize)
                    .background(.snow, in: .circle)
                Text("Machine")
                    .headlineText()
            }
            .foregroundStyle(.espresso)
            .frame(maxWidth: .infinity, minHeight: SidebarLayout.machineRowHeight, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
