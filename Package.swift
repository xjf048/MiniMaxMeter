// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiniMaxMeter",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MiniMaxMeter", targets: ["MiniMaxMeter"])
    ],
    targets: [
        .executableTarget(
            name: "MiniMaxMeter",
            path: "Sources/MiniMaxMeter"
        )
    ]
)
