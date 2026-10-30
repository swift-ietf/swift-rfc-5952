// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rfc-5952",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 5952", targets: ["RFC 5952"])
    ],
    traits: [
        .trait(name: "Coder", description: "Wire coders for RFC 5952 types")
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-ietf/swift-rfc-4291.git",
            branch: "main",
            traits: [.trait(name: "Coder", condition: .when(traits: ["Coder"]))]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ascii.git",
            branch: "main",
            traits: [
                .trait(name: "Parser", condition: .when(traits: ["Coder"])),
                .trait(name: "Serializer", condition: .when(traits: ["Coder"])),
            ]
        ),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4648.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 5952",
            dependencies: [
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
                .product(name: "ASCII", package: "swift-ascii", condition: .when(traits: ["Coder"])),
                .product(name: "RFC 4648", package: "swift-rfc-4648", condition: .when(traits: ["Coder"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Coder"])),
            ]
        ),
        .testTarget(
            name: "RFC 5952 Tests",
            dependencies: [
                .target(name: "RFC 5952"),
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
                .product(name: "ASCII", package: "swift-ascii", condition: .when(traits: ["Coder"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Coder"])),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
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
