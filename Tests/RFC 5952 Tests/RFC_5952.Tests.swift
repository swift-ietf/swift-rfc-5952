// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import RFC_4291
@testable import RFC_5952

@Suite("RFC 5952: IPv6 Text Representation Tests")
struct RFC5952Tests {

    // MARK: - RFC 5952 Section 4.1: Leading Zeros

    @Test
    func `RFC 5952 Section 4.1: Leading zeros MUST be suppressed`() throws {
        // 2001:0db8:0000:0000:0000:0000:0000:0001 → 2001:db8::1
        let address = RFC_4291.IPv6.Address(
            0x2001,
            0x0db8,
            0x0000,
            0x0000,
            0x0000,
            0x0000,
            0x0000,
            0x0001
        )
        let text = String(address)

        #expect(text == "2001:db8::1")
        #expect(!text.contains("0db8"))  // No leading zero
        #expect(!text.contains("0001"))  // No leading zeros
    }

    // MARK: - RFC 5952 Section 4.2: :: Usage

    @Test
    func `RFC 5952 Section 4.2.1: :: MUST be used for longest zero run`() throws {
        // Multiple zero runs, longest should be compressed
        let address = RFC_4291.IPv6.Address(
            0x2001,
            0x0db8,
            0x0000,
            0x0000,
            0x0000,
            0x0001,
            0x0000,
            0x0001
        )
        let text = String(address)

        // The run of 3 zeros (indices 2-4) should be compressed
        #expect(text == "2001:db8::1:0:1")
    }

    @Test
    func `RFC 5952 Section 4.2.2: Single zero MUST NOT use ::`() throws {
        // Single zeros should be represented as "0", not "::"
        let address = RFC_4291.IPv6.Address(
            0x2001,
            0x0db8,
            0x0000,
            0x0001,
            0x0000,
            0x0002,
            0x0000,
            0x0003
        )
        let text = String(address)

        #expect(text == "2001:db8:0:1:0:2:0:3")
        #expect(!text.contains("::"))  // No compression for single zeros
    }

    @Test
    func `RFC 5952 Section 4.2.3: Choose first occurrence when multiple equal runs`() throws {
        // Two runs of 2 zeros each - first should be compressed
        let address = RFC_4291.IPv6.Address(
            0x2001,
            0x0000,
            0x0000,
            0x0001,
            0x0000,
            0x0000,
            0x0001,
            0x0001
        )
        let text = String(address)

        // The first run (indices 1-2) should be compressed
        #expect(text == "2001::1:0:0:1:1")
    }

    // MARK: - RFC 5952 Section 4.3: Lowercase

    @Test
    func `RFC 5952 Section 4.3: Hexadecimal digits MUST be lowercase`() throws {
        let address = RFC_4291.IPv6.Address(
            0x2001,
            0x0db8,
            0x0abc,
            0x0def,
            0x0000,
            0x0000,
            0x0000,
            0x0001
        )
        let text = String(address)

        #expect(text == "2001:db8:abc:def::1")
        #expect(text.lowercased() == text)  // Must be all lowercase
        #expect(!text.contains("A"))
        #expect(!text.contains("B"))
        #expect(!text.contains("C"))
        #expect(!text.contains("D"))
        #expect(!text.contains("E"))
        #expect(!text.contains("F"))
    }

    // MARK: - Well-Known Addresses

    @Test
    func `Unspecified address (::)`() throws {
        let address = RFC_4291.IPv6.Address.unspecified
        let text = String(address)

        #expect(text == "::")
    }

    @Test
    func `Loopback address (::1)`() throws {
        let address = RFC_4291.IPv6.Address.loopback
        let text = String(address)

        #expect(text == "::1")
    }

    @Test
    func `IPv4-mapped IPv6 address`() throws {
        // ::ffff:192.0.2.1 (in pure IPv6 notation)
        let address = RFC_4291.IPv6.Address(0, 0, 0, 0, 0, 0xffff, 0xc000, 0x0201)
        let text = String(address)

        #expect(text == "::ffff:c000:201")
    }

