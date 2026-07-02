import XCTest
@testable import Speedometer

final class SpeedFormatterTests: XCTestCase {
    func testSpeedIsRoundedToNearestWholeNumber() {
        XCTAssertEqual(
            SpeedFormatter.displayValue(for: .speed(metersPerSecond: 10), unit: .kilometersPerHour),
            "36"
        )
        XCTAssertEqual(
            SpeedFormatter.displayValue(for: .speed(metersPerSecond: 10), unit: .milesPerHour),
            "22"
        )
    }

    func testZeroSpeedDisplaysAsZero() {
        for unit in SpeedUnit.allCases {
            XCTAssertEqual(SpeedFormatter.displayValue(for: .speed(metersPerSecond: 0), unit: unit), "0")
        }
    }

    func testUnknownReadingDisplaysAsPlaceholder() {
        XCTAssertEqual(SpeedFormatter.displayValue(for: .unknown, unit: .milesPerHour), "––")
    }

    func testDeniedReadingDisplaysAsPlaceholder() {
        XCTAssertEqual(SpeedFormatter.displayValue(for: .denied, unit: .kilometersPerHour), "––")
    }
}
