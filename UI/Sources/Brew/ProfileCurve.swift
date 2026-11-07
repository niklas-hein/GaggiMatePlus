import Charts
import DesignSystem
import SwiftUI

/// The pump targets a profile plans, phase by phase, with the other value at its limit, as GaggiMate's web app and
/// display draw them; a stop condition can end a phase sooner.
struct ProfileCurve: View {
    let phases: [BrewPhase]

    var body: some View {
        let points = CurvePoint.points(for: phases)
        VStack(alignment: .leading, spacing: .spacing8) {
            HStack(spacing: .spacing12) {
                ForEach(CurveKind.allCases.filter { kind in points.contains { $0.kind == kind } }) { kind in
                    Label {
                        Text(kind.name)
                    } icon: {
                        Image(systemName: "circle.fill")
                            .imageScale(.small)
                            .foregroundStyle(kind.color)
                    }
                }
            }
            .subheadlineText()
            .foregroundStyle(.slate)
            Chart {
                ForEach(phases.startTimes.dropFirst(), id: \.self) { start in
                    RuleMark(x: .value("Phase", start))
                        .foregroundStyle(.pebble)
                }
                ForEach(points) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("Value", point.kind.plotted(point.value)),
                        series: .value("Series", point.series)
                    )
                    .foregroundStyle(point.kind.color)
                    .lineStyle(point.isLimit ? .dashed : .chartLine)
                }
            }
            .chartXScale(domain: 0...phases.map(\.seconds).reduce(0, +))
            .chartYScale(domain: CurveKind.pressure.scale)
            .chartYAxis {
                axis(for: .pressure)
                axis(for: .flow)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let seconds = value.as(Double.self) {
                            Text("\(seconds.formatted()) s")
                        }
                    }
                    .foregroundStyle(.slate)
                }
            }
            .fontDesign(.rounded)
            .aspectRatio(.chartAspectRatio, contentMode: .fit)
        }
    }

    private func axis(for kind: CurveKind) -> some AxisContent {
        AxisMarks(position: kind.axisPosition, values: kind.ticks.map { kind.plotted($0) }) { value in
            AxisValueLabel {
                if let plotted = value.as(Double.self) {
                    Text(kind.unplotted(plotted).formatted())
                }
            }
            .foregroundStyle(kind.color)
        }
    }
}

/// One phase's stretch of the profile curve: the value the pump aims for, with its ramp, on the same scale as the
/// whole curve so phases compare.
struct PhaseCurve: View {
    let phases: [BrewPhase]
    let phase: BrewPhase

    var body: some View {
        // Off and power have no target, so the phase draws the pressure it allows, along the bottom.
        let kind: CurveKind = phase.pump.mode == .flow ? .flow : .pressure
        let start = phases.prefix(while: { $0.id != phase.id }).map(\.seconds).reduce(0, +)
        Chart(CurvePoint.points(for: phases).filter { $0.phase == phase.id && $0.kind == kind }) { point in
            LineMark(x: .value("Time", point.time), y: .value("Value", kind.plotted(point.value)))
                .lineStyle(.chartLine)
        }
        .foregroundStyle(phase.pump.mode == .flow || phase.pump.mode == .pressure ? kind.color : .slate)
        .chartXScale(domain: start...start + phase.seconds)
        .chartYScale(domain: CurveKind.pressure.scale)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .inlineChartFrame()
    }
}

private extension [BrewPhase] {
    /// When each phase starts, in seconds from the start of the shot.
    var startTimes: [Double] {
        reduce(into: [0]) { starts, phase in
            starts.append(starts[starts.count - 1] + phase.seconds)
        }
        .dropLast()
    }
}

private enum CurveKind: CaseIterable, Identifiable {
    case pressure
    case flow

    var id: Self { self }

    var name: LocalizedStringKey {
        switch self {
        case .pressure: "Pressure (bar)"
        case .flow: "Flow (ml/s)"
        }
    }