    @Test
    func `Documentation prefix (2001:db8::/32)`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "2001:db8::1")
    }

    @Test
    func `Link-local address (fe80::)`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "fe80::1")
    }

    @Test
    func `Multicast address (ff02::1)`() throws {
        let address = RFC_4291.IPv6.Address(0xff02, 0, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "ff02::1")
    }

    // MARK: - Edge Cases

    @Test
    func `No compression needed - no zero runs`() throws {
        let address = RFC_4291.IPv6.Address(
            0x2001,
            0x0db8,
            0x0001,
            0x0002,
            0x0003,
            0x0004,
            0x0005,
            0x0006
        )
        let text = String(address)

        #expect(text == "2001:db8:1:2:3:4:5:6")
        #expect(!text.contains("::"))
    }

    @Test
    func `Compression at beginning`() throws {
        let address = RFC_4291.IPv6.Address(0, 0, 0, 1, 2, 3, 4, 5)
        let text = String(address)

        #expect(text == "::1:2:3:4:5")
    }

    @Test
    func `Compression at end`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 1, 2, 0, 0, 0, 0)
        let text = String(address)

        #expect(text == "2001:db8:1:2::")
    }

    @Test
    func `Compression in middle`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 1, 2)
        let text = String(address)

        #expect(text == "2001:db8::1:2")
    }

    @Test
    func `Maximum value segments`() throws {
        let address = RFC_4291.IPv6.Address(
            0xffff,
            0xffff,
            0xffff,
            0xffff,
            0xffff,
            0xffff,
            0xffff,
            0xffff
        )
        let text = String(address)

        #expect(text == "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
    }

    // MARK: - Canonicalization Examples from RFC 5952

    @Test
    func `RFC 5952 Example: 2001:db8:0:0:1:0:0:1`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 1, 0, 0, 1)
        let text = String(address)

        // Longest run is 2 zeros at position 2-3
        #expect(text == "2001:db8::1:0:0:1")
    }

    @Test
    func `RFC 5952 Example: 2001:0db8:0:0:0:0:0:1`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let text = String(address)

        #expect(text == "2001:db8::1")
    }
}

// MARK: - Canonical text surface (retroactive conformances — moved from rfc-4291)

/// The RFC 5952 canonical text *serialization* surface for `RFC_4291.IPv6.Address`
/// lives in this package (DECISION 3, Option B): `ASCII.Serializable`,
/// `description`, `rawValue`, and `Codable` are all retroactive conformances that
/// route through the single canonical verb.
@Suite("RFC 5952 canonical text surface")
struct CanonicalTextSurfaceTests {

    @Test
    func `description is the canonical RFC 5952 text`() {
        let addr = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        #expect(addr.description == "2001:db8::1")
        #expect(RFC_4291.IPv6.Address.loopback.description == "::1")
        #expect(RFC_4291.IPv6.Address.unspecified.description == "::")
    }

    @Test
    func `rawValue is the canonical RFC 5952 text`() {
        let addr = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        #expect(addr.rawValue == "2001:db8::1")
        #expect(RFC_4291.IPv6.Address(0xABCD, 0xEF01, 0, 0, 0, 0, 0, 1).rawValue == "abcd:ef01::1")
    }

    @Test
    func `init(rawValue:) round-trips through the canonical text`() {
        let cases: [RFC_4291.IPv6.Address] = [
            .loopback,
            .unspecified,
            RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x1234, 0x5678, 0x9abc, 0xdef0, 0x1111, 0x2222),
            RFC_4291.IPv6.Address(0, 0, 0, 0, 0, 0, 0x8a2e, 0x7334),
            RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
        ]
        for original in cases {
            let parsed = RFC_4291.IPv6.Address(rawValue: original.rawValue)
            #expect(parsed == original)
        }
    }

    @Test
    func `init(rawValue:) returns nil for invalid or empty text`() {
        #expect(RFC_4291.IPv6.Address(rawValue: "not-an-address") == nil)
        #expect(RFC_4291.IPv6.Address(rawValue: "") == nil)
    }

    /// Canonical dual-projection consistency: the typed ASCII text path
    /// (`[ASCII.Code]`) projects byte-for-byte (`map(\.byte)`) to the
    /// `.serialized` byte form. Both derive from the single canonical verb.
    @Test
    func `asciiCodes map byte equals serialized wire bytes`() {
        let addr = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x85a3, 0, 0, 0x8a2e, 0x0370, 0x7334)
        let ascii = addr.asciiCodes
        let wire = addr.serialized
        #expect(ascii.map(\.byte) == wire)
    }

    /// The `@retroactive Codable` conformance encodes the canonical text
    /// (`description`) into a single-value container and decodes via the RFC 4291
    /// grammar parser (`init(ascii:)`). Both delegates are tested above; here we
    /// exercise the conformance through a minimal Foundation-free single-value
    /// coder (this standards package stays Foundation-free per [PRIM-FOUND-001]).
    @Test
    func `Codable encodes the canonical text and decodes it back`() throws {
        let original = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)

        let encoded = SingleStringCoder.encode(original)
        #expect(encoded == "2001:db8::1")  // canonical text payload

        let decoded = try SingleStringCoder.decode(RFC_4291.IPv6.Address.self, from: encoded)
        #expect(decoded == original)
    }
}

