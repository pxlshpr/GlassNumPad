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
