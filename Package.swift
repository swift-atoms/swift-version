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
        .library(name: "Version", targets: ["Version"]),

        .library(name: "Version Foundation Integration", targets: ["Version Foundation Integration"]),
        .library(name: "Version Test Support", targets: ["Version Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Version",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Sources/Version"
        ),
        
        .target(
            name: "Version Foundation Integration",
            dependencies: [
                .target(name: "Version"),
            ],
            path: "Sources/Version Foundation Integration"
        ),
        .target(
            name: "Version Test Support",
            dependencies: [
                .target(name: "Version"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Version Tests",
            dependencies: [
                .target(name: "Version"),
                .target(name: "Version Test Support"),
                .target(name: "Version Foundation Integration"),
            ],
            path: "Tests/Version Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
