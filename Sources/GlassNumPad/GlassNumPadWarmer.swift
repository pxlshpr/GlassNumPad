import SwiftUI

/// A near-invisible warmup view that renders a ``GlassNumPad`` instance once during app
/// launch so the first user-triggered presentation doesn't pay for Metal pipeline
/// compilation (`.glassEffect`), gradient shader compilation, or SF Symbol glyph
/// rasterization — the costs that make the first presentation feel laggy while
/// subsequent ones are smooth.
///
/// Drop this into your root view hierarchy at app start; it renders once at near-zero
/// opacity, then removes itself after `warmupDuration`.
public struct GlassNumPadWarmer: View {

    @State private var done = false

    private let warmupDuration: TimeInterval

    public init(warmupDuration: TimeInterval = 0.5) {
        self.warmupDuration = warmupDuration
    }

    public var body: some View {
        Group {
            if !done {
                contents
                    .allowsHitTesting(false)
                    .opacity(0.001)
                    .accessibilityHidden(true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + warmupDuration) {
                            done = true
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var contents: some View {
        // Mirror the real sheet structure (see SheetModifier.swift) so the costs that
        // matter actually land during this render: glass-effect Metal pipeline, the
        // prominent action button's gradient, and SF Symbol glyphs for every symbol the
        // keypad uses. Generic instantiation differs per call site, so a representative
        // signature is the best we can do at the package level.
        let sheetShape = UnevenRoundedRectangle(
            topLeadingRadius: 56,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 56,
            style: .continuous
        )
        VStack(spacing: 0) {
            GlassNumPad(
                value: .constant(0),
                configuration: .init(
                    accentColor: .accentColor,
                    actionButtonStyle: .prominent,
                    showCapsule: true,
                    showsCalculator: true,
                    maxDigitCount: 6
                ),
                capsuleLabel: { Text("g") },
                pickerContent: { EmptyView() },
                actionButton: { Image(systemName: "checkmark") },
                auxiliaryButton: { EmptyView() },
                header: { EmptyView() }
            )
        }
        .background {
            sheetShape
                .fill(.clear)
                .glassEffect(.regular, in: sheetShape)
        }
    }
}
