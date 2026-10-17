import SwiftUI

struct GlassNumPadDismissPickerKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

public extension EnvironmentValues {
    var dismissGlassNumPadPicker: () -> Void {
        get { self[GlassNumPadDismissPickerKey.self] }
        set { self[GlassNumPadDismissPickerKey.self] = newValue }
    }
}

/// The width a pad embedded in a caller's own layout (not a sheet) has to fit — NutriKit's
/// iPhone Duo panel puts the pad beside the food header, and the book pose's half is
/// narrower than the window-based key size assumes. nil keeps the window-based sizing.
struct GlassNumPadAvailableWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

public extension EnvironmentValues {
    var glassNumPadAvailableWidth: CGFloat? {
        get { self[GlassNumPadAvailableWidthKey.self] }
        set { self[GlassNumPadAvailableWidthKey.self] = newValue }
    }
}

/// The height a pad embedded in a caller's own layout has for itself — the column it was
/// given, with nothing else in it. The keys then fit five heights into that, exactly as they
/// fit five into a window when the pad is in its own sheet, so a caller that hands the pad
/// over to (or takes it out of) that sheet can land on the sheet's key size by giving it the
/// sheet's own pad height (`Configuration.sheetPadHeight(inWindowSize:)`) — NutriKit's iPhone
/// Duo fold morph, #3245. nil keeps the window-based cap.
struct GlassNumPadAvailableHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

public extension EnvironmentValues {
    var glassNumPadAvailableHeight: CGFloat? {
        get { self[GlassNumPadAvailableHeightKey.self] }
        set { self[GlassNumPadAvailableHeightKey.self] = newValue }
    }
}

/// #3276 — whether the pad lays its readout and its keys out SIDE BY SIDE rather than stacked:
/// the caller's header, the number and the unit capsule in a leading column, the keys in a
/// trailing one. Set by the pad's own sheet (`glassNumPad(...)`) on an iPhone turned sideways,
/// where the window is ~400 pt tall and the stacked pad wants 388 at its smallest keys before
/// the caller's header — it was clipped top and bottom there. A pad a caller embeds in its own
/// layout keeps the stacked form (NutriKit's iPhone Duo panel lays the pad beside the food
/// header itself, and scales it to the half it has).
struct GlassNumPadSideBySideKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    /// Public since NutriKit #3725: a caller that presents the pad in a sheet of its own (the
    /// diary's item panel, which IS the pad there) sets it as the pad's own sheet does.
    var glassNumPadSideBySide: Bool {
        get { self[GlassNumPadSideBySideKey.self] }
        set { self[GlassNumPadSideBySideKey.self] = newValue }
    }
}

/// NutriKit #3725 — a row the caller stands under the keys, as wide as the key grid, a key gap
/// below the bottom row (the diary item's Delete and More). Sideways (`glassNumPadSideBySide`) it
/// stands at the foot of the readout's column instead, so the keys keep the sheet's height. The
/// caller sizes it, and adds its height and the gap to `additionalContentHeight` so the sheet
/// grows by it. nil, the default, is the pad as it was.
struct GlassNumPadFooterKey: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

/// NutriKit #3725 — two controls either side of the unit capsule, at the capsule's height: the
/// diary item's Delete and More where the sheet has no room for a row of their own (an iPhone SE).
/// They stand at the key grid's edges and the capsule stays centred between them. Hidden while the
/// calculator's operator row stands in the capsule's place.
public struct GlassNumPadCapsuleAccessories {
    public let leading: AnyView
    public let trailing: AnyView
    /// The width each side keeps, so the capsule stays centred whatever the two hold.
    public let width: CGFloat

    public init(leading: AnyView, trailing: AnyView, width: CGFloat) {
        self.leading = leading
        self.trailing = trailing
        self.width = width
    }
}

struct GlassNumPadCapsuleAccessoriesKey: EnvironmentKey {
    static let defaultValue: GlassNumPadCapsuleAccessories? = nil
}

/// NutriKit #3725 — a colour the unit capsule's border is drawn in, for a unit the caller wants
/// checked (an amount carried over to another food by conversion). nil, the default, is the
/// capsule's own border.
struct GlassNumPadCapsuleHighlightKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
    var glassNumPadFooter: AnyView? {
        get { self[GlassNumPadFooterKey.self] }
        set { self[GlassNumPadFooterKey.self] = newValue }
    }

    var glassNumPadCapsuleAccessories: GlassNumPadCapsuleAccessories? {
        get { self[GlassNumPadCapsuleAccessoriesKey.self] }
        set { self[GlassNumPadCapsuleAccessoriesKey.self] = newValue }
    }

    var glassNumPadCapsuleHighlight: Color? {
        get { self[GlassNumPadCapsuleHighlightKey.self] }
        set { self[GlassNumPadCapsuleHighlightKey.self] = newValue }
    }
}
