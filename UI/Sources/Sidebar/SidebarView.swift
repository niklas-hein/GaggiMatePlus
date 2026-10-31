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
        .background(.porcelain)
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
                        .foregroundStyle(.cocoa)
                        .shimmering(status.isInProgress)
                }
            }
            .headlineText()
            .padding(.vertical, .spacing8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.highlight(isSelected: isSelected))
        .foregroundStyle(.espresso)
    }

    private var isSelected: Bool {
        coordinator.selectedRoot == .machine
    }
}

private extension MachineStatus {
    var subtitle: String {
        switch self {
        case .offline: "Offline"
        case .connecting: "Connecting…"
        case .error: "Error"
        case let .updating(progress): "Updating · \(progress)%"
        case .starting: "Starting…"
        case .needsUpdate: "Needs update"
        case .autotuning: "Autotuning"
        case .flushing: "Flushing"
        case .backflushing: "Backflushing"
        case .descaling: "Descaling"
        case .standby: "Standby"
        case let .warning(warning, others): others > 0 ? "\(warning.title) · +\(others)" : warning.title
        case let .heating(temperature): "Heating · \(temperature.degrees)"
        case let .steam(temperature): "Steam · \(temperature.degrees)"
        case .hotWater: "Hot water"
        case .updateAvailable: "Update available"
        case let .ready(temperature): "Ready · \(temperature.degrees)"
        }
    }

    var isInProgress: Bool {
        switch self {
        case .connecting, .updating, .starting, .autotuning, .flushing, .backflushing, .descaling, .heating:
            true
        case .offline, .error, .needsUpdate, .standby, .warning, .steam, .hotWater, .updateAvailable, .ready:
            false
        }
    }
}

private extension MachineWarning {
    var title: String {
        switch self {
        case .waterLow: "Water low"
        case .backflushDue: "Backflush due"
        case .descaleDue: "Descale due"
        case .noScale: "No scale"
        case .scaleBatteryLow: "Scale battery low"
        }
    }
}

private extension Double {
    var degrees: String {
        formatted(.number.precision(.fractionLength(0))) + "°"
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
    .background(.porcelain)
    .environment(Coordinator())
}
