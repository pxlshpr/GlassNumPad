import SwiftUI

/// The visual style applied to a single numpad button.
enum ButtonKind {
    /// Standard gray fill with primary-colored label (numbers, period, #, +/−, ⌫).
    case standard
    /// Gray fill with a custom-colored label (clear button).
    case clear
    /// Gray fill with accent-colored label (operators ÷ × − +).
    case `operator`
    /// Accent fill with white label (=, prominent action).
    case prominent
    /// Dashed border outline, no fill.
    case dashed
}

/// A single button in the ``GlassNumPad`` grid.
struct NumPadButtonView<Label: View>: View {

    let kind: ButtonKind
    let accentColor: Color
    let clearColor: Color
    let cornerRadius: CGFloat
    let action: () -> Void
    let label: Label

    init(
        kind: ButtonKind,
        accentColor: Color,
        clearColor: Color,
        cornerRadius: CGFloat,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.kind = kind
        self.accentColor = accentColor
        self.clearColor = clearColor
        self.cornerRadius = cornerRadius
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Styling

    private var foregroundColor: Color {
        switch kind {
        case .standard:  return .primary
        case .clear:     return clearColor
        case .operator:  return accentColor
        case .prominent: return .white
        case .dashed:    return .secondary
        }
    }

    @ViewBuilder
    private var background: some View {
        switch kind {
        case .prominent:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(accentColor.gradient)
        case .dashed:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .foregroundStyle(.secondary.opacity(0.5))
        default:
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                )
        }
    }
}
