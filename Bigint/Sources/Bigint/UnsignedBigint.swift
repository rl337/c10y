
enum BigintError : Error {
    case Overflow(String)
    case Underflow(String)
    case Unsigned(String)
    case DivideByZero(String)
}

func == (left: UnsignedBigint, right: Int) throws -> Bool {
    return try left.equals(UnsignedBigint(right))
}

func == (left: Int, right: UnsignedBigint) throws -> Bool {
    return try right.equals(UnsignedBigint(left))
}

func == (left: UnsignedBigint, right: UInt) -> Bool {
    return left.equals(UnsignedBigint(right))
}

func == (left: UInt, right: UnsignedBigint) -> Bool {
    return right.equals(UnsignedBigint(left))
}

func + (left: UnsignedBigint, right: UnsignedBigint) throws -> UnsignedBigint {
    return try left.add(right)
}

func + (left: UnsignedBigint, right: Int) throws -> UnsignedBigint {
    return try left.add(UnsignedBigint(right))
}

func + (left: Int, right: UnsignedBigint) throws -> UnsignedBigint {
    return try UnsignedBigint(left).add(right)
}

func - (left: UnsignedBigint, right: UnsignedBigint) throws -> UnsignedBigint {
    return try left.subtract(right)
}

func * (left: UnsignedBigint, right: UnsignedBigint) throws -> UnsignedBigint {
    return try left.multiply(right)
}

func / (left: UnsignedBigint, right: UnsignedBigint) throws -> UnsignedBigint {
    return try left.divide(right)
}

func < (left: UnsignedBigint, right: UnsignedBigint) -> Bool {
    return left.compare(right) < 0
}

struct UnsignedBigint {
    static let default_size: Int = 4

    var content: [UInt64]


    init(capacity: Int = UnsignedBigint.default_size) {
        self.content = [UInt64](repeating: 0, count: capacity)
    }
    
    init(_ arr: [UInt64], negative sign: Bool) {
        self.content = arr
    }

    init(_ value: UnsignedBigint) {
        self.content = value.content
    }

    init(_ value: Int) throws {
        if value < 0 {
            throw BigintError.Unsigned("Attempt to assign negative int to UnsignedBigint")
        }
        self.content = [UInt64](repeating: 0, count: UnsignedBigint.default_size)
        content[0] = UInt64(value)
    }

    init(_ value: UInt) {
        self.content = [UInt64](repeating: 0, count: UnsignedBigint.default_size)
        self.content[0] = UInt64(value)
    }

    
    func compare(_ other: UnsignedBigint) -> Int {
        if self.content == other.content {
            return 0
        }

        for i in stride(from: content.count-1, through: 0, by: -1) {
            if self.content[i] < other.content[i] {
                return -1
            }
        }
        
        return 1
    }
    
    func equals(_ other: UnsignedBigint) -> Bool {
        return self.compare(other) == 0
    }
    
    func add(_ other: UnsignedBigint) throws -> UnsignedBigint {
        var result = UnsignedBigint(self)
        // The signs are the same, we can just plain add them.
        for i:Int in 0..<self.content.count {
            try CarryHelper.add_with_carry(other.content[i], &result.content[i...])
        }
        
        return result
    }
    
    func subtract(_ other: UnsignedBigint) throws -> UnsignedBigint {
        var result = UnsignedBigint(self)
        for i:Int in 0..<self.content.count {
            try CarryHelper.subtract_with_borrow(other.content[i], &result.content[i...])
        }
        
        return result
    }
    
    func multiply(_ other: UnsignedBigint) throws -> UnsignedBigint {
        var i = UnsignedBigint(UInt(0))
        var result = UnsignedBigint(UInt(0))
        while i < self {
            try i = i + 1
            try result = result + other
        }
        return result
    }
    
    func divide(_ other: UnsignedBigint) throws -> UnsignedBigint {
        var result = UnsignedBigint(UInt(0))
        var i = UnsignedBigint(self)
        
        if try self == UnsignedBigint(0) {
            
        }
        while i <= other {
            try i = i - other
            try result = result + 1
        }
        return result
    }

}

extension UnsignedBigint: Equatable {
    static func == (left: UnsignedBigint, right: UnsignedBigint) -> Bool {
        return left.equals(right)
    }
}

extension UnsignedBigint: Comparable {


}

extension UnsignedBigint: CustomStringConvertible {
    var description: String {
        var result = ""
        
        for i in stride(from: self.content.count-1, through: 0, by: -1) {
            result.append(String(self.content[i], radix: 16, uppercase: false))
        }
        return result
    }
}

extension UnsignedBigint: CustomDebugStringConvertible {
    var debugDescription: String {
        var result = ""

        for i in stride(from: self.content.count-1, through: 0, by: -1) {
            result.append(String(self.content[i], radix: 16, uppercase: false))
        }
        return result
    }
}
