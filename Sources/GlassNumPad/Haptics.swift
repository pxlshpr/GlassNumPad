import UIKit

/// The buzzes the pad plays, each a moment an app can route through its own haptics.
public enum GlassNumPadHapticEvent: Sendable {
    /// A key lands under the finger: a digit, ⌫, C, an operator, the aux slot, ±.
    case key
    /// The action key (✓, or = committing in calculator mode) was tapped. Reported at the release,
    /// AFTER the action has run, so an app can play nothing when the action played a buzz of its own.
    case action
    /// The unit capsule is tapped open or closed.
    case capsule
    /// A preset chip is tapped.
    case preset
}

/// NutriKit #3972 — a hook an app sets so the pad's buzzes go through its own haptics (and honour
/// its haptics switch), as Shipyard's `ChartHooks` do. With `play` set, the pad plays nothing of
/// its own: each press is one `GlassNumPadHapticEvent`, as the finger lands (the action key's once
/// its action has run), and nothing at the release. Left `nil`, the pad plays what it always has (a rigid tap as a key lands and a soft
/// one at a held key's release, a medium on the capsule, a light on a preset).
@MainActor
public enum GlassNumPadHooks {
    public static var play: ((GlassNumPadHapticEvent) -> Void)?
}

enum Haptic {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// The pad's own buzz for `event`, or the app's (`GlassNumPadHooks.play`) when it set one.
    @MainActor
    static func play(_ event: GlassNumPadHapticEvent, fallback: () -> Void) {
        if let hook = GlassNumPadHooks.play { hook(event) } else { fallback() }
    }
}
