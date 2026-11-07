import DesignSystem
import Models
import Navigation
import SwiftUI

struct SidebarView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Nothing connects to a machine yet.
            MachineRow(status: .offline)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, .spacing12)
        .background(.frost)
    }
}

private struct MachineRow: View {
    @Environment(Coordinator.self)
    private var coordinator

    let status: MachineStatus

    var body: some View {
        Button {
            coordinator.select(.machine)
        } label: {
            HStack(spacing: .spacing8) {
                Image(systemName: "cup.and.heat.waves")
                    .imageScale(.large)
                    .symbolVariant(isSelected ? .fill : .none)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Machine")
                    Text(status.subtitle)
                        .secondarySubheadlineText()
                        .foregroundStyle(.slate)
                        .shimmering(status.isInProgress)
                }
            }
            .headlineText()
            .padding(.vertical, .spacing8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.highlight(isSelected: isSelected))
        .foregroundStyle(.ink)
    }

    private var isSelected: Bool {
        coordinator.selectedRoot == .machine
    }
}

#Preview("Machine row") {
    let statuses: [MachineStatus] = [
        .offline,
        .connecting,
        .error,
        .updating(progress: 40),
        .starting,
        .needsUpdate,
        .autotuning,
        .flushing,
        .backflushing,
        .descaling,
        .standby,
        .warning(.waterLow, others: 1),
        .warning(.backflushDue, others: 0),
        .warning(.descaleDue, others: 0),
        .warning(.noScale, others: 0),
        .warning(.scaleBatteryLow, others: 0),
        .heating(temperature: 71.4),
        .steam(temperature: 132.2),
        .hotWater,
        .updateAvailable,
        .ready(temperature: 92.8),
    ]
    ScrollView {
        VStack(spacing: 0) {
            ForEach(statuses.indices, id: \.self) { index in
                MachineRow(status: statuses[index])
            }
        }
        .padding(.horizontal, .spacing16)
    }
    .background(.frost)
    .environment(Coordinator())
}
