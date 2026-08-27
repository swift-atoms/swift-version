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
        .library(
            name: "Version Apple Foundation Integration",
            targets: ["Version Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Version",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged")
            ]
        ),
        .target(
            name: "Version Standard Library Integration",
            dependencies: [
                "Version",
                .product(name: "Tagged Standard Library Integration", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Version Apple Foundation Integration",
            dependencies: [
                "Version",
                "Version Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Version Tests",
            dependencies: [
                "Version",
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .testTarget(
            name: "Version Standard Library Integration Tests",
            dependencies: [
                "Version",
                "Version Standard Library Integration",
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Tagged Standard Library Integration", package: "swift-tagged"),
            ]
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
