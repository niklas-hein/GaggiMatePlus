import DesignSystem
import SwiftUI

/// The readings that end the phase early, as the web app's "Stop when" lists them.
struct StopConditionsCard: View {
    @Binding var conditions: [StopCondition]
    let measuresPressure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            Text("Stop when")
                .boldSubheadlineText()
                .foregroundStyle(.slate)
                .padding(.horizontal, .spacing20)
            VStack(spacing: 0) {
                ForEach($conditions) { $condition in
                    if condition.id != conditions.first?.id {
                        divider
                    }
                    EditorRow(condition.kind.title) {
                        if condition.kind == .ratio {
                            Text("1:")
                        }
                        TextField("0", value: $condition.value, format: .number)
                            .keyboardType(.decimalPad)
                        if let unit = condition.kind.unit {
                            Text(unit)
                        }
                        Button("Remove", systemImage: "minus.circle.fill") {
                            conditions.removeAll { $0.id == condition.id }
                        }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.raspberry)
                    }
                }
                if !available.isEmpty {
                    if !conditions.isEmpty {
                        divider
                    }
                    Menu {
                        ForEach(available, id: \.self) { kind in
                            Button(kind.title) {
                                conditions.append(StopCondition(kind: kind, value: 0))
                            }
                        }
                    } label: {
                        Label("Add condition", systemImage: "plus")
                    }
                    .headlineText()
                    .foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, .spacing20)
                    .padding(.vertical, .spacing12)
                }
            }
            .background(.snow, in: .rect(cornerRadius: .radius26))
        }
    }

    private var divider: some View {
        Divider()
            .padding(.leading, .spacing20)
    }

    /// Each condition once; pressure and flow need the sensor.
    private var available: [StopCondition.Kind] {
        StopCondition.Kind.allCases.filter { kind in
            !conditions.contains { $0.kind == kind } && (measuresPressure || !kind.needsSensor)
        }
    }
}

extension StopCondition.Kind {
    var title: LocalizedStringKey {
        switch self {
        case .waterPumped: "Water pumped"
        case .weight: "Weight reached"
        case .ratio: "Ratio reached"
        case .pressureAbove: "Pressure above"
        case .pressureBelow: "Pressure below"
        case .flowAbove: "Flow above"
        case .flowBelow: "Flow below"
        }
    }

    /// Nil for the ratio, whose "1:" leads the value.
    var unit: String? {
        switch self {
        case .waterPumped: String(localized: "ml")
        case .weight: String(localized: "g")
        case .ratio: nil
        case .pressureAbove, .pressureBelow: String(localized: "bar")
        case .flowAbove, .flowBelow: String(localized: "ml/s")
        }
    }

    var needsSensor: Bool {
        switch self {
        case .waterPumped, .weight, .ratio: false
        case .pressureAbove, .pressureBelow, .flowAbove, .flowBelow: true
        }
    }
}
