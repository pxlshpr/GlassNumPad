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
        /// A `/` key at the far left of the bottom row, so a fraction can be typed as one
        /// ("1/4" → 0.25): `0` gives up one cell for it. Numpad mode only — the calculator has
        /// its own ÷, and the key slides out as the calculator's `.` slides in. Needs a cell to
        /// stand in, so it is ignored when the calculator toggle AND an auxiliary button both
        /// already share the row with `0`.
        public var showsFractionKey: Bool

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
            showsAuxiliaryButton: Bool = true,
            showsFractionKey: Bool = false
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
            self.showsFractionKey = showsFractionKey
        }

        /// Button size: capped at 76pt, with minimum 30pt margin per side — and no taller
        /// than lets the whole sheet (`resolvedSheetHeight`, the caller's header included)
        /// fit the window with `sheetTopRoom` to spare. Five keys stand in the sheet's height
        /// (the header zone is a key plus 70, then four rows), so a window that is too short
        /// shrinks every key alike: the iPhone Duo's cover display (466 × 678) wanted 727 pt
        /// for 76 pt keys under a 175 pt food header and cut the top off; so did the iPhone SE.
        /// Measured against the key window (`UIScreen.main.bounds` is stale on a foldable —
        /// it kept the cover display's size after the unfold), falling back to the screen.
        ///
        /// `availableWidth` (the `glassNumPadAvailableWidth` environment) is the width a pad
        /// embedded in a caller's layout has: the keys then fit that less the pad's own 20 pt
        /// readout padding per side. `availableHeight` (`glassNumPadAvailableHeight`) is the
        /// height that pad was given, and the same five key heights are fitted into it —
        /// with none of the sheet's chrome, since an embedded pad has none. Given neither,
        /// the window is the measure, as it is for the pad in its own sheet.
        static func computeButtonSize(spacing: CGFloat, additionalContentHeight: CGFloat = 0,
                                      availableWidth: CGFloat? = nil, availableHeight: CGFloat? = nil) -> CGFloat {
            let bounds = windowBounds
            let byWidth: CGFloat
            if let availableWidth {
                byWidth = floor((availableWidth - 2 * 20 - 3 * spacing) / 4)
            } else {
                byWidth = floor((bounds.width - 2 * minMargin - 3 * spacing) / 4)
            }
            guard let availableHeight else {
                return sheetButtonSize(spacing: spacing, additionalContentHeight: additionalContentHeight,
                                       windowSize: bounds.size, byWidth: byWidth)
            }
            let byHeight = floor((availableHeight - padFixedHeight(spacing: spacing)) / 5)
            return max(minSize, min(maxSize, byWidth, byHeight))
        }

        /// The key size the pad's own SHEET uses on a window this size — the cap that put the
        /// iPhone Duo's cover display (466 × 678) at 62 pt under a 175 pt food header.
        static func sheetButtonSize(spacing: CGFloat, additionalContentHeight: CGFloat,
                                    windowSize: CGSize, byWidth: CGFloat? = nil) -> CGFloat {
            let width = byWidth ?? floor((windowSize.width - 2 * minMargin - 3 * spacing) / 4)
            let fixed = padFixedHeight(spacing: spacing) + sheetChromeHeight + additionalContentHeight + sheetTopRoom
            let byHeight = floor((windowSize.height - fixed) / 5)
            return max(minSize, min(maxSize, width, byHeight))
        }

        /// What the pad's own column costs beside its five key heights: its top padding, the
        /// 70 pt the readout zone stands above the key it is built on, the four gaps and the
        /// bottom padding — `GlassNumPad.body`'s own arithmetic, with none of the sheet's.
        static func padFixedHeight(spacing: CGFloat) -> CGFloat { 8 + 70 + 4 * spacing + 10 }

        /// #3276 — the key size the pad's own sheet uses on an iPhone turned sideways, where the
        /// readout and the keys stand side by side (`glassNumPadSideBySide`): FOUR key heights in
        /// the height it has (three digit rows and the bottom row — the readout is beside them,
        /// not above), the pad's own top and bottom padding and three gaps taken off; and a grid
        /// in each half of the width, the two halves `wideGap` apart inside `minMargin` a side.
        /// `size` is the sheet's content box once measured, the window until then.
        static func wideButtonSize(spacing: CGFloat, size: CGSize) -> CGFloat {
            let byHeight = floor((size.height - 8 - 10 - 3 * spacing) / 4)
            let half = (size.width - 2 * minMargin - wideGap) / 2
            let byWidth = floor((half - 3 * spacing) / 4)
            return max(minSize, min(maxSize, byWidth, byHeight))
        }

        /// #3276 — between the two columns of the side-by-side layout.
        static var wideGap: CGFloat { 24 }

        /// A key is never bigger than this, whatever the window.
        static var maxSize: CGFloat { 76 }
        /// A key never shrinks below this, whatever the window: past it the sheet clips
        /// rather than the keys becoming untappable.
        static var minSize: CGFloat { 52 }
        /// The least a sheet leaves at each side of the key grid.
        static var minMargin: CGFloat { 30 }
        /// What a sheet leaves above itself at its tallest: the top safe area is the
        /// caller's window's, and a `.height` detent stops short of the top by about this.
        static var sheetTopRoom: CGFloat { 20 }
        /// What the sheet wears around the pad: the grabber's band and the bottom safe area.
        static var sheetChromeHeight: CGFloat { 44 }

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
            resolvedSheetHeight(inWindowSize: Self.windowBounds.size)
        }

        /// The sheet's height on a window the caller names rather than the key one — for a
        /// caller whose window has already changed under it (the iPhone Duo's fold, #3245).
        public func resolvedSheetHeight(inWindowSize size: CGSize) -> CGFloat {
            if sheetHeight > 0 { return sheetHeight }
            // the pad's own column + handle/safe(44) + the caller's header
            return sheetPadHeight(inWindowSize: size) + Self.sheetChromeHeight + additionalContentHeight
        }

        /// The height the pad ITSELF takes in its own sheet on a window this size — the
        /// detent less the caller's header and the grabber/safe-area band. A caller that
        /// draws the pad inside its own layout and has to hand over to (or come out of) that
        /// sheet without the keys jumping gives the pad exactly this, through
        /// `glassNumPadAvailableHeight`: five key heights of the sheet's size fit it, so the
        /// keys come out the sheet's. NutriKit's iPhone Duo fold morph (#3245) springs the
        /// pad's height to it, which is the whole of what the keys do.
        /// The width of the pad's key grid in its own sheet on a window this size — which is
        /// also the width the sheet frames the caller's `header:` content to, so a caller
        /// morphing its own layout onto the sheet's lands both on one column (#3245).
        public func sheetGridWidth(inWindowSize size: CGSize) -> CGFloat {
            4 * Self.sheetButtonSize(spacing: buttonSpacing,
                                     additionalContentHeight: additionalContentHeight,
                                     windowSize: size) + 3 * buttonSpacing
        }

        public func sheetPadHeight(inWindowSize size: CGSize) -> CGFloat {
            Self.padFixedHeight(spacing: buttonSpacing)
                + 5 * Self.sheetButtonSize(spacing: buttonSpacing,
                                           additionalContentHeight: additionalContentHeight,
                                           windowSize: size)
        }
    }
}

/// The pad's configuration without the pad's five view generics, which it uses none of: for a
/// caller that has to ask the configuration something — how tall the pad's own sheet is, and
/// the pad inside it — without spelling those types out (#3245).
public typealias GlassNumPadConfiguration =
    GlassNumPad<EmptyView, EmptyView, EmptyView, EmptyView, EmptyView>.Configuration
