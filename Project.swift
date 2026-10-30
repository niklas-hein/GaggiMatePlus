import ProjectDescription

let bundleId = "dev.niklashein.gaggimateplus"
let destinations: Destinations = [.iPhone, .iPad]
let deploymentTargets: DeploymentTargets = .iOS("18.0")

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

let project = Project(
    name: "GaggiMatePlus",
    options: .options(automaticSchemesOptions: .disabled),
    settings: .settings(base: [
        "SWIFT_VERSION": "6.0",
        "SWIFT_STRICT_CONCURRENCY": "complete",
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
                "NSLocalNetworkUsageDescription": "GaggiMate+ connects to your GaggiMate controller on the local network.",
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
    ]
)
