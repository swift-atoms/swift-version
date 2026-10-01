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
    traits: [
        .trait(name: "Calendar", description: "Calendar integration"),
        .trait(name: "Parser", description: "Parser integration", enabledTraits: ["Bytes"]),
        .trait(name: "Serializer", description: "Serializer integration", enabledTraits: ["Bytes"]),
        .trait(name: "Bytes", description: "Shared byte representation for parsing and serialization"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-calendar-gregorian.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main", traits: [.trait(name: "Parser", condition: .when(traits: ["Parser"]))]),
        .package(url: "https://github.com/swift-atoms/swift-checkpoint.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main", traits: [.trait(name: "Collection", condition: .when(traits: ["Parser"]))]),
        .package(url: "https://github.com/swift-atoms/swift-iterator.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ordinal.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-text.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Version",
            dependencies: [
                .product(name: "Calendar Gregorian", package: "swift-calendar-gregorian", condition: .when(traits: ["Calendar"])),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Byte", package: "swift-byte", condition: .when(traits: ["Bytes", "Parser", "Serializer"])),
                .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Parser"])),
                .product(name: "ASCII", package: "swift-ascii", condition: .when(traits: ["Parser"])),
                .product(name: "Checkpoint", package: "swift-checkpoint", condition: .when(traits: ["Parser"])),
                .product(name: "Cursor", package: "swift-cursor", condition: .when(traits: ["Parser"])),
                .product(name: "Iterator", package: "swift-iterator", condition: .when(traits: ["Parser"])),
                .product(name: "Ordinal", package: "swift-ordinal", condition: .when(traits: ["Parser"])),
                .product(name: "Text", package: "swift-text", condition: .when(traits: ["Parser"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Serializer"])),
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
        .testTarget(name: "Version Parser Integration Tests", dependencies: [.product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Parser"])), .target(name: "Version"), .product(name: "Byte", package: "swift-byte", condition: .when(traits: ["Parser"])), .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Parser"])), .product(name: "ASCII", package: "swift-ascii", condition: .when(traits: ["Parser"])), .product(name: "Checkpoint", package: "swift-checkpoint", condition: .when(traits: ["Parser"])), .product(name: "Cursor", package: "swift-cursor", condition: .when(traits: ["Parser"])), .product(name: "Iterator", package: "swift-iterator", condition: .when(traits: ["Parser"])), .product(name: "Ordinal", package: "swift-ordinal", condition: .when(traits: ["Parser"])), .product(name: "Text", package: "swift-text", condition: .when(traits: ["Parser"])), .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Parser"]))], path: "Tests/Version Parser Integration Tests"),
        .testTarget(name: "Version Calendar Parser Tests", dependencies: [.product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Parser"])), .product(name: "Calendar Gregorian", package: "swift-calendar-gregorian", condition: .when(traits: ["Calendar"])), .target(name: "Version"), .product(name: "Byte", package: "swift-byte", condition: .when(traits: ["Parser"])), .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Parser"])), .product(name: "ASCII", package: "swift-ascii", condition: .when(traits: ["Parser"])), .product(name: "Checkpoint", package: "swift-checkpoint", condition: .when(traits: ["Parser"])), .product(name: "Cursor", package: "swift-cursor", condition: .when(traits: ["Parser"])), .product(name: "Iterator", package: "swift-iterator", condition: .when(traits: ["Parser"])), .product(name: "Ordinal", package: "swift-ordinal", condition: .when(traits: ["Parser"])), .product(name: "Text", package: "swift-text", condition: .when(traits: ["Parser"])), .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Parser"]))], path: "Tests/Version Calendar Parser Tests"),
        .testTarget(name: "Version Serializer Integration Tests", dependencies: [.target(name: "Version"), .product(name: "Byte", package: "swift-byte", condition: .when(traits: ["Serializer"])), .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Serializer"]))], path: "Tests/Version Serializer Integration Tests"),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
