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

// RFC_4291.IPv6.Address+RFC_5952.swift
// swift-rfc-5952
//
// RFC 5952 canonical serialization conformance for IPv6 addresses.
//
// Per DECISION 3 (Option B, spec-mirroring): each package owns the spec it
// encodes. RFC 4291 owns the address value, its wire form, and the §2.2 text
// grammar (parse); RFC 5952 owns the *canonical text serialization* choice.
// The canonical serialize verb and the String-facing text surface therefore
// live here as **retroactive** conformances (SE-0364 — this package owns
// neither `RFC_4291.IPv6.Address` nor these protocols).

import RFC_4291
public import RFC_4648

// MARK: - Canonical Serialization (RFC 5952) — the LIVE ASCII.Serializable

extension RFC_4291.IPv6.Address: @retroactive ASCII.Serializable {
    /// The **RFC 5952 canonical** text serializer — the live default text form
    /// for `RFC_4291.IPv6.Address` ([FAM-012] `ASCII.Serializable` sibling).
    ///
    /// **Source-defect-2 fix.** This body was formerly a dead, unreferenced
    /// `static func` (the user-facing `String`/`rawValue` path dispatched
    /// through RFC 4291's inline `Byte`-buffer serializer instead). It is now
    /// wired up as the live `ASCII.Serializable` conformance, so the derived
    /// accessors (`asciiCodes`, byte projection), `description`, `rawValue`, and
    /// `Codable` all route through the single canonical implementation.
    ///
    /// Canonical rules enforced:
    /// - Lowercase hexadecimal (RFC 5952 §4.3)
    /// - Leading zero suppression (§4.1)
    /// - `::` compression for the longest zero run, first on a tie (§4.2)
    ///
    /// Output is `[ASCII.Code]` (the typed text substrate); hex is produced by
    /// `RFC_4648.Base16.encode` (rfc-4648 is a spec-faithful lateral L2→L2 dep).
    static public func serialize<Buffer>(
        _ address: RFC_4291.IPv6.Address,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        let segments = [
            address.segments.0, address.segments.1, address.segments.2, address.segments.3,
            address.segments.4, address.segments.5, address.segments.6, address.segments.7,
        ]

        // RFC 5952 Section 4.2: Find longest run of consecutive zeros
        var longestZeroRun: (start: Int, length: Int) = (0, 0)
        var currentZeroRun: (start: Int, length: Int) = (0, 0)
        var inZeroRun = false

        for (index, segment) in segments.enumerated() {
            if segment == 0 {
                if !inZeroRun {
                    currentZeroRun = (index, 1)
                    inZeroRun = true
                } else {
                    currentZeroRun.length += 1
                }

                // Section 4.2.3: When equal, choose first occurrence
                if currentZeroRun.length > longestZeroRun.length {
                    longestZeroRun = currentZeroRun
                }
            } else {
                inZeroRun = false
            }
        }

        // Only compress if run has more than 1 zero segment
        let shouldCompress = longestZeroRun.length > 1

        // Maximum uncompressed: "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff" = 39 bytes
        buffer.reserveCapacity(39)

        var skipNext = false

        for index in 0..<8 {
            // Handle compression
            if shouldCompress && index >= longestZeroRun.start
                && index < longestZeroRun.start + longestZeroRun.length
            {
                if index == longestZeroRun.start {
                    // Section 4.2.2: "::" replaces the run
                    buffer.append(.colon)
                    buffer.append(.colon)
                    skipNext = true
                }
                continue
            }

            // Add colon separator (but not before first segment or after ::)
            if index > 0 && !skipNext {
                buffer.append(.colon)
            }
            skipNext = false

            // Section 4.3: Lowercase hexadecimal
            // Section 4.1: Leading zeros suppressed
            RFC_4648.Base16.encode(segments[index], into: &buffer, suppressLeadingZeros: true)
        }
    }
}

// MARK: - Canonical text surface (RFC 5952)

extension RFC_4291.IPv6.Address: @retroactive CustomStringConvertible {
    /// The address in canonical RFC 5952 text form, such as "2001:db8::1".
    ///
    /// Derived from the canonical `ASCII.Serializable` verb above.
    public var description: String {
        var codes: [ASCII.Code] = []
        RFC_4291.IPv6.Address.serialize(self, into: &codes)
        // `ASCII.Code.underlying` (UInt8) → the stdlib UTF-8 decoder; stays off
        // any byte-array bridge so no extra module import is required here.
        return String(decoding: codes.map(\.underlying), as: UTF8.self)
    }
}

extension RFC_4291.IPv6.Address: @retroactive Swift.RawRepresentable {
    /// The canonical RFC 5952 text representation.
    public var rawValue: String { description }

    /// Parses an IPv6 address from canonical (or any RFC 4291 §2.2) text via the
    /// RFC 4291 grammar parser. Returns `nil` for malformed text.
    public init?(rawValue: String) {
        do {
            try self.init(ascii: [Byte](rawValue.utf8))
        } catch {
            return nil
        }
    }
}

extension RFC_4291.IPv6.Address: @retroactive Encodable {
    /// Encodes the address as its canonical RFC 5952 text string.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension RFC_4291.IPv6.Address: @retroactive Decodable {
    /// Decodes an address from a text string via the RFC 4291 §2.2 grammar.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        do {
            try self.init(ascii: [Byte](string.utf8))
        } catch {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid IPv6 address: \(error)"
                )
            )
        }
    }
}
