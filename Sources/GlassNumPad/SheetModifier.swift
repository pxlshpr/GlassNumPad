import SwiftUI

// MARK: - View modifier for sheet presentation

public extension View {

    /// Presents a ``GlassNumPad`` in a detented glass sheet (with capsule + picker + action + auxiliary).
    func glassNumPad<C: View, P: View, A: View, Aux: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A, Aux>.Configuration = .init(),
        @ViewBuilder capsuleLabel: @escaping () -> C,
        @ViewBuilder pickerContent: @escaping () -> P,
        @ViewBuilder actionButton: @escaping () -> A,
        @ViewBuilder auxiliaryButton: @escaping () -> Aux,
        onAction: @escaping () -> Void = {},
        onAuxiliaryAction: @escaping () -> Void = {}
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            GlassNumPad(
                value: value,
                configuration: configuration,
                capsuleLabel: capsuleLabel,
                pickerContent: pickerContent,
                actionButton: actionButton,
                auxiliaryButton: auxiliaryButton,
                onAction: onAction,
                onAuxiliaryAction: onAuxiliaryAction
            )
            .presentationDetents([.height(configuration.resolvedSheetHeight)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
        }
    }

    /// Presents a ``GlassNumPad`` with capsule + picker + action (no auxiliary button — backward compatible).
    func glassNumPad<C: View, P: View, A: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A, EmptyView>.Configuration = .init(),
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
            onAction: onAction,
            onAuxiliaryAction: {}
        )
    }

    /// Presents a ``GlassNumPad`` without a capsule (no auxiliary button).
    func glassNumPad<A: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, A, EmptyView>.Configuration = .init(),
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
            onAction: onAction,
            onAuxiliaryAction: {}
        )
    }

    /// Presents a ``GlassNumPad`` without a capsule, with an auxiliary button (e.g. for calc-disabled custom action).
    func glassNumPad<A: View, Aux: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, A, Aux>.Configuration = .init(),
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
            onAction: onAction,
            onAuxiliaryAction: onAuxiliaryAction
        )
    }

    /// Presents a bare ``GlassNumPad`` (no capsule, no action button, no auxiliary).
    func glassNumPad(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, EmptyView, EmptyView>.Configuration = .init()
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: { EmptyView() },
            auxiliaryButton: { EmptyView() },
            onAction: {},
            onAuxiliaryAction: {}
        )
    }
}
