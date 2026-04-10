import SwiftUI

/// The large number readout at the top of the numpad.
struct NumberDisplay: View {

    let text: String
    let isCalculatorMode: Bool

    var body: some View {
        Text(text)
            .font(.system(
                size: isCalculatorMode ? 48 : 64,
                weight: .bold,
                design: .rounded
            ))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
            .contentTransition(.numericText())
            .animation(.interactiveSpring(duration: 0.3), value: text)
    }
}
