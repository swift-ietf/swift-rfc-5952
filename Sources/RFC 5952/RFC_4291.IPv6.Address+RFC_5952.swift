import RFC_4291
public import RFC_4648

extension RFC_4291.IPv6.Address: @retroactive ASCII.Serializable {

    public static func serialize<Buffer>(
        _ address: RFC_4291.IPv6.Address,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == ASCII.Code {
        let segments = [
            address.segments.0, address.segments.1, address.segments.2, address.segments.3,
            address.segments.4, address.segments.5, address.segments.6, address.segments.7,
        ]

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

                if currentZeroRun.length > longestZeroRun.length {
                    longestZeroRun = currentZeroRun
                }
            } else {
                inZeroRun = false
            }
        }

        let shouldCompress = longestZeroRun.length > 1

        buffer.reserveCapacity(39)

        var skipNext = false

        (0..<8).forEach { index in

            if shouldCompress && index >= longestZeroRun.start
                && index < longestZeroRun.start + longestZeroRun.length
            {
                if index == longestZeroRun.start {

                    buffer.append(.colon)
                    buffer.append(.colon)
                    skipNext = true
                }
                return
            }

            if index > 0 && !skipNext {
                buffer.append(.colon)
            }
            skipNext = false

            RFC_4648.Base16.encode(segments[index], into: &buffer, suppressLeadingZeros: true)
        }
    }
}

extension RFC_4291.IPv6.Address: @retroactive CustomStringConvertible {

    public var description: String {
        var codes: [ASCII.Code] = []
        RFC_4291.IPv6.Address.serialize(self, into: &codes)

        return String(decoding: codes.map(\.underlying), as: UTF8.self)
    }
}

extension RFC_4291.IPv6.Address: @retroactive Swift.RawRepresentable {

    public var rawValue: String { description }

    public init?(rawValue: String) {
        do throws(RFC_4291.IPv6.Address.Error) {
            try self.init(ascii: [Byte](rawValue.utf8))
        } catch {
            return nil
        }
    }
}

extension RFC_4291.IPv6.Address: @retroactive Encodable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension RFC_4291.IPv6.Address: @retroactive Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        do throws(RFC_4291.IPv6.Address.Error) {
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
