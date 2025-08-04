// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Pylon",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "Pylon",
            targets: ["Pylon"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "Pylon",
            dependencies: [],
            path: "Sources",
            exclude: ["Assets.xcassets", "Pylon.entitlements", "Preview Content"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "PylonTests",
            dependencies: ["Pylon"],
            path: "Tests/PylonTests"
        ),
    ]
)
