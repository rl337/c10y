import XCTest
@testable import Bigint

class BigintTests: XCTestCase {
    func testAssignmentEqualityInt() throws {
        let a = try UnsignedBigint(Int(5))
        let b = try UnsignedBigint(Int(3))

        XCTAssertFalse(a == b, "5 should not be equal to 3")
        XCTAssertTrue(a == a, "a value should be equal to itself")
        XCTAssertTrue(try a == 5, "a value should be equal to 5")
        XCTAssertTrue(try 5 == a, "a value should be equal to 5 (rhs)")
    }

    func testAssignmentEqualityUInt() {
        let a = UnsignedBigint(UInt(5))
        let b = UnsignedBigint(UInt(3))

        XCTAssertFalse(a == b, "5 should not be equal to 3")
        XCTAssertTrue(a == a, "a value should be equal to itself")
        XCTAssertTrue(try a == 5, "a value should be equal to 5")
        XCTAssertTrue(try 5 == a, "a value should be equal to 5 (rhs)")
    }
    
    func testLessThan() throws {
        let a = UnsignedBigint(UInt(5))
        let b = UnsignedBigint(UInt(3))
        let e = UnsignedBigint(UInt(8))
        
        let c = try a + b
        
        XCTAssertTrue(a < e, "5 should be less than 8")
        XCTAssertTrue(b < a, "3 should be less than 5")
        XCTAssertFalse(e < c, "8 should NOT be less than 8")
    }
    
    func testSimpleAdd() throws {
        let a = UnsignedBigint(UInt(5))
        let b = UnsignedBigint(UInt(3))
        let e = UnsignedBigint(UInt(8))
        
        let c = try a + b
        
        XCTAssertTrue(c == e, "5+3 should be 8")
    }
    
    func testAddWithSingleCarry() throws {
        let a = UnsignedBigint(UInt.max)
        let b = UnsignedBigint(UInt(3))
        
        let e = UnsignedBigint([UInt64]([2, 1, 0, 0]), negative: false)
        
        let c = try a + b

        XCTAssertTrue(c == e, "maxint + 3 should be [2, 1, 0, 0]")
    }
    
    func testAddWithMultipleCarry() throws {
        let a = UnsignedBigint([UInt64]([UInt64.max, UInt64.max, UInt64.max, 0]), negative: false)
        let b = UnsignedBigint(UInt(3))
        
        let e = UnsignedBigint([UInt64]([2, 0, 0, 1]), negative: false)
        
        let c = try a + b

        XCTAssertTrue(c == e, "maxint + 3 should be [2, 1, 0, 0]")
    }
    
    func testSimpleSubtract() throws {
        let a = UnsignedBigint(UInt(5))
        let b = UnsignedBigint(UInt(3))
        let e = UnsignedBigint(UInt(2))
        
        let c = try a - b
        
        XCTAssertTrue(c == e, "5-3 should be 2")
    }
    
    func testSubtractWithMultipleBorrow() throws {
        let a = UnsignedBigint([UInt64]([0, 0, 1, 0]), negative: false)
        let b = UnsignedBigint(UInt(1))
        
        let e = UnsignedBigint([UInt64]([UInt64.max, UInt64.max, 0, 0]), negative: false)
        
        let c = try a - b
        
        XCTAssertTrue(c == e, "cascading borrow should result in [UInt64.max, UInt64.max, 0, 0]")
    }
    
    
    func testMultiply() throws {
        XCTAssertEqual(try UnsignedBigint(0) * UnsignedBigint(50), try UnsignedBigint(0))
        XCTAssertEqual(try UnsignedBigint(1) * UnsignedBigint(1), try UnsignedBigint(1))
        XCTAssertEqual(try UnsignedBigint(10) * UnsignedBigint(10), try UnsignedBigint(100))
    }
    
    func testDivide() throws {
        XCTAssertEqual(try UnsignedBigint(1) / UnsignedBigint(50), try UnsignedBigint(0))
        XCTAssertEqual(try UnsignedBigint(1) / UnsignedBigint(1), try UnsignedBigint(1))
        XCTAssertEqual(try UnsignedBigint(100) / UnsignedBigint(10), try UnsignedBigint(10))
    }
    
    static var allTests = [
        ("test construction and == for int", testAssignmentEqualityInt),
        ("test construction and == for uint", testAssignmentEqualityUInt),
        ("test less than operator", testLessThan),
        ("test add without carry", testSimpleAdd),
        ("test add with one carry", testAddWithSingleCarry),
        ("test add with multiple carry", testAddWithMultipleCarry),
        ("test subtract without borrow", testSimpleSubtract),
        ("test subtract with cascading borrow", testSubtractWithMultipleBorrow),
        ("test multiply", testMultiply),
        ("test divide", testDivide),

    ]
}
