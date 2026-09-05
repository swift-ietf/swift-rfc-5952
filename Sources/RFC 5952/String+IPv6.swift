public import RFC_4291

extension String {

    public init(_ address: RFC_4291.IPv6.Address) {

        self = address.description
    }
}
