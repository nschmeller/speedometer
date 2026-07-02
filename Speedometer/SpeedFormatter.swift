enum SpeedFormatter {
    static func displayValue(for reading: SpeedReading, unit: SpeedUnit) -> String {
        switch reading {
        case .speed(let metersPerSecond):
            String(Int(unit.value(fromMetersPerSecond: metersPerSecond).rounded()))
        case .unknown, .denied:
            "––"
        }
    }
}
