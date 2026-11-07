import Foundation

/// A brew profile on the machine.
struct BrewProfile: Identifiable {
    let id: String
    var name: String
    var description: String
    var temperature: Double
    /// The coffee in the basket, if the profile sets one.
    var dose: Double?
    var phases: [BrewPhase]
}

struct BrewPhase: Identifiable {
    enum Kind: CaseIterable {
        case preinfusion
        case brew
    }

    let id = UUID()
    var name: String
    var kind: Kind
    /// The longest the phase runs.
    var seconds: Double
    /// Nil uses the profile's temperature.
    var temperature: Double?
    /// Whether water may flow to the group; closing it releases the pressure, as the backflush does.
    var isValveOpen = true
    var pump: Pump
    /// How the pump moves from the previous phase's target to this one's; nil jumps at once.
    var ramp: Ramp?
    /// Readings that end the phase before its duration runs out; the first one reached does.
    var stopConditions: [StopCondition] = []
}

/// A reading that ends a phase early.
struct StopCondition: Identifiable {
    /// The web app's conditions; a phase has each at most once.
    enum Kind: CaseIterable {
        case waterPumped
        case weight
        case ratio
        case pressureAbove
        case pressureBelow
        case flowAbove
        case flowBelow
    }

    var kind: Kind
    /// In ml, g, grams out per gram of dose, bar or ml/s, as `kind` says.
    var value: Double

    var id: Kind { kind }
}

struct Ramp {
    enum Style: CaseIterable {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }

    /// What the length counts.
    enum Measure: CaseIterable {
        case time
        case weight
        case waterPumped
    }

    var style: Style
    /// In seconds, grams or millilitres, as `measure` says; 0 ramps over the whole phase.
    var length: Double
    var measure = Measure.time
    /// Whether the ramp starts from the value measured when the phase begins, rather than the previous target.
    var startsFromCurrentValue = true
}

/// What the pump does during a phase, and how far the value it doesn't control may go.
struct Pump {
    enum Mode {
        case off
        case power
        case pressure
        case flow
    }

    var mode: Mode
    /// The share of full power in %, when the mode is `.power`.
    var power: Double = 100
    /// In bar: the target when the mode is `.pressure`, otherwise the most it may reach, where 0 sets no limit.
    /// Nil keeps the pressure the phase starts with.
    var pressure: Double? = 0
    /// In ml/s, like `pressure`.
    var flow: Double? = 0

    static func pressure(_ bar: Double?, flowLimit: Double = 0) -> Self {
        Self(mode: .pressure, pressure: bar, flow: flowLimit)
    }

    static func flow(_ rate: Double?, pressureLimit: Double = 0) -> Self {
        Self(mode: .flow, pressure: pressureLimit, flow: rate)
    }
}

extension BrewPhase {
    /// A new phase of a type: full pump power, which every machine can run, as GaggiMate's web app starts one.
    static func new(_ kind: Kind) -> Self {
        Self(name: "New phase", kind: kind, seconds: 10, pump: Pump(mode: .power))
    }
}

extension BrewProfile {
    /// A new profile, as GaggiMate's web app starts one: a short pump and a bloom to pre-infuse, then full power up
    /// to 36 g.
    static func new() -> Self {
        Self(
            id: UUID().uuidString,
            name: "New profile",
            description: "",
            temperature: 93,
            phases: [
                BrewPhase(name: "Pump", kind: .preinfusion, seconds: 3, pump: Pump(mode: .power)),
                BrewPhase(name: "Bloom", kind: .preinfusion, seconds: 5, pump: Pump(mode: .off)),
                BrewPhase(
                    name: "Pump",
                    kind: .brew,
                    seconds: 20,
                    pump: Pump(mode: .power),
                    stopConditions: [
                        StopCondition(kind: .weight, value: 36),
                    ]
                ),
            ]
        )
    }

