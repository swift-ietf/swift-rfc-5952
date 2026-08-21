// swift-tools-version: 6.4
import PackageDescription

extension String {
    static let rfc5952 = "RFC 5952"
    var tests: Self { "\(self) Tests" }
}

extension Target.Dependency {
    static let rfc5952 = Self.target(name: .rfc5952)
    static let rfc4291 = Self.product(name: "RFC 4291", package: "swift-rfc-4291")
    static let standards = Self.product(
        name: "Standard Library Extensions",
        package: "swift-standard-library-extensions"
    )
    static let incits41986 = Self.product(
        name: "ASCII Primitives",
        package: "swift-ascii-primitives"
    )
    static let rfc4648 = Self.product(name: "RFC 4648", package: "swift-rfc-4648")
}

let package = Package(
    name: "swift-rfc-5952",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(name: "RFC 5952", targets: ["RFC 5952"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-4291.git", branch: "main"),
        .package(
            url: "https://github.com/swift-primitives/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ascii-primitives.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 5952",
            dependencies: [.rfc4291, .standards, .incits41986, .rfc4648]
        ),
        .testTarget(
            name: "RFC 5952 Tests",
            dependencies: [
                "RFC 5952"
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
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
