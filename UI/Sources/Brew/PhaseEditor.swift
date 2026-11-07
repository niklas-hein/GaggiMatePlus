import DesignSystem
import SwiftUI

struct PhaseEditor: View {
    @Binding var phase: BrewPhase
    let profileTemperature: Double
    let measuresPressure: Bool
    let delete: () -> Void

    @Environment(\.dismiss) private var dismiss
    /// The phase goes once this screen has left, as the screen shows it until then.
    @State private var isDeleted = false

    var body: some View {
        ScrollView {
            VStack(spacing: .spacing32) {
                VStack(spacing: 0) {
                    EditorRow("Name") {
                        TextField("Name", text: $phase.name)
                    }
                    Divider()
                        .padding(.leading, .spacing20)
                    EditorRow("Type") {
                        ChoiceMenu(title: "Type", selection: $phase.kind, choices: BrewPhase.Kind.allCases) { $0.title }
                    }
                    Divider()
                        .padding(.leading, .spacing20)
                    EditorRow("Duration") {
                        TextField("Duration", value: $phase.seconds, format: .number)
                            .keyboardType(.decimalPad)
                        Text("s")
                    }
                    Divider()
                        .padding(.leading, .spacing20)
                    EditorRow("Temperature") {
                        // Empty uses the profile's temperature, which shows as the placeholder.
                        TextField(profileTemperature.formatted(), value: $phase.temperature, format: .number)
                            .keyboardType(.decimalPad)
                        Text("°C")
                    }
                }
                .background(.snow, in: .rect(cornerRadius: .radius26))
                PumpCard(pump: $phase.pump, isValveOpen: $phase.isValveOpen, measuresPressure: measuresPressure)
                RampCard(ramp: $phase.ramp)
                StopConditionsCard(conditions: $phase.stopConditions, measuresPressure: measuresPressure)
                CardButton(title: "Delete phase", systemImage: "trash", color: .raspberry) {
                    isDeleted = true
                    dismiss()
                }
            }
            .padding(.horizontal, .spacing16)
        }
        .background(.mist)
        .navigationBar(title: LocalizedStringKey(phase.name))
        .onDisappear {
            if isDeleted {
                delete()
            }
        }
    }
}

private struct PumpCard: View {
    @Binding var pump: Pump
    @Binding var isValveOpen: Bool
    let measuresPressure: Bool

    var body: some View {
        VStack(spacing: 0) {
            EditorRow("Pump") {
                ChoiceMenu(title: "Pump", selection: choice, choices: choices) { $0.title }
            }
            switch pump.mode {
            case .off:
                EmptyView()
            case .power:
                divider
                EditorRow("Power") {
                    TextField("Power", value: $pump.power, format: .number)
                        .keyboardType(.decimalPad)
                    Text("%")
                }
            case .pressure:
                if pump.pressure != nil {
                    divider
                    EditorRow("Pressure") {
                        TextField("Pressure", value: target(\.pressure), format: .number)
                            .keyboardType(.decimalPad)
                        Text("bar")
                    }
                }
                divider
                EditorRow("Flow limit") {
                    TextField("None", value: limit(\.flow), format: .number)
                        .keyboardType(.decimalPad)
                    Text("ml/s")
                }
            case .flow:
                if pump.flow != nil {
                    divider
                    EditorRow("Flow") {
                        TextField("Flow", value: target(\.flow), format: .number)
                            .keyboardType(.decimalPad)
                        Text("ml/s")
                    }
                }
                divider
                EditorRow("Pressure limit") {
                    TextField("None", value: limit(\.pressure), format: .number)
                        .keyboardType(.decimalPad)
                    Text("bar")
                }
            }
            divider
            EditorRow("Valve open") {
                Toggle("Valve open", isOn: $isValveOpen)
                    .labelsHidden()
                    .tint(.jade)
            }
        }
        .background(.snow, in: .rect(cornerRadius: .radius26))
    }

    private var divider: some View {
        Divider()
            .padding(.leading, .spacing20)
    }

    /// Pressure and flow need the sensor; a phase that already uses one keeps it on offer.
    private var choices: [PumpChoice] {
        PumpChoice.allCases.filter { measuresPressure || !$0.needsSensor || $0 == choice.wrappedValue }
    }

    private var choice: Binding<PumpChoice> {
        Binding {
            PumpChoice(pump)
        } set: { choice in
            choice.apply(to: &pump)
        }
    }

    /// A target that is set; clearing the field doesn't turn it into a hold.
    private func target(_ value: WritableKeyPath<Pump, Double?>) -> Binding<Double> {
        Binding {
            pump[keyPath: value] ?? 0
        } set: {
            pump[keyPath: value] = $0
        }
    }

    /// A limit of 0 sets none, so it shows as an empty field.
    private func limit(_ value: WritableKeyPath<Pump, Double?>) -> Binding<Double?> {
        Binding {
            pump[keyPath: value].flatMap { $0 == 0 ? nil : $0 }
        } set: {
            pump[keyPath: value] = $0 ?? 0
        }
    }
}

