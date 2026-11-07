import Models

extension MachineStatus {
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
