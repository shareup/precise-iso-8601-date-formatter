// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PreciseISO8601DateFormatter",
    platforms: [
        .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7),
    ],
    products: [
        .library(
            name: "PreciseISO8601DateFormatter",
            targets: ["PreciseISO8601DateFormatter"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/shareup/synchronized.git",
            .upToNextMajor(from: "4.0.0")
        ),
    ],
    targets: [
        .target(
            name: "PreciseISO8601DateFormatter",
            dependencies: [
                .product(name: "Synchronized", package: "synchronized"),
            ]
        ),
        .testTarget(
            name: "PreciseISO8601DateFormatterTests",
            dependencies: ["PreciseISO8601DateFormatter"]
        ),
    ]
)
