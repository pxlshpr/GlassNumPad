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
