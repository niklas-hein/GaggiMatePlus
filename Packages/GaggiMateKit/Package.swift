// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GaggiMateKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Transport", targets: ["Transport"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Store", targets: ["Store"]),
    ],
    targets: [
        .target(name: "Models"),
        .target(name: "Transport", dependencies: ["Models"]),
        .target(name: "Store", dependencies: ["Models", "Transport"]),
        .testTarget(name: "GaggiMateKitTests", dependencies: ["Models", "Transport", "Store"]),
    ]
)
