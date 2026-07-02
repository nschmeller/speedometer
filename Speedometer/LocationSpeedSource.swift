import CoreLocation

extension SpeedReading {
    static let maximumLocationAge: TimeInterval = 10
    static let maximumSpeedAccuracy: CLLocationSpeedAccuracy = 5

    init(location: CLLocation, now: Date = Date()) {
        let age = now.timeIntervalSince(location.timestamp)
        if age <= Self.maximumLocationAge,
           location.speed >= 0,
           (0...Self.maximumSpeedAccuracy).contains(location.speedAccuracy) {
            self = .speed(metersPerSecond: location.speed)
        } else {
            self = .unknown
        }
    }
}

@MainActor
final class LocationSpeedSource: NSObject, SpeedSource {
    var onReading: ((SpeedReading) -> Void)?

    private let manager: CLLocationManager
    private var isStarted = false
    private var isUpdating = false
    private var stalenessTimer: Timer?

    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
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
            beginUpdates()
        case .denied, .restricted:
            endUpdates()
        @unknown default:
            endUpdates()
        }
    }

    private func beginUpdates() {
        guard !isUpdating else { return }
        isUpdating = true
        emit(.unknown)
        manager.startUpdatingLocation()
    }

    private func endUpdates() {
        isUpdating = false
        manager.stopUpdatingLocation()
        emit(.denied)
    }

    private func handle(_ location: CLLocation) {
        let reading = SpeedReading(location: location)
        emit(reading, expiry: SpeedReading.maximumLocationAge + location.timestamp.timeIntervalSinceNow)
    }

    private func emit(_ reading: SpeedReading, expiry: TimeInterval = SpeedReading.maximumLocationAge) {
        stalenessTimer?.invalidate()
        if case .speed = reading {
            let timer = Timer(timeInterval: max(expiry, 0), repeats: false) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.emit(.unknown)
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            stalenessTimer = timer
        }
        onReading?(reading)
    }
}

extension LocationSpeedSource: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        onMain { $0.apply(status) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onMain { $0.handle(location) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard (error as? CLError)?.code == .denied else { return }
        onMain { $0.endUpdates() }
    }

    private nonisolated func onMain(_ work: @escaping @MainActor (LocationSpeedSource) -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated { work(self) }
        } else {
            DispatchQueue.main.async { work(self) }
        }
    }
}
