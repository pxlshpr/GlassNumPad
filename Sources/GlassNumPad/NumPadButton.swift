import SwiftUI

enum ButtonKind {
    case standard, clear, `operator`, prominent, dashed
}

struct NumPadButtonView<Label: View>: View {

    @Environment(\.colorScheme) private var colorScheme

    let kind: ButtonKind
    let accentColor: Color
    let clearColor: Color
    let cornerRadius: CGFloat
    let action: () -> Void
    let label: Label

    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }
    private var btnFill: Color { colorScheme == .dark ? .white.opacity(0.08) : Color(.label).opacity(0.06) }
    private var btnBorder: Color { colorScheme == .dark ? .white.opacity(0.1) : Color(.label).opacity(0.08) }

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
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
        }
        .buttonStyle(NumPadPressStyle())
    }

    private var foregroundColor: Color {
        switch kind {
        case .standard:  return fg
        case .clear:     return clearColor
        case .operator:  return accentColor
        case .prominent: return .white
        case .dashed:    return fg.opacity(0.4)
        }
    }

    @ViewBuilder
    private var background: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        switch kind {
        case .prominent:
            shape.fill(accentColor.gradient)
                .overlay(
                    shape.strokeBorder(fg.opacity(0.12), lineWidth: 1)
                )
        case .dashed:
            shape
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                .foregroundStyle(fg.opacity(0.2))
        default:
            shape
                .fill(btnFill)
                .overlay(
                    shape.strokeBorder(btnBorder, lineWidth: 1)
                )
        }
    }
}

struct NumPadPressStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        NumPadPressBody(configuration: configuration)
    }

    private struct NumPadPressBody: View {
        let configuration: PrimitiveButtonStyleConfiguration
        @State private var isPressed: Bool = false
        @State private var pressedAt: Date? = nil

        // Releases within this window of press-down feel like a single
        // haptic when both fire, so we skip the release haptic.
        private static let minHapticGap: TimeInterval = 0.15

        var body: some View {
            configuration.label
                .opacity(isPressed ? 0.5 : 1)
                .scaleEffect(isPressed ? 0.96 : 1)
                .animation(.easeOut(duration: 0.12), value: isPressed)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                                pressedAt = Date()
                                Haptic.rigid()
                            }
                        }
                        .onEnded { _ in
                            guard isPressed else { return }
                            isPressed = false
                            let elapsed = pressedAt.map { Date().timeIntervalSince($0) } ?? .infinity
                            pressedAt = nil
                            if elapsed >= Self.minHapticGap {
                                Haptic.soft()
                            }
                            configuration.trigger()
                        }
                )
        }
    }
}
