
import XCTest
@testable import Bigint

class CarryHelperTests: XCTestCase {
    func testNonCarry() {
        let (value, carry) = CarryHelper.add(3, 5)
        XCTAssertEqual(UInt64(0), carry)
        XCTAssertEqual(UInt64(8), value)
    }
    
    func testAddToMaxUInt64NonCarry() {
        var (value, carry) = CarryHelper.add(UInt64.max - 1, 1)
        XCTAssertEqual(UInt64(0), carry)
        XCTAssertEqual(UInt64.max, value)
        
        (value, carry) = CarryHelper.add(1, UInt64.max - 1)
        XCTAssertEqual(UInt64(0), carry)
        XCTAssertEqual(UInt64.max, value)
    }
    
    func testMaxUInt64Carry() {
        var (value, carry) = CarryHelper.add(UInt64.max, 13)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(UInt64(12), value)
        
        (value, carry) = CarryHelper.add(13, UInt64.max)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(UInt64(12), value)
    }
    
    func test2xMaxUInt64Carry() {
        let (value, carry) = CarryHelper.add(UInt64.max, UInt64.max)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(UInt64.max-1, value)
    }
    
    func testAround2xHalfMaxUInt64() {
        // remember, UInt64.max (2^64-1) which is odd, so dividing by 2 truncates
        var (value, carry) = CarryHelper.add(UInt64.max/2+1, UInt64.max/2)
        XCTAssertEqual(UInt64(0), carry)
        XCTAssertEqual(UInt64.max, value)
        
        (value, carry) = CarryHelper.add(UInt64.max/2+1, UInt64.max/2+13)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(12, value)
        
        (value, carry) = CarryHelper.add(UInt64.max/2+13, UInt64.max/2+1)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(12, value)
    }
    
    func testAddWithCarryNoCarry() throws {
        var arr = [UInt64](repeating: 0, count: 4)
        try CarryHelper.add_with_carry(5, &arr)
        XCTAssertEqual([5, 0, 0, 0], arr)
    }
    
    func testAddWithCarrySimpleCarry() throws {
        var arr = [UInt64](repeating: 0, count: 4)
        arr[0] = UInt64.max
        try CarryHelper.add_with_carry(13, &arr)
        XCTAssertEqual([12, 1, 0, 0], arr)
    }
    
    func testAddWithCarryCascadeCarry() throws {
        var arr = [UInt64](repeating: 0, count: 4)
        arr[0] = UInt64.max
        arr[1] = UInt64.max
        try CarryHelper.add_with_carry(13, &arr)
        XCTAssertEqual([12, 0, 1, 0], arr)
    }
    
    func testAddWithCarryNoCarrySlice() throws {
        var arr = [UInt64](repeating: 0, count: 4)[0...]
        try CarryHelper.add_with_carry(5, &arr)
        XCTAssertEqual([5, 0, 0, 0], arr)
    }
    
    func testAddWithCarrySimpleCarrySlice() throws {
        var arr = [UInt64](repeating: 0, count: 4)[0...]
        arr[0] = UInt64.max
        try CarryHelper.add_with_carry(13, &arr)
        XCTAssertEqual([12, 1, 0, 0], arr)
    }
    
    func testAddWithCarryCascadeCarrySlice() throws {
        var arr = [UInt64](repeating: 0, count: 4)[0...]
        arr[0] = UInt64.max
        arr[1] = UInt64.max
        try CarryHelper.add_with_carry(13, &arr)
        XCTAssertEqual([12, 0, 1, 0], arr)
    }
    
    func testAddOverflow() throws {
        var arr = [UInt64](repeating: UInt64.max, count: 4)
        do {
            try CarryHelper.add_with_carry(1, &arr)
            XCTFail("Expected BigintError.Overflow exception")
        } catch BigintError.Overflow {
            
        }
    }

    func testSubtractNoBorrow() throws {
        
        let (value, borrow) = CarryHelper.subtract(5, 3)
        
        XCTAssertEqual(UInt64(0), borrow)
        XCTAssertEqual(UInt64(2), value)
    }
    
    func testSubtractWithBorrow() throws {
        
        let (value, borrow) = CarryHelper.subtract(3, 5)
        
        let (value2, carry) = CarryHelper.add(value, 5)
        XCTAssertEqual(UInt64(1), borrow)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(UInt64(3), value2)
    }
    
    func testSubtractWithBorrowNoBorrow() throws {
        var arr = [UInt64](repeating: 0, count: 4)
        arr[0] = 8
        try CarryHelper.subtract_with_borrow(5, &arr)
        XCTAssertEqual([3, 0, 0, 0], arr)
    }
    
    func testSubtractWithBorrowSingleBorrow() throws {
        var arr = [UInt64](repeating: 1, count: 4)
        try CarryHelper.subtract_with_borrow(2, &arr)
        XCTAssertEqual([UInt64.max, 0, 1, 1], arr)
    }
    
    func testSubtractWithBorrowCascadeBorrow() throws {
        var arr = [UInt64](repeating: 0, count: 4)
        arr[3] = 1
        try CarryHelper.subtract_with_borrow(1, &arr)
        XCTAssertEqual([UInt64.max, UInt64.max, UInt64.max, 0], arr)
    }
    
    func testSubtractUnderflow() throws {
        var arr = [UInt64](repeating: 0, count: 4)
        do {
            try CarryHelper.subtract_with_borrow(1, &arr)
            XCTFail("Expected BigintError.Underflow exception")
        } catch BigintError.Underflow {
            
        }
    }

    static var allTests = [
        ("CarryUnit add test involving no carry", testNonCarry),
        ("CarryUnit add test involving carry just past maxint", testMaxUInt64Carry),
        ("CarryUnit add tests verifies no carry right at maxint", testAddToMaxUInt64NonCarry),
        ("CarryUnit add tests verifies maxint + maxint", testAround2xHalfMaxUInt64),
        ("CarryUnit tests verifies add with carry logic with no carry", testAddWithCarryNoCarry),
        ("CarryUnit tests verifies adding with single carry", testAddWithCarrySimpleCarry),
        ("CarryUnit tests verifies adding with multiple carry", testAddWithCarryCascadeCarry),
        ("CarryUnit tests verifies add with carry logic with no carry", testAddWithCarryNoCarrySlice),
        ("CarryUnit tests verifies adding with single carry", testAddWithCarrySimpleCarrySlice),
        ("CarryUnit tests verifies adding with multiple carry", testAddWithCarryCascadeCarrySlice),
        ("CarryUnit tests verifies add overflow", testAddOverflow),
        ("CarryUnit subtract test involving no borrowing", testSubtractNoBorrow),
        ("CarryUnit subtract test involving borrowing", testSubtractWithBorrow),
        ("CarryUnit tests verifies subtracting with single borrow", testSubtractWithBorrowSingleBorrow),
        ("CarryUnit tests verifies subtracting with multiple borrows", testSubtractWithBorrowCascadeBorrow),
        ("CarryUnit tests verifies subtract underflow", testSubtractUnderflow),
   ]
}
