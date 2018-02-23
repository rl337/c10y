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


    static var allTests = [
        ("test construction and == for int", testAssignmentEqualityInt),
        ("test construction and == for uint", testAssignmentEqualityUInt),
    ]
}