    /// The profiles the firmware ships with, without its backflush utility.
    static let samples = [
        Self(
            id: "9bar",
            name: "9 Bar Espresso",
            description: "",
            temperature: 93,
            phases: [
                BrewPhase(
                    name: "Pump",
                    kind: .brew,
                    seconds: 28,
                    pump: .pressure(9),
                    stopConditions: [
                        StopCondition(kind: .weight, value: 36),
                    ]
                ),
            ]
        ),
        Self(
            id: "adapt",
            name: "Adaptive v2",
            description: "Light to Medium - Fine - 25-40s - 1:2-2.5",
            temperature: 93,
            phases: [
                BrewPhase(
                    name: "Prefill",
                    kind: .preinfusion,
                    seconds: 5,
                    pump: .flow(8),
                    ramp: Ramp(style: .easeOut, length: 2),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                    ]
                ),
                BrewPhase(
                    name: "Fill",
                    kind: .preinfusion,
                    seconds: 12,
                    pump: .flow(8),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .pressureAbove, value: 3),
                    ]
                ),
                BrewPhase(
                    name: "Compressing",
                    kind: .preinfusion,
                    seconds: 12,
                    temperature: 88,
                    pump: .pressure(3),
                    ramp: Ramp(style: .easeOut, length: 2),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .flowBelow, value: 3),
                    ]
                ),
                BrewPhase(
                    name: "Dripping",
                    kind: .preinfusion,
                    seconds: 6,
                    temperature: 88,
                    pump: .pressure(0.1),
                    ramp: Ramp(style: .easeOut, length: 2)
                ),
                BrewPhase(
                    name: "Pressurize",
                    kind: .brew,
                    seconds: 6,
                    temperature: 88,
                    pump: .pressure(11, flowLimit: 3.5),
                    ramp: Ramp(style: .linear, length: 6),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .pressureAbove, value: 8.8),
                        StopCondition(kind: .weight, value: 38),
                    ]
                ),
                BrewPhase(
                    name: "Extraction",
                    kind: .brew,
                    seconds: 60,
                    temperature: 88,
                    pump: .flow(nil, pressureLimit: 9.5),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .weight, value: 38),
                    ]
                ),
            ]
        ),
        Self(
            id: "lever",
            name: "Cremina lever machine",
            description: "Darker Roasts - Very Fine- 40-60s - 1:1.5-2.2",
            temperature: 86.5,
            phases: [
                BrewPhase(name: "preinfusion start", kind: .preinfusion, seconds: 2, pump: .pressure(1.1)),
                BrewPhase(
                    name: "preinfusion",
                    kind: .preinfusion,
                    seconds: 3,
                    pump: .pressure(1.1),
                    stopConditions: [
                        StopCondition(kind: .pressureAbove, value: 3),
                    ]
                ),
                BrewPhase(name: "soak", kind: .preinfusion, seconds: 10, pump: .pressure(1.1)),
                BrewPhase(
                    name: "ramp",
                    kind: .brew,
                    seconds: 10,
                    pump: .pressure(9),
                    ramp: Ramp(style: .easeInOut, length: 10)
                ),
                BrewPhase(
                    name: "ramp-down",
                    kind: .brew,
                    seconds: 50,
                    temperature: 87,
                    pump: .pressure(3),
                    ramp: Ramp(style: .linear, length: 50),
                    stopConditions: [
                        StopCondition(kind: .weight, value: 36),
                    ]
                ),
            ]
        ),
        Self(
            id: "lmleva",
            name: "Damian's LM Leva",
            description: "Light to Medium Roasts - Very Fine - 20-45 - 1:2.0 - 2.5 | Simulates La Marzocco Leva",
            temperature: 89,
            phases: [
                BrewPhase(
                    name: "fill start",
                    kind: .preinfusion,
                    seconds: 2,
                    pump: .pressure(1.8),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                    ]
                ),
                BrewPhase(
                    name: "fill",
                    kind: .preinfusion,
                    seconds: 20,
                    pump: .pressure(1.8),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .pressureAbove, value: 1),
                    ]
                ),
                BrewPhase(
                    name: "preinfusion",
                    kind: .preinfusion,
                    seconds: 10,
                    temperature: 88.5,
                    pump: .pressure(2.2),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .pressureAbove, value: 4),
                    ]
                ),
                BrewPhase(
                    name: "rise",
                    kind: .brew,
                    seconds: 5,
                    temperature: 88,
                    pump: .pressure(8),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .pressureAbove, value: 8),
                    ]
                ),
                BrewPhase(
                    name: "hold",
                    kind: .brew,
                    seconds: 5,
                    temperature: 88,
                    pump: .pressure(8),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .flowAbove, value: 1.5),
                    ]
                ),
                BrewPhase(
                    name: "decline",
                    kind: .brew,
                    seconds: 58,
                    temperature: 88,
                    pump: .pressure(2.2),
                    ramp: Ramp(style: .linear, length: 58),
                    stopConditions: [
                        StopCondition(kind: .waterPumped, value: 100),
                        StopCondition(kind: .weight, value: 36),
                    ]
                ),
            ]
        ),
    ]
}
