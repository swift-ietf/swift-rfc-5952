// swift-tools-version: 6.4
import PackageDescription

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
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-serializer.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 5952",
            dependencies: [
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Serializable ASCII", package: "swift-ascii-serializer"),
            ]
        ),
        .testTarget(
            name: "RFC 5952 Tests",
            dependencies: [
                "RFC 5952",
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Serializable ASCII", package: "swift-ascii-serializer"),
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
