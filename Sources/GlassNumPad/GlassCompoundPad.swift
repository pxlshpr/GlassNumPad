import SwiftUI

// MARK: - Units

/// One part of a compound value — "min" of a duration, "ft" of a height,
/// "st" of a weight.
public struct GlassCompoundUnit: Sendable, Hashable {
    /// Beside the number while this part is being typed ("min").
    public let name: String
    /// After the value in the part chips ("m").
    public let suffix: String
    /// How many base units one of this unit is (minutes of a seconds-based
    /// duration: 60; feet of an inches-based length: 12).
    public let factor: Double
    /// The most digits this part takes.
    public let maxDigits: Int

    public init(name: String, suffix: String, factor: Double, maxDigits: Int = 2) {
        self.name = name
        self.suffix = suffix
        self.factor = factor
        self.maxDigits = maxDigits
    }
}

/// The parts a `GlassCompoundPad` offers, largest first. The value the pad
/// binds is in BASE units — the unit whose `factor` is 1, whether or not it's
/// one of the parts (`.hoursMinutes` keeps seconds as its base).
public struct GlassCompoundUnits: Sendable, Hashable {
    public let units: [GlassCompoundUnit]

    public init(_ units: [GlassCompoundUnit]) {
        self.units = units.sorted { $0.factor > $1.factor }
    }

    // Durations — base: seconds.
    public static let hoursMinutesSeconds = GlassCompoundUnits([.hours, .minutes, .seconds])
    public static let hoursMinutes = GlassCompoundUnits([.hours, .minutes])
    public static let minutesSeconds = GlassCompoundUnits([.minutes, .seconds])

    // Length — base: inches.
    public static let feetInches = GlassCompoundUnits([
        GlassCompoundUnit(name: "ft", suffix: "ft", factor: 12, maxDigits: 1),
        GlassCompoundUnit(name: "in", suffix: "in", factor: 1, maxDigits: 3),
    ])

    // Weight — base: pounds.
    public static let stonesPounds = GlassCompoundUnits([
        GlassCompoundUnit(name: "st", suffix: "st", factor: 14, maxDigits: 2),
        GlassCompoundUnit(name: "lb", suffix: "lb", factor: 1, maxDigits: 4),
    ])
}

public extension GlassCompoundUnit {
    static let hours = GlassCompoundUnit(name: "hours", suffix: "h", factor: 3600)
    static let minutes = GlassCompoundUnit(name: "min", suffix: "m", factor: 60)
    static let seconds = GlassCompoundUnit(name: "sec", suffix: "s", factor: 1)
}

// MARK: - Pad

/// A keypad for a value made of several parts — hours/minutes/seconds,
/// feet/inches, stones/pounds — typing one part at a time.
///
/// A row of part chips ("1m · 30s") sits above the number; the selected chip is
/// the part the keys type into, and tapping another switches to it. The pad
/// has no unit capsule: the selected part's name sits muted beside the number.
/// Parts aren't clamped while typing (90 seconds is fine), so the bound `value`
/// is always the plain sum in base units; format it to show it normalised.
/// The smallest part may carry a decimal (10 st 3.5 lb); the others are whole.
///
/// Embed it, or present it with `.glassCompoundPad(isPresented:value:units:…)`.
public struct GlassCompoundPad<ActionContent: View, Header: View>: View {

    @Binding var value: Double
    let units: GlassCompoundUnits
    let accentColor: Color
    let headerHeight: CGFloat
    let actionButton: () -> ActionContent
    let header: () -> Header
    let onAction: () -> Void

    @State private var parts: [Double]
    @State private var selected: Int
    @Namespace private var selection

    /// Height of the part-chip row above the number.
    public static var partRowHeight: CGFloat { 56 }

    /// - Parameters:
    ///   - value: The whole value, in base units.
    ///   - units: The parts to offer (a preset, or your own).
    ///   - accentColor: Fills the action key and marks the selected part.
    ///   - headerHeight: The height of `header`, so a sheet can size itself.
    ///   - actionButton: The action key's label (e.g. a checkmark).
    ///   - header: Content above the part chips (a title, say).
    ///   - onAction: The action key was tapped; `value` is already up to date.
    public init(
        value: Binding<Double>,
        units: GlassCompoundUnits,
        accentColor: Color = .blue,
        headerHeight: CGFloat = 0,
        @ViewBuilder actionButton: @escaping () -> ActionContent,
        @ViewBuilder header: @escaping () -> Header,
        onAction: @escaping () -> Void = {}
    ) {
        self._value = value
        self.units = units
        self.accentColor = accentColor
        self.headerHeight = headerHeight
        self.actionButton = actionButton
        self.header = header
        self.onAction = onAction

        let split = Self.split(value.wrappedValue, into: units)
        _parts = State(initialValue: split)
        // Start on the largest non-zero part, else the smallest.
        _selected = State(initialValue: split.firstIndex { $0 > 0 } ?? max(units.units.count - 1, 0))
    }

