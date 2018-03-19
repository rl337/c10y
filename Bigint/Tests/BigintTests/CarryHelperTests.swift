
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
        XCTAssertEqual(UInt64(13), value)
        
        (value, carry) = CarryHelper.add(13, UInt64.max)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(UInt64(13), value)
    }
    
    func test2xMaxUInt64Carry() {
        let (value, carry) = CarryHelper.add(UInt64.max, UInt64.max)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(UInt64.max, value)
    }
    
    func testAround2xHalfMaxUInt64() {
        // remember, UInt64.max (2^64-1) which is odd, so dividing by 2 truncates
        var (value, carry) = CarryHelper.add(UInt64.max/2+1, UInt64.max/2)
        XCTAssertEqual(UInt64(0), carry)
        XCTAssertEqual(UInt64.max, value)
        
        (value, carry) = CarryHelper.add(UInt64.max/2+1, UInt64.max/2+13)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(13, value)
        
        (value, carry) = CarryHelper.add(UInt64.max/2+13, UInt64.max/2+1)
        XCTAssertEqual(UInt64(1), carry)
        XCTAssertEqual(13, value)
    }


    static var allTests = [
        ("CarryUnit test involving no carry", testNonCarry),
        ("CarryUnit test involving carry just past maxint", testMaxUInt64Carry),
        ("CarryUnit tests verifies no carry right at maxint", testAddToMaxUInt64NonCarry),
        ("CarryUnit tests verifies maxint + maxint", testAround2xHalfMaxUInt64),
   ]
}
