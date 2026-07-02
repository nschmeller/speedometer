import Foundation

enum SpeedUnit: String, CaseIterable, Identifiable {
    case milesPerHour = "mph"
    case kilometersPerHour = "km/h"

    static var preferred: SpeedUnit {
        preferred(for: Locale.current.measurementSystem)
    }

    static func preferred(for measurementSystem: Locale.MeasurementSystem) -> SpeedUnit {
        measurementSystem == .metric ? .kilometersPerHour : .milesPerHour
    }

    var id: Self { self }

    var symbol: String { rawValue }

    var spokenName: String {
        switch self {
        case .milesPerHour: "miles per hour"
        case .kilometersPerHour: "kilometers per hour"
        }
    }

    func value(fromMetersPerSecond speed: Double) -> Double {
        let unit: UnitSpeed = switch self {
        case .milesPerHour: .milesPerHour
        case .kilometersPerHour: .kilometersPerHour
        }
        return Measurement(value: speed, unit: UnitSpeed.metersPerSecond)
            .converted(to: unit)
            .value
    }
}