    /// Splits a base-unit value across the parts, largest first: whole numbers
    /// for all but the smallest, which takes the remainder.
    static func split(_ value: Double, into units: GlassCompoundUnits) -> [Double] {
        var remaining = max(0, value)
        return units.units.enumerated().map { index, unit in
            if index == units.units.count - 1 {
                let last = remaining / unit.factor
                return (last * 100).rounded() / 100
            }
            let whole = (remaining / unit.factor).rounded(.down)
            remaining -= whole * unit.factor
            return whole
        }
    }

    private var total: Double {
        zip(parts, units.units).reduce(0) { $0 + $1.0 * $1.1.factor }
    }

    private var unit: GlassCompoundUnit { units.units[selected] }

    private var partBinding: Binding<Double> {
        Binding(get: { parts[selected] }, set: { parts[selected] = $0 })
    }

    public var body: some View {
        GlassNumPad(
            value: partBinding,
            configuration: .init(
                accentColor: accentColor,
                showCapsule: false,
                showsCalculator: false,
                maxDigitCount: unit.maxDigits,
                additionalContentHeight: Self.partRowHeight + headerHeight,
                unitSelectable: false,
                showsAuxiliaryButton: false,
                displaySuffix: unit.name
            )
        ) {
            EmptyView()
        } pickerContent: {
            EmptyView()
        } actionButton: {
            actionButton()
        } auxiliaryButton: {
            EmptyView()
        } header: {
            VStack(spacing: 0) {
                header()
                partRow
            }
        } onAction: {
            value = total
            onAction()
        }
        // One pad for every part: naming the part lets it roll the number over
        // to the new part's value (and start fresh) instead of rebuilding.
        .environment(\.glassNumPadFieldID, selected)
        .onChange(of: total) { _, newTotal in value = newTotal }
    }

    /// The part chips; the selected one is the part the keys type into. The
    /// row reads as the whole value ("1m 30s").
    private var partRow: some View {
        HStack(spacing: 8) {
            ForEach(Array(units.units.enumerated()), id: \.offset) { index, part in
                let isSelected = index == selected
                Button {
                    // One transaction: the highlight slides, the number rolls
                    // and the unit changes together.
                    withAnimation(.snappy(duration: 0.3)) { selected = index }
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(Self.format(parts[index]))
                            .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
                            .contentTransition(.numericText())
                        Text(part.suffix)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 64)
                    .padding(.vertical, 8)
                    .background {
                        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
                        ZStack {
                            shape.fill(Color.primary.opacity(0.08))
                            // The selection is ONE shape that slides between chips.
                            if isSelected {
                                shape.fill(accentColor.opacity(0.35))
                                    .overlay(shape.strokeBorder(accentColor, lineWidth: 1.5))
                                    .matchedGeometryEffect(id: "selection", in: selection)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
        .frame(height: Self.partRowHeight)
    }

    private static func format(_ value: Double) -> String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }

    /// The sheet height that fits the pad, its part row and a header of
    /// `headerHeight` — for callers presenting it in their own sheet.
    public static func sheetHeight(headerHeight: CGFloat = 0) -> CGFloat {
        GlassNumPad<EmptyView, EmptyView, EmptyView, EmptyView, EmptyView>
            .Configuration(showCapsule: false, additionalContentHeight: partRowHeight + headerHeight)
            .resolvedSheetHeight
    }
}

// MARK: - Sheet

public extension View {
    /// Presents a `GlassCompoundPad` in a detented sheet, as `.glassNumPad`
    /// does for the plain pad.
    func glassCompoundPad<A: View, H: View>(
        isPresented: Binding<Bool>,
        value: Binding<Double>,
        units: GlassCompoundUnits,
        accentColor: Color = .blue,
        headerHeight: CGFloat = 0,
        @ViewBuilder actionButton: @escaping () -> A,
        @ViewBuilder header: @escaping () -> H,
        onAction: @escaping () -> Void = {}
    ) -> some View {
        sheet(isPresented: isPresented) {
            GlassCompoundPad(
                value: value,
                units: units,
                accentColor: accentColor,
                headerHeight: headerHeight,
                actionButton: actionButton,
                header: header,
                onAction: onAction
            )
            .presentationDetents([.height(GlassCompoundPad<A, H>.sheetHeight(headerHeight: headerHeight))])
            .presentationDragIndicator(.visible)
        }
    }
}
