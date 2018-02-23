
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
    var content0: UInt64 = 0
    var content1: UInt64 = 0
    var negative: Bool = false

    init(_ value: Bigint) {
        self.content0 = value.content0
        self.content1 = value.content1
        self.negative = value.negative
    }

    init(_ value: Int) {
        var absolute = value
        self.negative = false
        if absolute < 0 {
            absolute = -1 * value
            self.negative = true
        }
        self.content0 = UInt64(absolute)
        self.content1 = 0
    }

    init(_ value: UInt) {
        self.negative = false
        self.content0 = UInt64(value)
        self.content1 = 0
    }

    func equals(_ other: Bigint) -> Bool {
        return self.content0 == other.content0 &&
               self.content1 == other.content1 &&
               self.negative == other.negative
    }


}
