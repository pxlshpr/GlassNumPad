import SwiftUI

struct CapsuleBar<Label: View>: View {

    @Environment(\.colorScheme) private var colorScheme

    @Binding var isExpanded: Bool
    let accentColor: Color
    @ViewBuilder let label: () -> Label

    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }

    var body: some View {
        Button {
            Haptic.medium()
            withAnimation(.interactiveSpring(duration: 0.35)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                label()
                    .foregroundStyle(isExpanded ? accentColor : fg.opacity(0.7))
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isExpanded ? accentColor : fg.opacity(0.4))
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
            }
        }
        .buttonStyle(.plain)
    }
}
