
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

func + (left: Bigint, right: Bigint) throws -> Bigint {
    return try left.add(right)
}

func < (left: Bigint, right: Bigint) throws -> Bool {
    return left.compare(right) < 0
}

struct Bigint {
    static let default_size: Int = 4

    var content: [UInt64]
    var capacity: Int
    var negative: Bool

    init(capacity: Int = Bigint.default_size) {
        self.capacity = capacity
        self.content = [UInt64](repeating: 0, count: capacity)
        self.negative = false
    }
    
    init(_ arr: [UInt64], negative sign: Bool) {
        self.capacity = arr.count
        self.content = arr
        self.negative = sign
    }

    init(_ value: Bigint) {
        self.capacity = Bigint.default_size
        self.content = value.content
        self.capacity = value.capacity
        self.negative = value.negative
    }

    init(_ value: Int) {
        self.capacity = Bigint.default_size
        self.content = [UInt64](repeating: 0, count: capacity)
        var absolute = value
        self.negative = false
        if absolute < 0 {
            absolute = -1 * value
            self.negative = true
        }
        content[0] = UInt64(absolute)
    }

    init(_ value: UInt) {
        self.capacity = Bigint.default_size
        self.content = [UInt64](repeating: 0, count: capacity)
        self.negative = false
        self.content[0] = UInt64(value)
    }

    
    func compare(_ other: Bigint) -> Int {
        
        if self.negative == other.negative {
            if self.content == other.content {
                return 0
            }
            
            if self.negative {
                for i in stride(from: content.count-1, through: 0, by: -1) {
                    if self.content[i] > other.content[i] {
                        return -1
                    }
                }
            } else {
                for i in stride(from: content.count-1, through: 0, by: -1) {
                    if self.content[i] < other.content[i] {
                        return -1
                    }
                }
            }
            
            return 1
        }
        
        if self.negative {
            return -1
        }
        
        return 1
    }
    
    func equals(_ other: Bigint) -> Bool {
        return self.compare(other) == 0
    }
    
    func add(_ other: Bigint) throws -> Bigint {
        var result = Bigint(self)
        for i:Int in 0..<self.content.count {
            try CarryHelper.add_with_carry(other.content[i], &result.content[i...])
        }
        
        return result
    }

}

extension Bigint: CustomStringConvertible {
    var description: String {
        var result = ""
        
        for i in stride(from: self.capacity-1, through: 0, by: -1) {
            result.append(String(self.content[i], radix: 16, uppercase: false))
        }
        return result
    }
}

extension Bigint: CustomDebugStringConvertible {
    var debugDescription: String {
        var result = ""

        for i in stride(from: self.capacity-1, through: 0, by: -1) {
            result.append(String(self.content[i], radix: 16, uppercase: false))
        }
        return result
    }
}
