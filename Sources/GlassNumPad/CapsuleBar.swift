import SwiftUI

struct CapsuleBar<Label: View>: View {

    @Environment(\.colorScheme) private var colorScheme

    @Binding var isExpanded: Bool
    let accentColor: Color
    /// When false, there's only one possible unit: no chevron, dimmed, no tap.
    var isSelectable: Bool = true
    @ViewBuilder let label: () -> Label

    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }

    var body: some View {
        Button {
            guard isSelectable else { return }
            Haptic.medium()
            withAnimation(.interactiveSpring(duration: 0.35)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                label()
                    .foregroundStyle(isExpanded
                        ? accentColor
                        : fg.opacity(isSelectable ? 0.7 : 0.35))
                if isSelectable {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isExpanded ? accentColor : fg.opacity(0.4))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background {
                let fill: Color = colorScheme == .dark ? .white.opacity(0.08) : Color(.label).opacity(0.06)
                let border: Color = colorScheme == .dark ? .white.opacity(0.1) : Color(.label).opacity(0.08)
                Capsule(style: .continuous)
                    .fill(isExpanded
                        ? accentColor.opacity(0.2)
                        : fill
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(border, lineWidth: 1)
                    )
                    .opacity(isSelectable ? 1 : 0.6)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isSelectable)
    }
}
