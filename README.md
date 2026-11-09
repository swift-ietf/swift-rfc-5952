# swift-rfc-5952

Use this package when you need the one canonical text form of an IPv6 address, for display, logs or comparing addresses as text. Start from `RFC_4291.IPv6.Address.Text.Canonical` to write the text, or from `RFC_5952.Compression` if you only need to know which zero fields collapse. For the address type itself and parsing, use swift-rfc-4291. For one namespace that combines both with scoped addresses, use swift-ipv6-standard.

## Laws

- Only the longest run of zero fields is compressed. A single zero field is never compressed, and an address with no run of two or more zero fields has no `RFC_5952.Compression`.
- When two runs of zero fields are equally long, the first one is compressed.
- `RFC_5952.Compression.start` counts fields from 0, and `RFC_5952.Compression.range` covers exactly the compressed fields, so `RFC_5952.Compression.end` is the first field after the run.
- The canonical text writes hexadecimal digits in lowercase, drops leading zeros in each field, and writes the compressed run as a double colon. The unspecified address is a bare double colon, and the loopback address is a double colon followed by 1.
- An IPv4-mapped address (`::ffff:0:0/96`) or IPv4-translated address (`::ffff:0:0:0/96`) writes its last 32 bits in dotted-decimal form, as in `::ffff:192.0.2.1`, following RFC 5952 section 5. Every other address is written in hexadecimal only.
