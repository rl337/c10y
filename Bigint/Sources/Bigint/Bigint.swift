
enum BigintError : Error {
    case Overflow(String)
}

func == (left: Bigint, right: Bigint) -> Bool {
    return left.equals(right)
}

func == (left: Bigint, right: Int) -> Bool {
    return left.equals(Bigint(right))
}

func == (left: Int, right: Bigint) -> Bool {
    return right.equals(Bigint(left))
}

func == (left: Bigint, right: UInt) -> Bool {
    return left.equals(Bigint(right))
}

func == (left: UInt, right: Bigint) -> Bool {
    return right.equals(Bigint(left))
}

struct Bigint {
    static let default_size: Int = 4

    var content: [UInt64]
    var negative: Bool

    init(capacity: Int = default_size) {
        self.content = [UInt64](repeating: 0, count: capacity)
        self.negative = false
    }

    init(_ value: Bigint) {
        self.content = value.content
        self.negative = value.negative
    }

    init(_ value: Int) {
        var absolute = value
        self.negative = false
        if absolute < 0 {
            absolute = -1 * value
            self.negative = true
        }
        self.content = [ UInt64(absolute) ]
    }

    init(_ value: UInt) {
        self.negative = false
        self.content = [ UInt64(value) ]
    }

    func equals(_ other: Bigint) -> Bool {
        return self.content == other.content &&
               self.negative == other.negative
    }

}
