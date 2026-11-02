import Charts
import DesignSystem
import SwiftUI

/// The boiler's live readings, which update with every status frame.
struct BoilerDetailView: View {
    let readings: BoilerReadings

    /// The time someone drags to on a chart; nil shows the latest values.
    @State private var selection: Date?

    var body: some View {
        ScrollView {
            charts
                .padding(.horizontal, .spacing16)
        }
        .background(.cream)
        .navigationBar(title: "Boiler")
    }

    /// Temperature on top; pressure and flow below on one shared scale.
    private var charts: some View {
        VStack(alignment: .leading, spacing: .spacing32) {
            VStack(alignment: .leading, spacing: .spacing8) {
                Text(timeLabel)
                    .subheadlineText()
                    .foregroundStyle(.cocoa)
                ValueLabel(
                    kind: .temperature,
                    text: BoilerSeries.temperature.text(for: value(of: .temperature)),
                    detail: "Target \(readings.target.degrees)"
                )
                TimeChart(
                    history: readings.history,
                    kinds: [.temperature],
                    domain: temperatureDomain,
                    target: readings.target,
                    showsTimeAxis: false,
                    aspectRatio: .compactChartAspectRatio,
                    selection: $selection
                )
            }
            VStack(alignment: .leading, spacing: .spacing8) {
                HStack(alignment: .top, spacing: .spacing12) {
                    ForEach(kinds.filter { $0 != .temperature }) { kind in
                        ValueLabel(kind: kind, text: kind.text(for: value(of: kind)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                TimeChart(
                    history: readings.history,
                    kinds: kinds.filter { $0 != .temperature },
                    domain: BoilerSeries.sharedDomain,
                    target: nil,
                    showsTimeAxis: true,
                    aspectRatio: .chartAspectRatio,
                    selection: $selection
                )
            }
        }
    }

    private var kinds: [BoilerSeries] {
        readings.measuresPressure ? [.temperature, .pressure, .flow] : [.temperature, .flow]
    }

    private var selectedFrame: BoilerReadings.Frame? {
        guard let selection else { return nil }
        return readings.history.min {
            abs($0.time.timeIntervalSince(selection)) < abs($1.time.timeIntervalSince(selection))
        }
    }

    private var timeLabel: String {
        selectedFrame.map { $0.time.formatted(date: .omitted, time: .standard) } ?? String(localized: "Now")
    }

    private func value(of kind: BoilerSeries) -> Double {
        if let selectedFrame {
            return selectedFrame[keyPath: kind.value]
        }
        return switch kind {
        case .temperature: readings.temperature
        case .pressure: readings.pressure
        case .flow: readings.flow
        }
    }

    /// Fits the readings and the target, but never narrower than 5°, so noise at rest stays small.
    private var temperatureDomain: ClosedRange<Double> {
        let values = readings.history.map(\.temperature) + [readings.target]
        let low = values.min() ?? readings.target
        let high = values.max() ?? readings.target
        let missing = max(5 - (high - low), 0)
        return (low - missing / 2)...(high + missing / 2)
    }
}

private enum BoilerSeries: Identifiable {
    case temperature
    case pressure
    case flow

    /// Bar and ml/s share one 0–10 scale, as on GaggiMate's own dashboard.
    static let sharedDomain = 0.0...10

    var id: Self { self }

    var name: String {
        switch self {
        case .temperature: "Temperature"
        case .pressure: "Pressure"
        case .flow: "Flow"
        }
    }

    var color: Color {
        switch self {
        case .temperature: .terracotta
        case .pressure: .denim
        case .flow: .jade
        }
    }

    var value: KeyPath<BoilerReadings.Frame, Double> {
        switch self {
        case .temperature: \.temperature
        case .pressure: \.pressure
        case .flow: \.flow
        }
    }

    func text(for value: Double) -> String {
        switch self {
        case .temperature: value.degrees
        case .pressure: value.oneDecimal + " bar"
        case .flow: value.oneDecimal + " ml/s"
        }
    }
}

private struct ValueLabel: View {
    let kind: BoilerSeries
    let text: String
    /// A quieter note after the value, such as the target.
    var detail: LocalizedStringKey?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label {
                Text(kind.name)
                    .subheadlineText()
                    .foregroundStyle(.cocoa)
            } icon: {
                Image(systemName: "circle.fill")
                    .imageScale(.small)
                    .foregroundStyle(kind.color)
            }
            HStack(alignment: .firstTextBaseline, spacing: .spacing8) {
                Text(text)
                    .headlineText()
                    .monospacedDigit()
                    .foregroundStyle(.espresso)
                if let detail {
                    Text(detail)
                        .subheadlineText()
                        .monospacedDigit()
                        .foregroundStyle(.cocoa)
                }
            }
        }
    }
}

private struct TimeChart: View {
    let history: [BoilerReadings.Frame]
    let kinds: [BoilerSeries]
    let domain: ClosedRange<Double>
    let target: Double?
    let showsTimeAxis: Bool
    let aspectRatio: CGFloat
    @Binding var selection: Date?

    var body: some View {
        Chart {
            if let target {
                RuleMark(y: .value("Target", target))
                    .foregroundStyle(.cocoa)
                    .lineStyle(.dashed)
            }
            ForEach(kinds) { kind in
                ForEach(history) { frame in
                    LineMark(
                        x: .value("Time", frame.time),
                        y: .value("Value", frame[keyPath: kind.value]),
                        series: .value("Series", kind.name)
                    )
                    .foregroundStyle(kind.color)
                    .lineStyle(.chartLine)
                    .interpolationMethod(.monotone)
                }
            }
            if let selection {
                RuleMark(x: .value("Selected", selection))
                    .foregroundStyle(.cocoa)
            }
        }
        .chartYScale(domain: domain)
        .chartYAxis(.hidden)
        .chartXAxis(showsTimeAxis ? .automatic : .hidden)
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .foregroundStyle(.cocoa)
            }
        }
        .chartXSelection(value: $selection)
        .fontDesign(.rounded)
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

private extension Double {
    var oneDecimal: String {
        formatted(.number.precision(.fractionLength(1)))
    }
}
