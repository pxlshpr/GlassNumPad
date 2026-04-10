import SwiftUI

/// The large number readout at the top of the numpad.
struct NumberDisplay: View {

    let text: String
    let isCalculatorMode: Bool

    var body: some View {
        Text(text)
            .font(.system(
                size: isCalculatorMode ? 48 : 56,
                weight: .semibold,
                design: .rounded
            ))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 8)
            .contentTransition(.numericText())
            .animation(.interactiveSpring(duration: 0.3), value: text)
    }
}
