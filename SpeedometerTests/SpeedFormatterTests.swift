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

    func testAccessibilityLabelSpeaksValueAndUnit() {
        XCTAssertEqual(
            SpeedFormatter.accessibilityLabel(for: .speed(metersPerSecond: 10), unit: .kilometersPerHour),
            "36 kilometers per hour"
        )
        XCTAssertEqual(
            SpeedFormatter.accessibilityLabel(for: .speed(metersPerSecond: 10), unit: .milesPerHour),
            "22 miles per hour"
        )
    }

    func testAccessibilityLabelDescribesUnavailableStates() {
        XCTAssertEqual(SpeedFormatter.accessibilityLabel(for: .unknown, unit: .milesPerHour), "Speed unavailable")
        XCTAssertEqual(SpeedFormatter.accessibilityLabel(for: .denied, unit: .kilometersPerHour), "Location access denied")
    }
}
