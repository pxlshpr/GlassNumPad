import SwiftUI

// MARK: - View modifier for sheet presentation

public extension View {

    /// Presents a ``GlassNumPad`` in a detented sheet (with capsule + picker + action + auxiliary + optional header).
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

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent
            }
            .onChange(of: isPresented) { _, newValue in
                GlassNumPadDebug.event("sheetModifier.isPresented → \(newValue)")
            }
    }

    private var sheetContent: some View {
        let _ = GlassNumPadDebug.event("sheetModifier.sheet body evaluated")
        return GlassNumPad(
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
        .presentationDetents([.height(configuration.resolvedSheetHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear)
        .background {
            Color.clear.onAppear {
                GlassNumPadDebug.event("sheetModifier.sheet onAppear (first frame on screen)")
            }
        }
    }
}
