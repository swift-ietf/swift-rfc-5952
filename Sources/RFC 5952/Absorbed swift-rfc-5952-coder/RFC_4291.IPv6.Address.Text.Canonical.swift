#if Coder
    public import ASCII
    public import RFC_4291
    public import RFC_4291
    import RFC_4648
    import Serializer

    extension RFC_4291.IPv6.Address.Text {

        public struct Canonical: Serializer::Serializing {

            public init() {}
        }
    }

    extension RFC_4291.IPv6.Address.Text.Canonical {
        public typealias Output = RFC_4291.IPv6.Address
        public typealias Buffer = [ASCII.Code]
        public typealias Failure = Never

        public borrowing func serialize(
            _ address: RFC_4291.IPv6.Address,
            into buffer: inout [ASCII.Code]
        ) {
            let s = address.segments
            let segments: [UInt16] = [s.0, s.1, s.2, s.3, s.4, s.5, s.6, s.7]
            let compression = RFC_5952.Compression(address)

            let embedsIPv4 =
                segments[0..<4].allSatisfy { $0 == 0 }
                && ((segments[4] == 0 && segments[5] == 0xffff) || (segments[4] == 0xffff && segments[5] == 0))
            let hexadecimalCount = embedsIPv4 ? 6 : segments.count

            buffer.reserveCapacity(45)

            var index = 0
            while index < hexadecimalCount {
                if let compression, index == compression.start {
                    buffer.append(ASCII.Code.colon)
                    buffer.append(ASCII.Code.colon)
                    index = compression.end
                    continue
                }

                if index > 0, compression?.end != index {
                    buffer.append(ASCII.Code.colon)
                }

                RFC_4648.Base16.encode(segments[index], into: &buffer, suppressLeadingZeros: true)
                index += 1
            }

            guard embedsIPv4 else { return }

            if compression?.end != hexadecimalCount {
                buffer.append(ASCII.Code.colon)
            }

            for (offset, octet) in [s.6 >> 8, s.6 & 0xff, s.7 >> 8, s.7 & 0xff].enumerated() {
                if offset > 0 {
                    buffer.append(ASCII.Code.period)
                }
                ASCII.Decimal.serialize(octet, into: &buffer)
            }
        }
    }

    extension Serializer::Serializing where Self == RFC_4291.IPv6.Address.Text.Canonical {

        public static var canonical: RFC_4291.IPv6.Address.Text.Canonical { .init() }
    }
#endif
