import CoreLocation

extension SpeedReading {
    static let maximumLocationAge: TimeInterval = 10

    init(location: CLLocation, now: Date = Date()) {
        let age = now.timeIntervalSince(location.timestamp)
        if age <= Self.maximumLocationAge, location.speed >= 0, location.speedAccuracy >= 0 {
            self = .speed(metersPerSecond: location.speed)
        } else {
            self = .unknown
        }
    }
}

@MainActor
final class LocationSpeedSource: NSObject, SpeedSource {
    var onReading: ((SpeedReading) -> Void)?

    private let manager = CLLocationManager()
    private var isStarted = false
    private var stalenessTimer: Timer?

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .otherNavigation
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
    }

    func start() {
        isStarted = true
        apply(manager.authorizationStatus)
    }

    private func apply(_ status: CLAuthorizationStatus) {
        guard isStarted else { return }
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            emit(.unknown)
            manager.startUpdatingLocation()
        case .denied, .restricted:
            emit(.denied)
        @unknown default:
            emit(.denied)
        }
    }

    private func emit(_ reading: SpeedReading) {
        stalenessTimer?.invalidate()
        if case .speed = reading {
            stalenessTimer = Timer.scheduledTimer(
                withTimeInterval: SpeedReading.maximumLocationAge,
                repeats: false
            ) { [weak self] _ in
                self?.emit(.unknown)
            }
        }
        onReading?(reading)
    }
}

extension LocationSpeedSource: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.apply(status)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.emit(SpeedReading(location: location))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let reading: SpeedReading = (error as? CLError)?.code == .denied ? .denied : .unknown
        DispatchQueue.main.async {
            self.emit(reading)
        }
    }
}
