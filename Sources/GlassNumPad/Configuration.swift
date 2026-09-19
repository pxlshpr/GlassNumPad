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
        /// Maximum number of digit characters allowed in a single operand.
        /// Caps unbounded input from rapid digit tapping. Override to fit
        /// the contextual range of the value being edited.
        public var maxDigitCount: Int
        /// When true, the pad opens in picker mode (capsule pre-expanded) so
        /// callers whose primary input is a discrete picker (e.g. RPE values
        /// 6–10 in 0.5 steps) skip the digit grid on first appearance.
        public var startsInPicker: Bool
        /// Extra height added to the auto-computed sheet detent to fit caller-
        /// supplied header content (the `header:` ViewBuilder slot). Ignored
        /// when `sheetHeight` is set explicitly.
        public var additionalContentHeight: CGFloat
        /// Whether the capsule's unit is user-selectable. When false (there's
        /// only one possible unit), the capsule drops its chevron, dims, and
        /// stops responding to taps so it's clear there's no choice to make.
        public var unitSelectable: Bool
        /// Runtime switch for the caller-supplied auxiliary button. The slot's
        /// presence is otherwise derived from the `AuxiliaryContent` TYPE, which a
        /// caller whose button is conditional (e.g. delete, only while editing an
        /// existing entry) can't vary per presentation — this flag can. Ignored
        /// when there is no auxiliary content to show.
        public var showsAuxiliaryButton: Bool

        public init(
            accentColor: Color = .blue,
            clearColor: Color = .orange,
            sheetHeight: CGFloat = 0,
            buttonCornerRadius: CGFloat = 20,
            buttonSpacing: CGFloat = 10,
            actionButtonStyle: ActionButtonStyle = .prominent,
            showCapsule: Bool = true,
            showsCalculator: Bool = true,
            maxDigitCount: Int = 12,
            startsInPicker: Bool = false,
            additionalContentHeight: CGFloat = 0,
            unitSelectable: Bool = true,
            showsAuxiliaryButton: Bool = true
        ) {
            self.accentColor = accentColor
            self.clearColor = clearColor
            self.sheetHeight = sheetHeight
            self.buttonCornerRadius = buttonCornerRadius
            self.buttonSpacing = buttonSpacing
            self.actionButtonStyle = actionButtonStyle
            self.showCapsule = showCapsule
            self.showsCalculator = showsCalculator
            self.maxDigitCount = maxDigitCount
            self.startsInPicker = startsInPicker
            self.additionalContentHeight = additionalContentHeight
            self.unitSelectable = unitSelectable
            self.showsAuxiliaryButton = showsAuxiliaryButton
        }

        /// Button size: capped at 76pt, with minimum 30pt margin per side — and no taller
        /// than lets the whole sheet (`resolvedSheetHeight`, the caller's header included)
        /// fit the window with `sheetTopRoom` to spare. Five keys stand in the sheet's height
        /// (the header zone is a key plus 70, then four rows), so a window that is too short
        /// shrinks every key alike: the iPhone Duo's cover display (466 × 678) wanted 727 pt
        /// for 76 pt keys under a 175 pt food header and cut the top off; so did the iPhone SE.
        /// Measured against the key window (`UIScreen.main.bounds` is stale on a foldable —
        /// it kept the cover display's size after the unfold), falling back to the screen.
        static func computeButtonSize(spacing: CGFloat, additionalContentHeight: CGFloat = 0) -> CGFloat {
            let bounds = windowBounds
            let maxSize: CGFloat = 76
            let minMargin: CGFloat = 30
            let byWidth = floor((bounds.width - 2 * minMargin - 3 * spacing) / 4)
            let fixed = 8 + 70 + 4 * spacing + 10 + 44 + additionalContentHeight + sheetTopRoom
            let byHeight = floor((bounds.height - fixed) / 5)
            return max(minSize, min(maxSize, byWidth, byHeight))
        }

        /// A key never shrinks below this, whatever the window: past it the sheet clips
        /// rather than the keys becoming untappable.
        static var minSize: CGFloat { 52 }
        /// What a sheet leaves above itself at its tallest: the top safe area is the
        /// caller's window's, and a `.height` detent stops short of the top by about this.
        static var sheetTopRoom: CGFloat { 20 }

        /// Read on the main thread only — from view bodies and the sheet's detent — hence the
        /// assumption rather than an annotation (the callers are not actor-annotated).
        static var windowBounds: CGRect {
            MainActor.assumeIsolated {
                let window = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first { $0.activationState == .foregroundActive }?
                    .keyWindow
                guard let window, window.bounds.width > 0, window.bounds.height > 0 else {
                    return UIScreen.main.bounds
                }
                return window.bounds
            }
        }

        public var resolvedSheetHeight: CGFloat {
            if sheetHeight > 0 { return sheetHeight }
            let btn = Self.computeButtonSize(spacing: buttonSpacing, additionalContentHeight: additionalContentHeight)
            let headerH = btn + 70
            // top(8) + header + spacing + 4 rows + 3 gaps + bottom(10) + handle+safe(44)
            return 8 + headerH + 4 * btn + 4 * buttonSpacing + 10 + 44 + additionalContentHeight
        }
    }
}
