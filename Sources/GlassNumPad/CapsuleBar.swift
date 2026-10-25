import SwiftUI

struct CapsuleBar<Label: View>: View {

    @Environment(\.colorScheme) private var colorScheme
    /// NutriKit #3725 — a unit the caller wants checked wears its border in this colour.
    @Environment(\.glassNumPadCapsuleHighlight) private var highlight

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

    @ViewBuilder
    private var chip: some View {
        if isSelectable {
            GlassNumPadChip(isActive: isExpanded, accentColor: accentColor, label: label)
        } else {
            label()
                .foregroundStyle(fg.opacity(0.45))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background { staticBackground }
        }
    }

    // The digit keys are fill + border; a static unit drops the border and halves the fill, so
    // it reads as a label on the readout rather than a key of its own. Keeps the same padding
    // so the header height is unchanged.
    private var staticBackground: some View {
        Capsule(style: .continuous)
            .fillOnKeyBacking(colorScheme == .dark ? .white.opacity(0.04) : Color(.label).opacity(0.03), colorScheme)
            .overlay {
                if let highlight {
                    Capsule(style: .continuous)
                        .strokeBorder(highlight, lineWidth: 2)
                }
            }
    }
}
