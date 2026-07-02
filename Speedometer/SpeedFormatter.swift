enum SpeedFormatter {
    static func displayValue(for reading: SpeedReading, unit: SpeedUnit) -> String {
        switch reading {
        case .speed(let metersPerSecond):
            String(Int(unit.value(fromMetersPerSecond: metersPerSecond).rounded()))
        case .unknown, .denied:
            "––"
        }
    }

    static func accessibilityLabel(for reading: SpeedReading, unit: SpeedUnit) -> String {
        switch reading {
        case .speed:
            "\(displayValue(for: reading, unit: unit)) \(unit.spokenName)"
        case .unknown:
            "Speed unavailable"
        case .denied:
            "Location access denied"
        }
    }
}
