enum SpeedFormatter {
    static func displayValue(for reading: SpeedReading, unit: SpeedUnit) -> String {
        switch reading {
        case .speed(let metersPerSecond):
            String(Int(unit.value(fromMetersPerSecond: metersPerSecond).rounded()))
        case .unknown, .denied:
            "––"
        }
    }

    static func statusText(for reading: SpeedReading) -> String? {
        switch reading {
        case .speed:
            nil
        case .unknown:
            "Waiting for a GPS signal."
        case .denied:
            "Speedometer needs location access. You can allow it in Settings."
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
