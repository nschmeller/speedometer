import XCTest
@testable import Speedometer

final class SpeedometerModelTests: XCTestCase {
    private final class FakeSpeedSource: SpeedSource {
        var onReading: ((SpeedReading) -> Void)?
        private(set) var started = false

        func start() {
            started = true
        }
    }

    func testInitialReadingIsUnknown() {
        XCTAssertEqual(SpeedometerModel(source: FakeSpeedSource()).reading, .unknown)
    }

    func testStartStartsTheSource() {
        let source = FakeSpeedSource()
        let model = SpeedometerModel(source: source)
        model.start()
        XCTAssertTrue(source.started)
    }

    func testReadingsFromTheSourceArePublished() {
        let source = FakeSpeedSource()
        let model = SpeedometerModel(source: source)
        source.onReading?(.speed(metersPerSecond: 5))
        XCTAssertEqual(model.reading, .speed(metersPerSecond: 5))
        source.onReading?(.denied)
        XCTAssertEqual(model.reading, .denied)
    }
}
