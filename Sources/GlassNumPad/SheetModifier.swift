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
                GlassNumPadSheetContent(
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
            .onChange(of: isPresented) { _, newValue in
                GlassNumPadDebug.event("sheetModifier.isPresented → \(newValue)")
            }
    }
}

/// The sheet's content: the pad, at its detent, on a clear background. A view of its own so it
/// can read the SHEET's size class (#3276): on an iPhone turned sideways — compact height — the
/// pad lays its readout and keys out side by side (`glassNumPadSideBySide`) and the sheet is
/// attached to the bottom edge, where UIKit otherwise drops a compact-height sheet's detents and
/// stands it edge to edge over the whole screen with no grabber and no corners. Attached, it is
/// a rounded sheet with its grabber, still the screen's full height, which the side-by-side pad
/// fits (`EdgeAttachedInCompactHeight` — SwiftUI has no modifier for it).
private struct GlassNumPadSheetContent<
    CapsuleLabel: View,
    PickerContent: View,
    ActionContent: View,
    AuxiliaryContent: View,
    Header: View
>: View {

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Binding var value: Double
    let configuration: GlassNumPad<CapsuleLabel, PickerContent, ActionContent, AuxiliaryContent, Header>.Configuration
    let capsuleLabel: () -> CapsuleLabel
    let pickerContent: () -> PickerContent
    let actionButton: () -> ActionContent
    let auxiliaryButton: () -> AuxiliaryContent
    let header: () -> Header
    let onAction: () -> Void
    let onAuxiliaryAction: () -> Void

    var body: some View {
        let _ = GlassNumPadDebug.event("sheetModifier.sheet body evaluated")
        let sideBySide = verticalSizeClass == .compact
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
        .environment(\.glassNumPadSideBySide, sideBySide)
        .presentationDetents([.height(configuration.resolvedSheetHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear)
        .background {
            Color.clear.onAppear {
                GlassNumPadDebug.event("sheetModifier.sheet onAppear (first frame on screen)")
            }
        }
        .background { EdgeAttachedInCompactHeight().frame(width: 0, height: 0) }
    }
}

/// #3276 — keeps the pad's sheet a sheet on an iPhone turned sideways (the pattern NutriKit's
/// `DiaryPanelSheet` settled in #3275). In compact height UIKit otherwise presents it over the
/// whole screen, edge to edge, with no grabber and no corners — nothing that says it pulls
/// down. Attached to the bottom edge it stands as a rounded sheet with its grabber, the
/// screen's full height. The sheet's controller is reached from inside the presentation: it is
/// the top of this controller's parent chain.
private struct EdgeAttachedInCompactHeight: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) {}

    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            attach()
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            attach()
        }

        private func attach() {
            var top: UIViewController = self
            while let parent = top.parent { top = parent }
            guard let sheet = top.sheetPresentationController,
                  !sheet.prefersEdgeAttachedInCompactHeight else { return }
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
    }
}
