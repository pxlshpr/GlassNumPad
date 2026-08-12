import SwiftUI

struct CapsuleBar<Label: View>: View {

    @Environment(\.colorScheme) private var colorScheme

    @Binding var isExpanded: Bool
    let accentColor: Color
    /// When false, there's only one possible unit: no chevron, no tap, and a flat
    /// annotation style so the capsule doesn't read as a pressable key.
    var isSelectable: Bool = true
    @ViewBuilder let label: () -> Label

    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }

    var body: some View {
        if isSelectable {
            Button {
                Haptic.medium()
                withAnimation(.interactiveSpring(duration: 0.35)) {
                    isExpanded.toggle()
                }
            } label: {
                chip
            }
            .buttonStyle(.plain)
        } else {
            // Not a Button at all — nothing to activate, and VoiceOver shouldn't
            // announce a control the user can't act on.
            chip
        }
    }

    private var chip: some View {
        HStack(spacing: 8) {
            label()
                .foregroundStyle(labelColor)
            if isSelectable {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isExpanded ? accentColor : fg.opacity(0.4))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background { chipBackground }
    }

    private var labelColor: Color {
        guard isSelectable else { return fg.opacity(0.45) }
        return isExpanded ? accentColor : fg.opacity(0.7)
    }

    @ViewBuilder
    private var chipBackground: some View {
        let fill: Color = colorScheme == .dark ? .white.opacity(0.08) : Color(.label).opacity(0.06)
        let border: Color = colorScheme == .dark ? .white.opacity(0.1) : Color(.label).opacity(0.08)
        if isSelectable {
            Capsule(style: .continuous)
                .fill(isExpanded ? accentColor.opacity(0.2) : fill)
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(border, lineWidth: 1)
                )
        } else {
            // The digit keys are fill + border; a static unit drops the border and
            // halves the fill, so it reads as a label on the readout rather than a
            // key of its own. Keeps the same padding so the header height is unchanged.
            Capsule(style: .continuous)
                .fill(colorScheme == .dark ? .white.opacity(0.04) : Color(.label).opacity(0.03))
        }
    }
}
