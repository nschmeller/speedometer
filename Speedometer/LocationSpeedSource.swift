import CoreLocation

final class LocationSpeedSource: NSObject, SpeedSource, CLLocationManagerDelegate {
    var onReading: ((SpeedReading) -> Void)?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .otherNavigation
        manager.pausesLocationUpdatesAutomatically = false
    }

    func start() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            onReading?(.denied)
        @unknown default:
            onReading?(.denied)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        start()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if location.speed >= 0, location.speedAccuracy >= 0 {
            onReading?(.speed(metersPerSecond: location.speed))
        } else {
            onReading?(.unknown)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            onReading?(.denied)
        }
    }
}
