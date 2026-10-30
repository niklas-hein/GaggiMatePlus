import ProjectDescription

let bundleId = "dev.niklashein.gaggimateplus"
let destinations: Destinations = [.iPhone, .iPad]
let deploymentTargets: DeploymentTargets = .iOS("27.0")

/// A static framework with its sources in `<name>/Sources`.
func module(_ name: String, dependencies: [TargetDependency] = []) -> Target {
    .target(
        name: name,
        destinations: destinations,
        product: .staticFramework,
        bundleId: "\(bundleId).\(name.lowercased())",
        deploymentTargets: deploymentTargets,
        sources: ["\(name)/Sources/**"],
        dependencies: dependencies
    )
}

/// The Swift Testing target for a module, with its sources in `<name>/Tests`.
func tests(for name: String, dependencies: [TargetDependency]) -> Target {
    .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name.lowercased()).tests",
        deploymentTargets: deploymentTargets,
        sources: ["\(name)/Tests/**"],
        dependencies: dependencies
    )
}

/// A scheme that builds one module and runs its tests, for `just test <name>` and that module's CI job.
func testScheme(for name: String) -> Scheme {
    .scheme(
        name: name,
        buildAction: .buildAction(targets: [.target(name)]),
        testAction: .targets([.testableTarget(target: .target("\(name)Tests"))])
    )
}

let project = Project(
    name: "GaggiMatePlus",
    options: .options(automaticSchemesOptions: .disabled),
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
        "SWIFT_STRICT_MEMORY_SAFETY": "YES",
        // Every upcoming feature that Swift 6 mode does not turn on yet.
        "SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY": "YES",
        "SWIFT_UPCOMING_FEATURE_INTERNAL_IMPORTS_BY_DEFAULT": "YES",
        "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
        "SWIFT_UPCOMING_FEATURE_INFER_ISOLATED_CONFORMANCES": "YES",
        "SWIFT_UPCOMING_FEATURE_NONISOLATED_NONSENDING_BY_DEFAULT": "YES",
        // Xcode has no build setting for this one.
        "OTHER_SWIFT_FLAGS": "$(inherited) -enable-upcoming-feature ImmutableWeakCaptures",
    ]),
    targets: [
        // The composition root: wires Networking into the Models store and hands it to the UI.
        .target(
            name: "GaggiMatePlus",
            destinations: destinations,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "GaggiMate+",
                "UILaunchScreen": [:],
                "NSLocalNetworkUsageDescription":
                    "GaggiMate+ connects to your GaggiMate controller on the local network.",
                "NSBonjourServices": ["_gaggimate._tcp"], // placeholder
                "NSAppTransportSecurity": ["NSAllowsLocalNetworking": true],
            ]),
            sources: ["App/Sources/**"],
            dependencies: [
                .target(name: "UI"),
                .target(name: "Networking"),
                .target(name: "DesignSystem"),
                .target(name: "Models"),
            ]
        ),
        module("UI", dependencies: [.target(name: "DesignSystem"), .target(name: "Models")]),
        module("Networking", dependencies: [.target(name: "Models")]),
        module("DesignSystem"),
        module("Models"),
        tests(for: "Models", dependencies: [.target(name: "Models")]),
        tests(for: "Networking", dependencies: [.target(name: "Networking"), .target(name: "Models")]),
    ],
    schemes: [
        .scheme(
            name: "GaggiMatePlus",
            buildAction: .buildAction(targets: ["GaggiMatePlus"]),
            testAction: .targets(["ModelsTests", "NetworkingTests"]),
            runAction: .runAction(executable: "GaggiMatePlus")
        ),
        testScheme(for: "Models"),
        testScheme(for: "Networking"),
    ]
)
