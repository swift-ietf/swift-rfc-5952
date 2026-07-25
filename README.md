# swift-rfc-5952

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Canonical text representation of IPv6 addresses per RFC 5952.

## Standard Reference

- **RFC**: 5952
- **Title**: A Recommendation for IPv6 Address Text Representation

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", from: "0.1.5")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 5952", package: "swift-rfc-5952")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
