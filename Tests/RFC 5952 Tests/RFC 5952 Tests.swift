import RFC_4291
import RFC_5952
import Testing

@Suite
struct `RFC 5952 Tests` {
    @Suite struct `Zero Compression Tests` {}
    @Suite struct `Compression Range Tests` {}
}

extension `RFC 5952 Tests`.`Zero Compression Tests` {

    @Test
    func `the longest run of zero fields is compressed`() {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 1, 0, 1)

        #expect(RFC_5952.Compression(address) == RFC_5952.Compression(address))
        #expect(RFC_5952.Compression(address)?.start == 2)
        #expect(RFC_5952.Compression(address)?.count == 3)
    }

    @Test
    func `a single zero field is never compressed`() {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 1, 0, 2, 0, 3)

        #expect(RFC_5952.Compression(address) == nil)
    }

    @Test
    func `the first of two equally long runs wins`() {
        let address = RFC_4291.IPv6.Address(0x2001, 0, 0, 1, 0, 0, 1, 1)

        #expect(RFC_5952.Compression(address)?.start == 1)
        #expect(RFC_5952.Compression(address)?.count == 2)
    }

    @Test
    func `an address without zero fields compresses nothing`() {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 1, 2, 3, 4, 5, 6)

        #expect(RFC_5952.Compression(address) == nil)
    }

    @Test
    func `the unspecified address compresses every field`() {
        let compression = RFC_5952.Compression(.unspecified)

        #expect(compression?.start == 0)
        #expect(compression?.count == 8)
    }

    @Test
    func `the loopback address compresses the leading seven fields`() {
        let compression = RFC_5952.Compression(.loopback)

        #expect(compression?.start == 0)
        #expect(compression?.count == 7)
    }

    @Test
    func `a run at the end of the address is compressed`() {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 1, 2, 0, 0, 0, 0)

        #expect(RFC_5952.Compression(address)?.start == 4)
        #expect(RFC_5952.Compression(address)?.count == 4)
    }
}

extension `RFC 5952 Tests`.`Compression Range Tests` {

    @Test
    func `the range covers exactly the compressed fields`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let compression = try #require(RFC_5952.Compression(address))

        #expect(compression.range == 2..<7)
        #expect(compression.end == 7)
        #expect(compression.contains(2))
        #expect(compression.contains(6))
        #expect(!compression.contains(7))
    }
}
