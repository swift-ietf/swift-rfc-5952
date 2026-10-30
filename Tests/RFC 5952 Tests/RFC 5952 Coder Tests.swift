#if Coder
    import ASCII
    import RFC_4291
    import RFC_4291
    import RFC_5952
    import Serializer
    import Testing

    @Suite
    struct `RFC 5952 Coder Tests` {
        @Suite struct `Canonical Text Tests` {}
    }

    extension `RFC 5952 Coder Tests`.`Canonical Text Tests` {

        static func text(_ address: RFC_4291.IPv6.Address) -> String {
            var codes: [ASCII.Code] = []
            RFC_4291.IPv6.Address.Text.Canonical().serialize(address, into: &codes)

            return String(decoding: codes.map(\.underlying), as: UTF8.self)
        }

        @Test
        func `leading zeros in a field are suppressed`() {
            #expect(Self.text(RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)) == "2001:db8::1")
        }

        @Test
        func `the longest run of zero fields becomes a double colon`() {
            #expect(
                Self.text(RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 1, 0, 1)) == "2001:db8::1:0:1"
            )
        }

        @Test
        func `a single zero field is written out`() {
            #expect(
                Self.text(RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 1, 0, 2, 0, 3))
                    == "2001:db8:0:1:0:2:0:3"
            )
        }

        @Test
        func `the first of two equally long runs is compressed`() {
            #expect(Self.text(RFC_4291.IPv6.Address(0x2001, 0, 0, 1, 0, 0, 1, 1)) == "2001::1:0:0:1:1")
        }

        @Test
        func `hexadecimal digits are lowercase`() {
            #expect(
                Self.text(RFC_4291.IPv6.Address(0x2001, 0x0db8, 0x0abc, 0x0def, 0, 0, 0, 1))
                    == "2001:db8:abc:def::1"
            )
        }

        @Test
        func `the unspecified address is a bare double colon`() {
            #expect(Self.text(.unspecified) == "::")
        }

        @Test
        func `the loopback address is a double colon and one`() {
            #expect(Self.text(.loopback) == "::1")
        }

        @Test
        func `an IPv4-mapped address keeps its hexadecimal fields`() {
            #expect(
                Self.text(RFC_4291.IPv6.Address(0, 0, 0, 0, 0, 0xffff, 0xc000, 0x0201))
                    == "::ffff:c000:201"
            )
        }

        @Test
        func `a run at the start of the address is compressed`() {
            #expect(Self.text(RFC_4291.IPv6.Address(0, 0, 0, 1, 2, 3, 4, 5)) == "::1:2:3:4:5")
        }

        @Test
        func `a run at the end of the address is compressed`() {
            #expect(Self.text(RFC_4291.IPv6.Address(0x2001, 0x0db8, 1, 2, 0, 0, 0, 0)) == "2001:db8:1:2::")
        }

        @Test
        func `an address without zero fields is written in full`() {
            #expect(
                Self.text(RFC_4291.IPv6.Address(0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff))
                    == "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff"
            )
        }

        @Test
        func `the canonical serializer is reachable through the serializer namespace`() {
            var codes: [ASCII.Code] = []
            let serializer: RFC_4291.IPv6.Address.Text.Canonical = .canonical
            serializer.serialize(.loopback, into: &codes)

            #expect(String(decoding: codes.map(\.underlying), as: UTF8.self) == "::1")
        }
    }
#endif
