import SwiftUI

/// NutriKit #3731 — what the pad's plain surfaces stand on: an opaque layer of the sheet's own tone,
/// under each key's faint fill. The sheet is glass, and a key that was see-through on see-through glass
/// let whatever stood under the sheet (the diary, a food list) read straight through it. NutriKit's
/// panels stand their keys on the same layer (`DiaryPanelSurface`, #3719): keep the two in step.
enum KeySurface {
    static func backing(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.13) : Color(white: 0.97)
    }
}

extension Shape {
    /// The shape filled with the pad's opaque backing, then `fill` over it.
    func fillOnKeyBacking(_ fill: Color, _ scheme: ColorScheme) -> some View {
        ZStack {
            self.fill(KeySurface.backing(scheme))
            self.fill(fill)
        }
    }
}
