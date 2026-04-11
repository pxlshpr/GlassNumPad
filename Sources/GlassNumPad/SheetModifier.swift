import SwiftUI

// MARK: - View modifier for sheet presentation

public extension View {

    /// Presents a ``GlassNumPad`` in a detented glass sheet.
    func glassNumPad<C: View, P: View, A: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<C, P, A>.Configuration = .init(),
        @ViewBuilder capsuleLabel: @escaping () -> C,
        @ViewBuilder pickerContent: @escaping () -> P,
        @ViewBuilder actionButton: @escaping () -> A,
        onAction: @escaping () -> Void = {}
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            GlassNumPad(
                value: value,
                configuration: configuration,
                capsuleLabel: capsuleLabel,
                pickerContent: pickerContent,
                actionButton: actionButton,
                onAction: onAction
            )
            .presentationDetents([.height(configuration.resolvedSheetHeight)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
    }

    /// Presents a ``GlassNumPad`` without a capsule.
    func glassNumPad<A: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, A>.Configuration = .init(),
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
            onAction: onAction
        )
    }

    /// Presents a bare ``GlassNumPad`` (no capsule, no action button).
    func glassNumPad(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        configuration: GlassNumPad<EmptyView, EmptyView, EmptyView>.Configuration = .init()
    ) -> some View {
        glassNumPad(
            isPresented: isPresented,
            value: value,
            configuration: configuration,
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: { EmptyView() },
            onAction: {}
        )
    }
}
