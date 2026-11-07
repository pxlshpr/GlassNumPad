import SwiftUI

/// A ready-made value the pad offers as a one-tap button — a common cue time,
/// a previously used amount.
public struct GlassNumPadPreset: Identifiable, Hashable, Sendable {
    public let id: String
    /// The button's text ("1m 30s", "250 g").
    public let label: String
    /// The value it stands for, in the units the pad's value is bound in (a
    /// `GlassCompoundPad`'s base units).
    public let value: Double

    public init(label: String, value: Double, id: String? = nil) {
        self.label = label
        self.value = value
        self.id = id ?? "\(label)|\(value)"
    }
}

/// The presets and what to do when one is tapped — carried in the environment
/// so any pad (plain or compound) picks it up.
public struct GlassNumPadPresets {
    public let items: [GlassNumPadPreset]
    public let onSelect: (GlassNumPadPreset) -> Void
    /// Whether the pad shows a tapped preset's value itself before `onSelect`.
    /// `GlassCompoundPad` turns it off for its inner pad: the preset is in base
    /// units, so the compound pad splits it across its parts instead.
    var appliesToPad = true
}

private struct GlassNumPadPresetsKey: EnvironmentKey {
    static let defaultValue: GlassNumPadPresets? = nil
}

public extension EnvironmentValues {
    var glassNumPadPresets: GlassNumPadPresets? {
        get { self[GlassNumPadPresetsKey.self] }
        set { self[GlassNumPadPresetsKey.self] = newValue }
    }
}

public extension View {
    /// Shows `presets` as a row of buttons where the pad's unit capsule sits
    /// (they take its place when both are configured). Tapping one hands it to
    /// `onSelect` — typically to apply it straight away and close — while the
    /// keys still type any exact value. An empty list shows no row.
    func glassNumPadPresets(
        _ presets: [GlassNumPadPreset],
        onSelect: @escaping (GlassNumPadPreset) -> Void
    ) -> some View {
        environment(\.glassNumPadPresets, GlassNumPadPresets(items: presets, onSelect: onSelect))
    }
}

/// The preset row: plain key-styled capsules on a horizontal scroll that runs
/// edge to edge, inset at its ends.
struct PresetStrip: View {
    @Environment(\.colorScheme) private var colorScheme
    let presets: GlassNumPadPresets
    /// The pad's handler: it shows the value, then calls `presets.onSelect`.
    let onTap: (GlassNumPadPreset) -> Void

    private var fill: Color { colorScheme == .dark ? .white.opacity(0.08) : Color(.label).opacity(0.06) }
    private var border: Color { colorScheme == .dark ? .white.opacity(0.1) : Color(.label).opacity(0.08) }
    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(presets.items) { preset in
                    Button {
                        Haptic.light()
                        onTap(preset)
                    } label: {
                        Text(preset.label)
                            .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(fg)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Capsule().fillOnKeyBacking(fill, colorScheme))
                            .overlay(Capsule().strokeBorder(border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .frame(height: 44)
    }
}
