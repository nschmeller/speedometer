import SwiftUI

struct SpeedometerView: View {
    @StateObject private var model: SpeedometerModel
    @AppStorage("unit") private var unit: SpeedUnit = .milesPerHour

    init(model: @autoclosure @escaping () -> SpeedometerModel) {
        _model = StateObject(wrappedValue: model())
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(SpeedFormatter.displayValue(for: model.reading, unit: unit))
                .font(.system(size: 128, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityLabel(accessibilityLabel)
            Picker("Unit", selection: $unit) {
                ForEach(SpeedUnit.allCases) { unit in
                    Text(unit.symbol).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 240)
            Spacer()
            if model.reading == .denied {
                Text("Allow location access in Settings to see your speed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .animation(.default, value: model.reading)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            model.start()
        }
    }

    private var accessibilityLabel: String {
        switch model.reading {
        case .speed:
            "\(SpeedFormatter.displayValue(for: model.reading, unit: unit)) \(unit.symbol)"
        case .unknown:
            "Speed unavailable"
        case .denied:
            "Location access denied"
        }
    }
}

#Preview {
    SpeedometerView(model: SpeedometerModel(source: LocationSpeedSource()))
}
