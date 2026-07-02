import XCTest
@testable import Speedometer

final class SpeedUnitTests: XCTestCase {
    func testZeroIsZeroInAllUnits() {
        for unit in SpeedUnit.allCases {
            XCTAssertEqual(unit.value(fromMetersPerSecond: 0), 0, accuracy: 0.001)
        }
    }

    func testMetersPerSecondToMilesPerHour() {
        XCTAssertEqual(
            SpeedUnit.milesPerHour.value(fromMetersPerSecond: 22.352),
            50,
            accuracy: 0.001
        )
    }

    func testMetersPerSecondToKilometersPerHour() {
        XCTAssertEqual(
            SpeedUnit.kilometersPerHour.value(fromMetersPerSecond: 10),
            36,
            accuracy: 0.001
        )
    }
}
