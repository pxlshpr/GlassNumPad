import SwiftUI

// MARK: - View modifier for overlay-based presentation

public extension View {

    /// Presents a ``GlassNumPad`` in a bottom-anchored overlay (with capsule + picker + action + auxiliary + optional header).
    ///
    /// Uses a `ZStack` overlay rather than `.sheet` so taps register from the first frame of the
    /// present animation — `UISheetPresentationController` disables hit testing on the sheet view
    /// during its slide-up.
    func glassNumPad<C: View, P: View, A: View, Aux: View, H: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A, Aux, H>.Configuration = .init(),
        @ViewBuilder capsuleLabel: @escaping () -> C,
        @ViewBuilder pickerContent: @escaping () -> P,
        @ViewBuilder actionButton: @escaping () -> A,
        @ViewBuilder auxiliaryButton: @escaping () -> Aux,
        @ViewBuilder header: @escaping () -> H,
        onAction: @escaping () -> Void = {},
        onAuxiliaryAction: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            GlassNumPadPresentation(
                isPresented: isPresented,
                value: value,
                configuration: configuration,
                capsuleLabel: capsuleLabel,
                pickerContent: pickerContent,
                actionButton: actionButton,
                auxiliaryButton: auxiliaryButton,
                header: header,
                onAction: onAction,
                onAuxiliaryAction: onAuxiliaryAction
            )
        )
    }

    /// Capsule + picker + action + auxiliary, no header — backward compatible.
    func glassNumPad<C: View, P: View, A: View, Aux: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A, Aux, EmptyView>.Configuration = .init(),
        @ViewBuilder capsuleLabel: @escaping () -> C,
        @ViewBuilder pickerContent: @escaping () -> P,
        @ViewBuilder actionButton: @escaping () -> A,
        @ViewBuilder auxiliaryButton: @escaping () -> Aux,
        onAction: @escaping () -> Void = {},
        onAuxiliaryAction: @escaping () -> Void = {}
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: capsuleLabel,
            pickerContent: pickerContent,
            actionButton: actionButton,
            auxiliaryButton: auxiliaryButton,
            header: { EmptyView() },
            onAction: onAction,
            onAuxiliaryAction: onAuxiliaryAction
        )
    }

    /// Presents a ``GlassNumPad`` with capsule + picker + action (no auxiliary button — backward compatible).
    func glassNumPad<C: View, P: View, A: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A, EmptyView, EmptyView>.Configuration = .init(),
        @ViewBuilder capsuleLabel: @escaping () -> C,
        @ViewBuilder pickerContent: @escaping () -> P,
        @ViewBuilder actionButton: @escaping () -> A,
        onAction: @escaping () -> Void = {}
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: capsuleLabel,
            pickerContent: pickerContent,
            actionButton: actionButton,
            auxiliaryButton: { EmptyView() },
            header: { EmptyView() },
            onAction: onAction,
            onAuxiliaryAction: {}
        )
    }

    /// Capsule + picker + action + header (no auxiliary). Use this when the caller wants to embed
    /// custom content (e.g. a food row) above the number display.
    func glassNumPad<C: View, P: View, A: View, H: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A, EmptyView, H>.Configuration = .init(),
        @ViewBuilder capsuleLabel: @escaping () -> C,
        @ViewBuilder pickerContent: @escaping () -> P,
        @ViewBuilder actionButton: @escaping () -> A,
        @ViewBuilder header: @escaping () -> H,
        onAction: @escaping () -> Void = {}
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: capsuleLabel,
            pickerContent: pickerContent,
            actionButton: actionButton,
            auxiliaryButton: { EmptyView() },
            header: header,
            onAction: onAction,
            onAuxiliaryAction: {}
        )
    }

    /// Presents a ``GlassNumPad`` without a capsule (no auxiliary button).
    func glassNumPad<A: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, A, EmptyView, EmptyView>.Configuration = .init(),
        @ViewBuilder actionButton: @escaping () -> A,
        onAction: @escaping () -> Void = {}
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: actionButton,
            auxiliaryButton: { EmptyView() },
            header: { EmptyView() },
            onAction: onAction,
            onAuxiliaryAction: {}
        )
    }

    /// Presents a ``GlassNumPad`` without a capsule, with an auxiliary button (e.g. for calc-disabled custom action).
    func glassNumPad<A: View, Aux: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, A, Aux, EmptyView>.Configuration = .init(),
        @ViewBuilder actionButton: @escaping () -> A,
        @ViewBuilder auxiliaryButton: @escaping () -> Aux,
        onAction: @escaping () -> Void = {},
        onAuxiliaryAction: @escaping () -> Void = {}
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: actionButton,
            auxiliaryButton: auxiliaryButton,
            header: { EmptyView() },
            onAction: onAction,
            onAuxiliaryAction: onAuxiliaryAction
        )
    }

    /// Presents a bare ``GlassNumPad`` (no capsule, no action button, no auxiliary).
    func glassNumPad(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, EmptyView, EmptyView, EmptyView>.Configuration = .init()
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: { EmptyView() },
            auxiliaryButton: { EmptyView() },
            header: { EmptyView() },
            onAction: {},
            onAuxiliaryAction: {}
        )
    }
}

