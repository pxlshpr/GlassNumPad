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