/// How the pump moves from the previous phase's target to this one's.
private struct RampCard: View {
    @Binding var ramp: Ramp?

    var body: some View {
        VStack(spacing: 0) {
            EditorRow("Ramp") {
                ChoiceMenu(title: "Ramp", selection: choice, choices: RampChoice.allCases) { $0.title }
            }
            if let ramp = Binding($ramp) {
                divider
                EditorRow("Measured by") {
                    ChoiceMenu(title: "Measured by", selection: ramp.measure, choices: Ramp.Measure.allCases) {
                        $0.title
                    }
                }
                divider
                EditorRow("Length") {
                    // The firmware ramps over the whole phase when the length is 0.
                    TextField("Whole phase", value: length(ramp), format: .number)
                        .keyboardType(.decimalPad)
                    Text(ramp.wrappedValue.measure.unit)
                }
                divider
                EditorRow("Start from") {
                    ChoiceMenu(title: "Start from", selection: ramp.startsFromCurrentValue, choices: [false, true]) {
                        $0 ? "Current value" : "Previous target"
                    }
                }
            }
        }
        .background(.snow, in: .rect(cornerRadius: .radius26))
    }

    private var divider: some View {
        Divider()
            .padding(.leading, .spacing20)
    }

    private var choice: Binding<RampChoice> {
        Binding {
            ramp.map { .style($0.style) } ?? .instant
        } set: { choice in
            switch choice {
            case .instant:
                ramp = nil
            case let .style(style):
                if ramp == nil {
                    ramp = Ramp(style: style, length: 0)
                } else {
                    ramp?.style = style
                }
            }
        }
    }

    /// A length of 0 shows as an empty field.
    private func length(_ ramp: Binding<Ramp>) -> Binding<Double?> {
        Binding {
            ramp.wrappedValue.length == 0 ? nil : ramp.wrappedValue.length
        } set: {
            ramp.wrappedValue.length = $0 ?? 0
        }
    }
}

private enum RampChoice: Hashable, CaseIterable {
    case instant
    case style(Ramp.Style)

    static var allCases: [Self] {
        [.instant] + Ramp.Style.allCases.map(Self.style)
    }

    var title: LocalizedStringKey {
        switch self {
        case .instant: "Instant"
        case .style(.linear): "Linear"
        case .style(.easeIn): "Ease in"
        case .style(.easeOut): "Ease out"
        case .style(.easeInOut): "Ease in and out"
        }
    }
}

extension Ramp.Measure {
    var title: LocalizedStringKey {
        switch self {
        case .time: "Time"
        case .weight: "Weight"
        case .waterPumped: "Water pumped"
        }
    }

    var unit: String {
        switch self {
        case .time: String(localized: "s")
        case .weight: String(localized: "g")
        case .waterPumped: String(localized: "ml")
        }
    }
}

/// The pump settings a phase offers, as GaggiMate's web app lists them.
private enum PumpChoice: CaseIterable {
    case off
    case power
    case pressure
    case holdPressure
    case flow
    case holdFlow

    init(_ pump: Pump) {
        self = switch pump.mode {
        case .off: .off
        case .power: .power
        case .pressure: pump.pressure == nil ? .holdPressure : .pressure
        case .flow: pump.flow == nil ? .holdFlow : .flow
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .off: "Off"
        case .power: "Power"
        case .pressure: "Pressure"
        case .holdPressure: "Hold pressure"
        case .flow: "Flow"
        case .holdFlow: "Hold flow"
        }
    }

    var needsSensor: Bool {
        switch self {
        case .off, .power: false
        case .pressure, .holdPressure, .flow, .holdFlow: true
        }
    }

    /// Switches the mode and keeps the values, except that holding clears the target.
    func apply(to pump: inout Pump) {
        switch self {
        case .off:
            pump.mode = .off
        case .power:
            pump.mode = .power
        case .pressure:
            pump.mode = .pressure
            pump.pressure = pump.pressure ?? 0
        case .holdPressure:
            pump.mode = .pressure
            pump.pressure = nil
        case .flow:
            pump.mode = .flow
            pump.flow = pump.flow ?? 0
        case .holdFlow:
            pump.mode = .flow
            pump.flow = nil
        }
    }
}

/// A value picked from a menu, styled like the other values on an editor card.
private struct ChoiceMenu<Choice: Hashable>: View {
    let title: LocalizedStringKey
    @Binding var selection: Choice
    let choices: [Choice]
    let label: (Choice) -> LocalizedStringKey

    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(choices, id: \.self) { choice in
                    Text(label(choice))
                }
            }
        } label: {
            Text(label(selection))
            Image(systemName: "chevron.up.chevron.down")
                .imageScale(.small)
        }
        .foregroundStyle(.slate)
    }
}

extension BrewPhase.Kind {
    var title: LocalizedStringKey {
        switch self {
        case .preinfusion: "Pre-infusion"
        case .brew: "Brew"
        }
    }
}
