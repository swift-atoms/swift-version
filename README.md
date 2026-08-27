# swift-version

Typed semantic-version and Swift tools-version values, ranges, and sets.

`swift-version` is a Swift atom with a Foundation-free core. It models SemVer 2.0.0 values and Swift tools-version values with distinct tagged components, plus reusable range and set algebra.

## Installation

Add the package from its canonical home:

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-atoms/swift-version.git",
        branch: "main"
    )
]
```

Then depend on the narrowest product your target needs:

```swift
.product(name: "Version", package: "swift-version")
```

## Core

The `Version` product provides typed values and algebra without Foundation:

```swift
import Version

let version = Version.Semantic(major: 1, minor: 2, patch: 3)
let tools = Version.Tools(major: 6, minor: 4)

let compatible = Version.Range<Version.Semantic>.upToNextMajor(from: version)
let requirement = Version.Set.range(compatible)
```

Semantic versions compare according to SemVer precedence. Build metadata is preserved but does not participate in equality, hashing, or ordering.

## Standard library integration

The `Version Standard Library Integration` product adds parsing, descriptions, string literals, `Swift.Range` integration, and Codable conformances:

```swift
import Version_Standard_Library_Integration

let semantic = try Version.Semantic(parsing: "1.2.3-rc.1+build.456")
let tools = try Version.Tools(parsing: "6.4")

let literal: Version.Semantic = "2.0.0"
print(semantic.description)
```

Codable support is omitted when Swift's Embedded feature is enabled. The remaining core and standard-library integration stay Foundation-free.

## Products

- `Version` — typed semantic/tools versions, phases, bumps, ranges, and sets.
- `Version Standard Library Integration` — parsing, descriptions, literals, Codable, and standard-library range integration.
- `Version Apple Foundation Integration` — the Foundation-facing integration seam; this is the only product that imports Foundation.

The package depends only on [`swift-atoms/swift-tagged`](https://github.com/swift-atoms/swift-tagged), which gives version components distinct types.

## License

See [LICENSE.md](LICENSE.md).
