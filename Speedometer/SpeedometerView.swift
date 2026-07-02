import SwiftUI

struct SpeedometerView: View {
    @StateObject private var model = SpeedometerModel(source: LocationSpeedSource())
    @AppStorage("unit") private var unit = SpeedUnit.preferred
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(SpeedFormatter.displayValue(for: model.reading, unit: unit))
                .font(.system(size: 128, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityLabel(SpeedFormatter.accessibilityLabel(for: model.reading, unit: unit))
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
        .onAppear(perform: model.start)
        .onChange(of: scenePhase, initial: true) { _, phase in
            UIApplication.shared.isIdleTimerDisabled = phase != .background
        }
    }
}

#Preview {
    SpeedometerView()
}
