import SwiftUI

/// The large number readout at the top of the numpad.
struct NumberDisplay: View {

    @Environment(\.colorScheme) private var colorScheme

    let text: String
    let isCalculatorMode: Bool
    /// Muted unit text beside the number (`Configuration.displaySuffix`).
    var suffix: String? = nil

    @State private var hasAppeared = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(text)
                .font(.system(
                    size: isCalculatorMode ? 48 : 64,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(colorScheme == .dark ? .white : Color(.label))
            if let suffix, !isCalculatorMode {
                Text(suffix)
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }
        }
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
            .contentTransition(.numericText())
            .animation(hasAppeared ? .interactiveSpring(duration: 0.3) : .none, value: text)
            .onAppear {
                GlassNumPadDebug.event("numberDisplay.onAppear")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    hasAppeared = true
                }
            }
    }
}
