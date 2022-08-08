import XCTest
@testable import CircUp

final class CircUpTests: XCTestCase {
    func testInit() throws
    {
        let cli = CircUp()
        XCTAssertNotNil(cli)
    }
}
