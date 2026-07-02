import Foundation

enum SpeedUnit: String, CaseIterable, Identifiable {
    case milesPerHour = "mph"
    case kilometersPerHour = "km/h"

    var id: String { rawValue }

    var symbol: String { rawValue }

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
