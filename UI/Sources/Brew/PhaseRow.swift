import DesignSystem
import SwiftUI

/// A phase's card: its stretch of the curve beside its name, what the pump does, and when it ends.
struct PhaseRow: View {
    let phases: [BrewPhase]
    let phase: BrewPhase

    var body: some View {
        HStack(spacing: .spacing12) {
            PhaseCurve(phases: phases, phase: phase)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: .spacing12) {
                    Text(phase.name)
                        .headlineText()
                        .foregroundStyle(.ink)
                    Spacer(minLength: 0)
                    Text(phase.pump.summary)
                        .subheadlineText()
                        .monospacedDigit()
                        .foregroundStyle(.slate)
                }
                Text(phase.ending)
                    .secondarySubheadlineText()
                    .monospacedDigit()
                    .foregroundStyle(.slate)
            }
        }
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing12)
        .background(.snow, in: .rect(cornerRadius: .radius26))
        .contentShape(.rect)
        .contentShape(.dragPreview, .rect(cornerRadius: .radius26))
    }
}

private extension Pump {
    var summary: String {
        switch mode {
        case .off:
            String(localized: "pump off")
        case .power:
            "\(power.formatted(.number.precision(.fractionLength(0)))) %"
        case .pressure:
            pressure.map { "\($0.short) bar" } ?? String(localized: "holds pressure")
        case .flow:
            flow.map { "\($0.short) ml/s" } ?? String(localized: "holds flow")
        }
    }
}

private extension BrewPhase {
    /// How long the phase may run, and what ends it sooner.
    var ending: String {
        let duration = "\(seconds.short)\u{00A0}s"
        guard !stopConditions.isEmpty else {
            return duration
        }
        return String(localized: "Up to \(([duration] + stopConditions.map(\.summary)).formatted(.list(type: .or)))")
    }
}

private extension StopCondition {
    /// A number never wraps away from its unit.
    var summary: String {
        switch kind {
        case .waterPumped:
            String(localized: "\(value.short)\u{00A0}ml pumped")
        case .ratio:
            "1:\(value.short)"
        case .pressureBelow, .flowBelow:
            String(localized: "under \(value.short)\u{00A0}\(kind.unit ?? "")")
        case .weight, .pressureAbove, .flowAbove:
            "\(value.short)\u{00A0}\(kind.unit ?? "")"
        }
    }
}

private extension Double {
    /// At most one decimal, as the web app shows profile values.
    var short: String {
        formatted(.number.precision(.fractionLength(0...1)))
    }
}
