import SwiftUI

public extension GlassNumPad {

    enum ActionButtonStyle {
        case dashed, standard, prominent
    }

    struct Configuration {
        public var accentColor: Color
        public var clearColor: Color
        public var sheetHeight: CGFloat
        public var buttonCornerRadius: CGFloat
        public var buttonSpacing: CGFloat
        public var actionButtonStyle: ActionButtonStyle
        public var showCapsule: Bool
        public var showsCalculator: Bool

        public init(
            accentColor: Color = .blue,
            clearColor: Color = .orange,
            sheetHeight: CGFloat = 0,
            buttonCornerRadius: CGFloat = 20,
            buttonSpacing: CGFloat = 10,
            actionButtonStyle: ActionButtonStyle = .prominent,
            showCapsule: Bool = true,
            showsCalculator: Bool = true
        ) {
            self.accentColor = accentColor
            self.clearColor = clearColor
            self.sheetHeight = sheetHeight
            self.buttonCornerRadius = buttonCornerRadius
            self.buttonSpacing = buttonSpacing
            self.actionButtonStyle = actionButtonStyle
            self.showCapsule = showCapsule
            self.showsCalculator = showsCalculator
        }

        /// Button size: capped at 76pt, with minimum 30pt margin per side.
        static func computeButtonSize(spacing: CGFloat) -> CGFloat {
            let screenWidth = UIScreen.main.bounds.width
            let maxSize: CGFloat = 76
            let minMargin: CGFloat = 30
            return min(maxSize, floor((screenWidth - 2 * minMargin - 3 * spacing) / 4))
        }

        public var resolvedSheetHeight: CGFloat {
            if sheetHeight > 0 { return sheetHeight }
            let btn = Self.computeButtonSize(spacing: buttonSpacing)
            let headerH = btn + 70
            // top(8) + header + spacing + 4 rows + 3 gaps + bottom(10) + handle+safe(44)
            return 8 + headerH + 4 * btn + 4 * buttonSpacing + 10 + 44
        }
    }
}