// MARK: - Presentation modifier

private struct GlassNumPadPresentation<
    CapsuleLabel: View,
    PickerContent: View,
    ActionContent: View,
    AuxiliaryContent: View,
    Header: View
>: ViewModifier {

    @Binding var isPresented: Bool
    @Binding var value: Double
    let configuration: GlassNumPad<CapsuleLabel, PickerContent, ActionContent, AuxiliaryContent, Header>.Configuration
    let capsuleLabel: () -> CapsuleLabel
    let pickerContent: () -> PickerContent
    let actionButton: () -> ActionContent
    let auxiliaryButton: () -> AuxiliaryContent
    let header: () -> Header
    let onAction: () -> Void
    let onAuxiliaryAction: () -> Void

    @State private var dragOffset: CGFloat = 0

    private static var presentSpring: Animation {
        .spring(response: 0.35, dampingFraction: 0.85)
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    if isPresented {
                        sheet
                            .transition(.move(edge: .bottom))
                    }
                }
                .animation(Self.presentSpring, value: isPresented)
                .ignoresSafeArea(.container, edges: .bottom)
            }
    }

    private var sheet: some View {
        // Asymmetric drag handling:
        //   - Downward drag (dragOffset > 0): apply via .offset so the whole
        //     sheet (incl. glass) slides off-screen, used for dismissal animation.
        //   - Upward drag (dragOffset < 0): grow the bottom padding instead of
        //     applying offset, so the sheet's bottom stays anchored at the screen
        //     bottom (keeping the home-indicator covered) while the top extends
        //     upward to give rubber-band feedback.
        let downwardOffset = max(0, dragOffset)
        let upwardStretch = max(0, -dragOffset)

        return VStack(spacing: 0) {
            // Drag indicator (replaces system .presentationDragIndicator)
            Capsule()
                .fill(Color.secondary.opacity(0.45))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity)

            GlassNumPad(
                value: $value,
                configuration: configuration,
                capsuleLabel: capsuleLabel,
                pickerContent: pickerContent,
                actionButton: actionButton,
                auxiliaryButton: auxiliaryButton,
                header: header,
                onAction: onAction,
                onAuxiliaryAction: onAuxiliaryAction
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, upwardStretch)
        .background {
            // Apple's recommended pattern for backgrounds extending past safe
            // area: attach .ignoresSafeArea to the shape itself, not the host.
            // The shape grows to fill its parent (the .background slot), and
            // ignoresSafeArea on the shape lets it paint past the safe area
            // into the home-indicator zone. Glass is masked to the same shape;
            // without `in:` it would default to .capsule (oval).
            Self.sheetShape
                .fill(.clear)
                .glassEffect(.regular, in: Self.sheetShape)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .contentShape(Self.sheetShape)
        .offset(y: downwardOffset)
        .gesture(dragGesture)
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) {
            isPresented = false
        }
    }

    private static var sheetShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 56,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 56,
            style: .continuous
        )
    }

    private var dragGesture: some Gesture {
        // minimumDistance > 0 lets button taps win when finger movement is small,
        // and only activates the drag once the user clearly moves the sheet.
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let translation = value.translation.height
                if translation >= 0 {
                    dragOffset = translation
                } else {
                    // Upward drag: rubber-band damping (UIKit-style, c=0.55, d=200).
                    let absT = abs(translation)
                    let dimension: CGFloat = 200
                    let coefficient: CGFloat = 0.55
                    let damped = (coefficient * absT * dimension) / (dimension + coefficient * absT)
                    dragOffset = -damped
                }
            }
            .onEnded { value in
                let predictedEnd = value.predictedEndTranslation.height
                let dragDistance = value.translation.height
                let shouldDismiss = dragDistance > 100 || predictedEnd > 200
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    // Reset offset within the same animation so the next presentation
                    // starts at zero. When dismissing, the slide-off transition compounds
                    // with offset → 0 to keep the view visually attached to the finger.
                    dragOffset = 0
                    if shouldDismiss { isPresented = false }
                }
            }
    }
}
