public import RFC_4291

extension RFC_5952 {

    public struct Compression: Equatable, Hashable {

        public let start: Int

        public let count: Int

        public init?(_ address: RFC_4291.IPv6.Address) {
            let s = address.segments
            let segments: [UInt16] = [s.0, s.1, s.2, s.3, s.4, s.5, s.6, s.7]

            var longest: (start: Int, count: Int)?
            var current: (start: Int, count: Int)?

            for (index, segment) in segments.enumerated() {
                guard segment == 0 else {
                    current = nil
                    continue
                }

                let run = current.map { (start: $0.start, count: $0.count + 1) } ?? (start: index, count: 1)
                current = run

                if run.count > (longest?.count ?? 1) {
                    longest = run
                }
            }

            guard let longest else { return nil }

            self.start = longest.start
            self.count = longest.count
        }
    }
}

extension RFC_5952.Compression {

    public var range: Range<Int> { start..<(start + count) }

    public var end: Int { start + count }

    public func contains(_ index: Int) -> Bool { range.contains(index) }
}
