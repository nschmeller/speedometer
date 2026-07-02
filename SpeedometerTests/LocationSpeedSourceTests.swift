import CoreLocation
import XCTest
@testable import Speedometer

@MainActor
final class LocationSpeedSourceTests: XCTestCase {
    private final class ManagerSpy: CLLocationManager {
        var status: CLAuthorizationStatus = .notDetermined
        private(set) var didRequestAuthorization = false
        private(set) var isUpdatingLocation = false

        override var authorizationStatus: CLAuthorizationStatus { status }

        override func requestWhenInUseAuthorization() {
            didRequestAuthorization = true
        }

        override func startUpdatingLocation() {
            isUpdatingLocation = true
        }

        override func stopUpdatingLocation() {
            isUpdatingLocation = false
        }
    }

    private var manager = ManagerSpy()
    private var source: LocationSpeedSource!
    private var readings: [SpeedReading] = []

    override func setUp() {
        super.setUp()
        manager = ManagerSpy()
        source = LocationSpeedSource(manager: manager)
        readings = []
        source.onReading = { [self] reading in readings.append(reading) }
    }

    func testAuthorizationCallbackBeforeStartDoesNothing() {
        source.locationManagerDidChangeAuthorization(manager)
        XCTAssertFalse(manager.didRequestAuthorization)
        XCTAssertFalse(manager.isUpdatingLocation)
        XCTAssertEqual(readings, [])
    }

    func testStartRequestsAuthorizationWhenNotDetermined() {
        source.start()
        XCTAssertTrue(manager.didRequestAuthorization)
        XCTAssertFalse(manager.isUpdatingLocation)
    }

    func testStartBeginsUpdatesWhenAuthorized() {
        manager.status = .authorizedWhenInUse
        source.start()
        XCTAssertTrue(manager.isUpdatingLocation)
        XCTAssertEqual(readings, [.unknown])
    }

    func testStartEmitsDeniedWhenDenied() {
        manager.status = .denied
        source.start()
        XCTAssertFalse(manager.isUpdatingLocation)
        XCTAssertEqual(readings, [.denied])
    }

    func testGrantingAuthorizationAfterPromptBeginsUpdates() {
        source.start()
        manager.status = .authorizedWhenInUse
        source.locationManagerDidChangeAuthorization(manager)
        XCTAssertTrue(manager.isUpdatingLocation)
        XCTAssertEqual(readings, [.unknown])
    }

    func testRepeatedAuthorizedCallbacksDoNotBlankLiveReading() {
        manager.status = .authorizedWhenInUse
        source.start()
        source.locationManager(manager, didUpdateLocations: [location(speed: 5)])
        source.locationManagerDidChangeAuthorization(manager)
        XCTAssertEqual(readings, [.unknown, .speed(metersPerSecond: 5)])
    }

    func testRevokedAuthorizationStopsUpdatesAndEmitsDenied() {
        manager.status = .authorizedWhenInUse
        source.start()
        manager.status = .denied
        source.locationManagerDidChangeAuthorization(manager)
        XCTAssertFalse(manager.isUpdatingLocation)
        XCTAssertEqual(readings, [.unknown, .denied])
    }

    func testDeniedErrorStopsUpdatesAndEmitsDenied() {
        manager.status = .authorizedWhenInUse
        source.start()
        source.locationManager(manager, didFailWithError: CLError(.denied))
        XCTAssertFalse(manager.isUpdatingLocation)
        XCTAssertEqual(readings, [.unknown, .denied])
    }

    func testTransientErrorsAreIgnored() {
        manager.status = .authorizedWhenInUse
        source.start()
        source.locationManager(manager, didUpdateLocations: [location(speed: 5)])
        source.locationManager(manager, didFailWithError: CLError(.locationUnknown))
        source.locationManager(manager, didFailWithError: CLError(.network))
        XCTAssertEqual(readings, [.unknown, .speed(metersPerSecond: 5)])
    }

    func testInvalidLocationEmitsUnknown() {
        manager.status = .authorizedWhenInUse
        source.start()
        source.locationManager(manager, didUpdateLocations: [location(speed: -1)])
        XCTAssertEqual(readings, [.unknown, .unknown])
    }

    private func location(speed: Double) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            course: 0,
            courseAccuracy: 0,
            speed: speed,
            speedAccuracy: 1,
            timestamp: Date()
        )
    }
}
