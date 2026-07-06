import CoreLocation
import XCTest
@testable import Speedometer

final class SpeedReadingTests: XCTestCase {
    func testRecentValidLocationYieldsItsSpeed() {
        XCTAssertEqual(
            SpeedReading(location: location(speed: 5, speedAccuracy: 1), now: Date()),
            .speed(metersPerSecond: 5)
        )
    }

    func testNegativeSpeedIsUnknown() {
        XCTAssertEqual(
            SpeedReading(location: location(speed: -1, speedAccuracy: 1), now: Date()),
            .unknown
        )
    }

    func testInvalidSpeedAccuracyIsUnknown() {
        XCTAssertEqual(
            SpeedReading(location: location(speed: 5, speedAccuracy: -1), now: Date()),
            .unknown
        )
    }

    func testPoorSpeedAccuracyIsUnknown() {
        let imprecise = location(speed: 5, speedAccuracy: SpeedReading.maximumSpeedAccuracy + 1)
        XCTAssertEqual(SpeedReading(location: imprecise, now: Date()), .unknown)
    }

    func testStaleLocationIsUnknown() {
        let stale = location(speed: 5, speedAccuracy: 1, age: SpeedReading.maximumLocationAge + 1)
        XCTAssertEqual(SpeedReading(location: stale, now: Date()), .unknown)
    }

    private func location(speed: Double, speedAccuracy: Double, age: TimeInterval = 0) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            course: 0,
            courseAccuracy: 0,
            speed: speed,
            speedAccuracy: speedAccuracy,
            timestamp: Date(timeIntervalSinceNow: -age)
        )
    }
}
