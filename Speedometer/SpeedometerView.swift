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
                    Text(unit.symbol)
                        .accessibilityLabel(unit.spokenName)
                        .tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 240)
            Spacer()
            if let status = SpeedFormatter.statusText(for: model.reading) {
                Text(status)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .animation(.default, value: model.reading)
        .onAppear(perform: model.start)
        .onChange(of: keepsScreenAwake, initial: true) { _, keepAwake in
            UIApplication.shared.isIdleTimerDisabled = keepAwake
        }
    }

    private var keepsScreenAwake: Bool {
        scenePhase != .background && model.reading != .denied
    }
}

#Preview {
    SpeedometerView()
}
