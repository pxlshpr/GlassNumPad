import SwiftUI

/// A warmup view that renders a ``GlassNumPad`` instance once during launch so the first
/// user-triggered presentation doesn't pay for Metal pipeline compilation
/// (`.glassEffect`), gradient shader compilation, or SF Symbol glyph rasterization —
/// the costs that make the first presentation feel laggy while subsequent ones are
/// smooth.
///
/// Designed to be attached via `.background { GlassNumPadWarmer() }` on a host view
/// that has an opaque foreground (so the warmup keypad is hidden visually but still
/// rendered through the full Metal pipeline). Off-screen positioning was tried first
/// but iOS's tile-based deferred renderer culled the tiles before the pipeline state
/// got compiled, defeating the warmup. On-screen-but-covered is what reliably works.
///
/// After `warmupDuration` the contents swap to `Color.clear` so the warmup view stops
/// costing CPU/GPU time. The struct itself stays in the parent's layout (size doesn't
/// change) so the parent isn't invalidated by the swap.
public struct GlassNumPadWarmer: View {

    @State private var warmedUp = false

    private let warmupDuration: TimeInterval

    public init(warmupDuration: TimeInterval = 0.6) {
        self.warmupDuration = warmupDuration
        GlassNumPadDebug.event("warmer.init")
    }

    public var body: some View {
        Group {
            if warmedUp {
                Color.clear
            } else {
                contents
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .onAppear {
                        GlassNumPadDebug.event("warmer.onAppear (will hold for \(Int(warmupDuration * 1000))ms)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + warmupDuration) {
                            GlassNumPadDebug.event("warmer.done (swapping to Color.clear)")
                            warmedUp = true
                        }
                    }
                    .background {
                        Color.clear.onAppear {
                            GlassNumPadDebug.event("warmer.contents-onAppear (first frame rendered)")
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var contents: some View {
        let _ = GlassNumPadDebug.event("warmer.contents-getter called")
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
