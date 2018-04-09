
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

func * (left: UnsignedBigint, right: Int) throws -> UnsignedBigint {
    return try left.multiply(UnsignedBigint(right))
}

func / (left: UnsignedBigint, right: UnsignedBigint) throws -> UnsignedBigint {
    return try left.divide(right)
}

func / (left: UnsignedBigint, right: Int) throws -> UnsignedBigint {
    return try left.divide(try UnsignedBigint(right))
}

func < (left: UnsignedBigint, right: UnsignedBigint) -> Bool {
    return left.compare(right) < 0
}

func > (left: UnsignedBigint, right: UnsignedBigint) -> Bool {
    return left.compare(right) > 0
}

func > (left: UnsignedBigint, right: Int) throws -> Bool {
    return left.compare(try UnsignedBigint(right)) > 0
}

func <= (left: UnsignedBigint, right: Int) throws -> Bool {
    return left.compare(try UnsignedBigint(right)) <= 0
}

func >= (left: UnsignedBigint, right: Int) throws -> Bool {
    return left.compare(try UnsignedBigint(right)) >= 0
}

struct UnsignedBigint {
    static let default_size: Int = 4

    var content: [UInt32]


    init(capacity: Int = UnsignedBigint.default_size) {
        self.content = [UInt32](repeating: 0, count: capacity)
    }
    
    init(_ arr: [UInt32]) {
        self.content = arr
    }

    init(_ value: UnsignedBigint) {
        self.content = value.content
    }

    init(_ value: Int) throws {
        if value < 0 {
            throw BigintError.Unsigned("Attempt to assign negative int to UnsignedBigint")
        }
        self.content = [UInt32](repeating: 0, count: UnsignedBigint.default_size)
        content[0] = UInt32(value)
    }

    init(_ value: UInt) {
        self.content = [UInt32](repeating: 0, count: UnsignedBigint.default_size)
        if UInt.max > UInt32.max {
            let (part1, part2) = CarryHelper.splitUInt64(UInt64(value))
            self.content[0] = part1
            self.content[1] = part2
        } else {
            self.content[0] = UInt32(value)
        }
    }

    init(_ value: UInt32) {
        self.content = [UInt32](repeating: 0, count: UnsignedBigint.default_size)
        self.content[0] = value
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
    
    /*
     * When multiplying numbers ABCD with EF we multiply it by hand like this:
     *             A  B  C  D
     *                *  E  F
     *          --------------
     * (P1)     H4 G4 G3 G2 G1
     * (P2)  K4 J4 J3 J2 J1 0
     *
     * Product is P1 + P2
     *
     *   Where G and H are:     and J and K are
     *   (G1,H1) = F*D          (J1,K1) = E*D
     *   (G2,H2) = F*C + H1     (J2,K2) = E*C + K1
     *   (G3,H3) = F*B + H2     (J3,K3) = E*B + K2
     *   (G4,H4) = F*A + H3     (J4,K4) = E*A + K3
     */
    func multiply(_ other: UnsignedBigint) throws -> UnsignedBigint {
        var result = try UnsignedBigint(0)
        for i in 0..<self.content.count {
            var partialProduct = try UnsignedBigint(0)
            for j in 0..<other.content.count {
                let placeProduct: UInt64 = UInt64(self.content[i]) * UInt64(other.content[j])
                
                let (part1, part2) = CarryHelper.splitUInt64(placeProduct)
                partialProduct.content[j] = part1
                // This needs to be fixed with a variable length bigint
                if part2 > 0 && j < partialProduct.content.count {
                    try CarryHelper.add_with_carry(part2, &partialProduct.content[(j+1)...])
                }
            }
            try result = result + partialProduct
        }
        return result
    }
    
    func divide(_ other: UnsignedBigint) throws -> UnsignedBigint {
        var result = UnsignedBigint(UInt(0))
        var i = UnsignedBigint(self)
        
        if try other == UnsignedBigint(0) {
            throw BigintError.DivideByZero("Division by zero")
        }
        
        if try self == UnsignedBigint(0) {
            return self
        }
        
        
        
        while i >= other {
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
        
//        var result = ""
//
//        for i in stride(from: self.content.count-1, through: 0, by: -1) {
//            result.append(String(self.content[i], radix: 16, uppercase: false))
//        }
//        return result
        var result = ""

        if self == UnsignedBigint(UInt(0)) {
            return "0"
        }

        var rest = UnsignedBigint(self)
        do {
            var place = try UnsignedBigint(1)
            while try place * 10 < rest {
                place = try place * 10
            }

            while try place >= 1 {
                var digit = 0
                while rest >= place {
                    rest = try rest - place
                    digit = digit + 1
                }
                result.append(digit.description)
                place = try place / 10
            }
            return result
        } catch {
            return ""
        }
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
