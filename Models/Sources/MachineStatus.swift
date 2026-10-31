/// What the machine is doing, as the sidebar's machine row shows it.
public enum MachineStatus: Sendable {
    case offline
    case connecting
    case error
    case updating(progress: Int)
    case starting
    case needsUpdate
    case autotuning
    case flushing
    case backflushing
    case descaling
    case standby
    case warning(MachineWarning, others: Int)
    case heating(temperature: Double)
    case steam(temperature: Double)
    case hotWater
    case updateAvailable
    case ready(temperature: Double)
}

public enum MachineWarning: Sendable {
    case waterLow
    case backflushDue
    case descaleDue
    case noScale
    case scaleBatteryLow
}
