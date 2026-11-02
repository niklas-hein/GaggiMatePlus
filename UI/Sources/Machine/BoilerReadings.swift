import Foundation

/// The boiler's latest values and the frames recorded while the app is connected.
struct BoilerReadings {
    struct Frame: Identifiable {
        let time: Date
        let temperature: Double
        let pressure: Double
        let flow: Double

        var id: Date { time }
    }

    let temperature: Double
    let target: Double
    let pressure: Double
    /// Whether the machine has a pressure sensor (`cp`).
    let measuresPressure: Bool
    let flow: Double
    let history: [Frame]
}

extension BoilerReadings {
    /// Three minutes at the status rate of two frames a second, with a 30-second shot in the middle.
    static func sample(endingAt end: Date) -> Self {
        let history = stride(from: -180.0, through: 0, by: 0.5).map { offset in
            Frame(
                time: end.addingTimeInterval(offset),
                temperature: Sample.temperature(at: offset),
                pressure: Sample.pressure(at: offset - Sample.shotStart),
                flow: Sample.flow(at: offset - Sample.shotStart)
            )
        }
        let last = history[history.count - 1]
        return Self(
            temperature: last.temperature,
            target: 93,
            pressure: last.pressure,
            measuresPressure: true,
            flow: last.flow,
            history: history
        )
    }
}

/// A made-up shot: pre-infusion at 2.5 bar, a ramp to 9 bar, then a decline as the puck erodes.
private enum Sample {
    static let shotStart = -75.0
    static let shotEnd = -45.0

    static func pressure(at shot: Double) -> Double {
        switch shot {
        case 0..<6: 2.5 * shot / 6
        case 6..<10: 2.5 + 6.5 * (shot - 6) / 4
        case 10..<24: 9
        case 24...30: 9 - 2 * (shot - 24) / 6
        default: 0
        }
    }

    static func flow(at shot: Double) -> Double {
        switch shot {
        case 0..<6: 3
        case 6..<10: 3 - 2 * (shot - 6) / 4
        case 10...30: 1 + 1.2 * (shot - 10) / 20
        default: 0
        }
    }

    static func temperature(at offset: Double) -> Double {
        let wobble = 0.15 * sin(offset / 7)
        if offset < shotStart {
            return 93 + wobble
        }
        if offset <= shotEnd {
            return 93 - 2.5 * (offset - shotStart) / 30
        }
        return 90.5 + 2.5 * (1 - exp(-(offset - shotEnd) / 12)) + wobble
    }
}
