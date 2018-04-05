import XCTest
@testable import Bigint

class BigintTests: XCTestCase {
    func testAssignmentEqualityInt() {
        let a = Bigint(Int(5))
        let b = Bigint(Int(-3))

        XCTAssertFalse(a == b, "5 should not be equal to -3")
        XCTAssertTrue(a == a, "a value should be equal to itself")
        XCTAssertTrue(a == 5, "a value should be equal to 5")
        XCTAssertTrue(5 == a, "a value should be equal to 5 (rhs)")
    }

    func testAssignmentEqualityUInt() {
        let a = Bigint(UInt(5))
        let b = Bigint(UInt(3))

        XCTAssertFalse(a == b, "5 should not be equal to 3")
        XCTAssertTrue(a == a, "a value should be equal to itself")
        XCTAssertTrue(a == 5, "a value should be equal to 5")
        XCTAssertTrue(5 == a, "a value should be equal to 5 (rhs)")
    }
    
    func testLessThan() throws {
        let a = Bigint(UInt(5))
        let b = Bigint(UInt(3))
        let x = Bigint(-5)
        let y = Bigint(-3)
        let e = Bigint(UInt(8))
        
        let c = try a + b
        
        XCTAssertTrue(try a < e, "5 should be less than 8")
        XCTAssertTrue(try b < a, "3 should be less than 5")
        XCTAssertFalse(try e < c, "8 should NOT be less than 8")
        XCTAssertTrue(try x < b, "-5 should be less than 3")
        XCTAssertTrue(try y < Bigint(0), "-3 should be less than 0")
        XCTAssertTrue(try x < y, "-5 should be less than -3")

    }
    
    func testSimpleAdd() throws {
        let a = Bigint(UInt(5))
        let b = Bigint(UInt(3))
        let e = Bigint(UInt(8))
        
        let c = try a + b
        
        XCTAssertTrue(c == e, "5+3 should be 8")
    }
    
    func testAddWithSingleCarry() throws {
        let a = Bigint(UInt.max)
        let b = Bigint(UInt(3))
        
        let e = Bigint([UInt64]([2, 1, 0, 0]), negative: false)
        
        let c = try a + b

        XCTAssertTrue(c == e, "maxint + 3 should be [2, 1, 0, 0]")
    }
    
    func testAddWithMultipleCarry() throws {
        let a = Bigint([UInt64]([UInt64.max, UInt64.max, UInt64.max, 0]), negative: false)
        let b = Bigint(UInt(3))
        
        let e = Bigint([UInt64]([2, 0, 0, 1]), negative: false)
        
        let c = try a + b

        XCTAssertTrue(c == e, "maxint + 3 should be [2, 1, 0, 0]")
    }
    
    func testSimpleSubtract() throws {
        let a = Bigint(UInt(5))
        let b = Bigint(UInt(3))
        let e = Bigint(UInt(2))
        
        let c = try a - b
        
        XCTAssertTrue(c == e, "5-3 should be 2")
    }
    
    static var allTests = [
        ("test construction and == for int", testAssignmentEqualityInt),
        ("test construction and == for uint", testAssignmentEqualityUInt),
        ("test less than operator", testLessThan),
        ("test add without carry", testSimpleAdd),
        ("test add with one carry", testAddWithSingleCarry),
        ("test add with multiple carry", testAddWithMultipleCarry),
        ("test subtract without carry", testSimpleSubtract),
        
    ]
}
