import SwiftUI

public extension GlassNumPad {

    /// Styling options for the custom action button in the bottom-right corner.
    enum ActionButtonStyle {
        /// Dashed border outline, no fill.
        case dashed
        /// Standard gray fill matching number buttons.
        case standard
        /// Accent-colored fill with white foreground.
        case prominent
    }

    /// Configuration for a ``GlassNumPad`` instance.
    struct Configuration {
        /// The accent color used for prominent buttons and highlights.
        public var accentColor: Color
        /// The color used for the clear (C) button text.
        public var clearColor: Color
        /// Height of the presentation sheet detent.
        public var sheetHeight: CGFloat
        /// Corner radius for individual buttons.
        public var buttonCornerRadius: CGFloat
        /// Spacing between buttons in the grid.
        public var buttonSpacing: CGFloat
        /// Horizontal padding around the entire pad.
        public var horizontalPadding: CGFloat
        /// Style applied to the custom action button slot.
        public var actionButtonStyle: ActionButtonStyle
        /// Whether to show the capsule bar below the number display.
        public var showCapsule: Bool

        public init(
            accentColor: Color = .blue,
            clearColor: Color = .orange,
            sheetHeight: CGFloat = 480,
            buttonCornerRadius: CGFloat = 12,
            buttonSpacing: CGFloat = 8,
            horizontalPadding: CGFloat = 16,
            actionButtonStyle: ActionButtonStyle = .prominent,
            showCapsule: Bool = true
        ) {
            self.accentColor = accentColor
            self.clearColor = clearColor
            self.sheetHeight = sheetHeight
            self.buttonCornerRadius = buttonCornerRadius
            self.buttonSpacing = buttonSpacing
            self.horizontalPadding = horizontalPadding
            self.actionButtonStyle = actionButtonStyle
            self.showCapsule = showCapsule
        }
    }
}
