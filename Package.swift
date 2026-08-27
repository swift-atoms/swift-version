// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-version",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Version",
            targets: ["Version"]
        ),
        .library(
            name: "Version Standard Library Integration",
            targets: ["Version Standard Library Integration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-ascii.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-ascii-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-byte-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-carrier.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-ordinal.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-serializer.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-text.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-time.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Version",
            dependencies: [
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "ASCII Decimal Parser", package: "swift-ascii-parser"),
                .product(name: "Byte Standard Library Integration", package: "swift-byte"),
                .product(name: "Byte Parser", package: "swift-byte-parser"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Text", package: "swift-text"),
                .product(name: "Time", package: "swift-time"),
            ]
        ),
        .target(
            name: "Version Standard Library Integration",
            dependencies: [
                "Version",
            ]
        ),
        .testTarget(
            name: "Version Tests",
            dependencies: [
                "Version",
            ],
            path: "Tests/Version Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