// MARK: - Foundation-free single-value string coder (test support)

/// Minimal `Encoder`/`Decoder` that carries a single `String` value, used to
/// exercise a `Codable` conformance whose single-value payload is a string —
/// without importing Foundation into this standards test target.
private enum SingleStringCoder {
    static func encode<T: Encodable>(_ value: T) -> String {
        let encoder = StringEncoder()
        try? value.encode(to: encoder)
        return encoder.value ?? ""
    }

    static func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        try T(from: StringDecoder(string))
    }

    final class StringEncoder: Encoder, SingleValueEncodingContainer {
        var value: String?
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] = [:]

        func singleValueContainer() -> SingleValueEncodingContainer { self }
        func unkeyedContainer() -> UnkeyedEncodingContainer { fatalError("unsupported") }
        func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
            fatalError("unsupported")
        }

        func encodeNil() throws {}
        func encode(_ v: String) throws { value = v }
        func encode(_ v: Bool) throws { fatalError("unsupported") }
        func encode(_ v: Double) throws { fatalError("unsupported") }
        func encode(_ v: Float) throws { fatalError("unsupported") }
        func encode(_ v: Int) throws { fatalError("unsupported") }
        func encode(_ v: Int8) throws { fatalError("unsupported") }
        func encode(_ v: Int16) throws { fatalError("unsupported") }
        func encode(_ v: Int32) throws { fatalError("unsupported") }
        func encode(_ v: Int64) throws { fatalError("unsupported") }
        func encode(_ v: UInt) throws { fatalError("unsupported") }
        func encode(_ v: UInt8) throws { fatalError("unsupported") }
        func encode(_ v: UInt16) throws { fatalError("unsupported") }
        func encode(_ v: UInt32) throws { fatalError("unsupported") }
        func encode(_ v: UInt64) throws { fatalError("unsupported") }
        func encode<T: Encodable>(_ v: T) throws { try v.encode(to: self) }
    }

    struct StringDecoder: Decoder, SingleValueDecodingContainer {
        let string: String
        var codingPath: [any CodingKey] = []
        var userInfo: [CodingUserInfoKey: Any] = [:]

        init(_ string: String) { self.string = string }

        func singleValueContainer() throws -> SingleValueDecodingContainer { self }
        func unkeyedContainer() throws -> UnkeyedDecodingContainer { fatalError("unsupported") }
        func container<Key>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
            fatalError("unsupported")
        }

        func decodeNil() -> Bool { false }
        func decode(_ type: String.Type) throws -> String { string }
        func decode(_ type: Bool.Type) throws -> Bool { fatalError("unsupported") }
        func decode(_ type: Double.Type) throws -> Double { fatalError("unsupported") }
        func decode(_ type: Float.Type) throws -> Float { fatalError("unsupported") }
        func decode(_ type: Int.Type) throws -> Int { fatalError("unsupported") }
        func decode(_ type: Int8.Type) throws -> Int8 { fatalError("unsupported") }
        func decode(_ type: Int16.Type) throws -> Int16 { fatalError("unsupported") }
        func decode(_ type: Int32.Type) throws -> Int32 { fatalError("unsupported") }
        func decode(_ type: Int64.Type) throws -> Int64 { fatalError("unsupported") }
        func decode(_ type: UInt.Type) throws -> UInt { fatalError("unsupported") }
        func decode(_ type: UInt8.Type) throws -> UInt8 { fatalError("unsupported") }
        func decode(_ type: UInt16.Type) throws -> UInt16 { fatalError("unsupported") }
        func decode(_ type: UInt32.Type) throws -> UInt32 { fatalError("unsupported") }
        func decode(_ type: UInt64.Type) throws -> UInt64 { fatalError("unsupported") }
        func decode<T: Decodable>(_ type: T.Type) throws -> T { try T(from: self) }
    }
}
