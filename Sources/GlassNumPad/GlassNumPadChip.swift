import SwiftUI

/// A capsule dressed as the pad's unit capsule, for a control of the caller's own that stands
/// in the pad's `header:` (NutriKit #3853: a weigh-in's date and time), so it reads as part of
/// the pad rather than a system control dropped on it. `CapsuleBar` draws its selectable unit
/// with it, so the two can't drift apart.
public struct GlassNumPadChip<Label: View>: View {

    @Environment(\.colorScheme) private var colorScheme
    /// NutriKit #3725 — a unit the caller wants checked wears its border in this colour.
    @Environment(\.glassNumPadCapsuleHighlight) private var highlight

    let isActive: Bool
    let accentColor: Color
    let label: Label

    /// - Parameters:
    ///   - isActive: what it opens is showing (the unit list, a picker): label, chevron and
    ///     fill in the accent, as the unit capsule does while expanded.
    public init(isActive: Bool, accentColor: Color, @ViewBuilder label: () -> Label) {
        self.isActive = isActive
        self.accentColor = accentColor
        self.label = label()
    }

    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }

    public var body: some View {
        HStack(spacing: 8) {
            label
                .foregroundStyle(isActive ? accentColor : fg.opacity(0.7))
            // One chevron turned, never swapped for another: it rotates as it opens and back
            // as it closes.
            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isActive ? accentColor : fg.opacity(0.4))
                .rotationEffect(.degrees(isActive ? 180 : 0))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background {
            let fill: Color = colorScheme == .dark ? .white.opacity(0.08) : Color(.label).opacity(0.06)
            let border: Color = colorScheme == .dark ? .white.opacity(0.1) : Color(.label).opacity(0.08)
            Capsule(style: .continuous)
                .fillOnKeyBacking(isActive ? accentColor.opacity(0.2) : fill, colorScheme)
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(highlight ?? border, lineWidth: highlight == nil ? 1 : 2)
                )
        }
        // The chip animates its own change, both ways: what closes it (a popover dismissed by
        // a tap outside) sets its state with no animation of its own, and the chip snapped back.
        .animation(.interactiveSpring(duration: 0.35), value: isActive)
    }
}