    /// Fixed like GaggiMate's web app, each on its own axis: pressure on the left, flow on the right.
    var scale: ClosedRange<Double> {
        switch self {
        case .pressure: 0...12
        case .flow: 0...10
        }
    }

    var ticks: [Double] {
        switch self {
        case .pressure: [0, 3, 6, 9, 12]
        case .flow: [0, 2, 4, 6, 8, 10]
        }
    }

    var axisPosition: AxisMarkPosition {
        switch self {
        case .pressure: .leading
        case .flow: .trailing
        }
    }

    /// The chart plots on the pressure scale, so flow is stretched onto it.
    func plotted(_ value: Double) -> Double {
        value / scale.upperBound * CurveKind.pressure.scale.upperBound
    }

    func unplotted(_ value: Double) -> Double {
        value / CurveKind.pressure.scale.upperBound * scale.upperBound
    }

    var color: Color {
        switch self {
        case .pressure: .denim
        case .flow: .jade
        }
    }

    /// Whether the pump aims for this value, and the value: nil keeps the one the phase starts with.
    func role(in pump: Pump) -> (isLimit: Bool, value: Double?) {
        switch (self, pump.mode) {
        case (_, .off), (_, .power): (true, 0)
        case (.pressure, .pressure): (false, pump.pressure)
        case (.pressure, .flow): (true, pump.pressure)
        case (.flow, .flow): (false, pump.flow)
        case (.flow, .pressure): (true, pump.flow)
        }
    }
}

private struct CurvePoint: Identifiable {
    let id: Int
    /// A run of phases where the value is the target, or one where it's a limit; each draws as one line.
    let series: Int
    /// The phase the point belongs to.
    let phase: BrewPhase.ID
    let kind: CurveKind
    let isLimit: Bool
    let time: Double
    let value: Double

    private static let rampSteps = 24

    static func points(for phases: [BrewPhase]) -> [Self] {
        var points: [Self] = []
        var series = 0
        for kind in CurveKind.allCases {
            var start = 0.0
            var level = 0.0
            var previousRole: Bool?

            func add(at time: Double, _ value: Double, isLimit: Bool, phase: BrewPhase.ID) {
                points.append(
                    Self(
                        id: points.count,
                        series: series,
                        phase: phase,
                        kind: kind,
                        isLimit: isLimit,
                        time: time,
                        value: value
                    )
                )
            }

            for phase in phases {
                defer { start += phase.seconds }
                let role = kind.role(in: phase.pump)
                let isLimit = role.isLimit
                // A limit of 0 sets none and draws along the bottom.
                let value = role.value ?? level
                if isLimit != previousRole {
                    series += 1
                }
                // Like GaggiMate's web app and display, the curve reads every ramp length as seconds.
                let rampLength = phase.ramp.map { $0.length > 0 ? $0.length : phase.seconds } ?? 0
                let rampSeconds = isLimit ? 0 : min(rampLength, phase.seconds)
                if let ramp = phase.ramp, rampSeconds > 0 {
                    for step in 0...rampSteps {
                        let progress = Double(step) / Double(rampSteps)
                        let eased = level + (value - level) * ramp.style.eased(progress)
                        add(at: start + progress * rampSeconds, eased, isLimit: false, phase: phase.id)
                    }
                } else {
                    add(at: start, value, isLimit: isLimit, phase: phase.id)
                }
                add(at: start + phase.seconds, value, isLimit: isLimit, phase: phase.id)
                level = value
                previousRole = isLimit
            }
        }
        return points
    }
}

private extension Ramp.Style {
    /// Maps progress through the ramp, 0 to 1, to progress towards the target.
    func eased(_ progress: Double) -> Double {
        switch self {
        case .linear: progress
        case .easeIn: progress * progress
        case .easeOut: 1 - (1 - progress) * (1 - progress)
        case .easeInOut: progress * progress * (3 - 2 * progress)
        }
    }
}
