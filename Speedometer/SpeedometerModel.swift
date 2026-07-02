import Foundation

final class SpeedometerModel: ObservableObject {
    @Published private(set) var reading: SpeedReading = .unknown

    private let source: SpeedSource

    init(source: SpeedSource) {
        self.source = source
        source.onReading = { [weak self] reading in
            self?.reading = reading
        }
    }

    func start() {
        source.start()
    }
}
