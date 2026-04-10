import SwiftUI

/// A glass-style numeric keypad with an integrated calculator mode.
///
/// Present it in a sheet via the `.glassNumPad()` view modifier, or embed directly.
///
/// ```swift
/// .glassNumPad(isPresented: $show, value: $amount) {
///     Text("kg")          // capsule label
/// } pickerContent: {
///     WeightUnitPicker()  // replaces numpad when capsule is tapped
/// } actionButton: {
///     Image(systemName: "checkmark")
/// }
/// ```
public struct GlassNumPad<
    CapsuleLabel: View,
    PickerContent: View,
    ActionContent: View
>: View {

    // MARK: - Public

    @Binding var value: Double
    let configuration: Configuration
    let onAction: () -> Void

    let capsuleLabel: CapsuleLabel
    let pickerContent: PickerContent
    let actionContent: ActionContent

    // MARK: - State

    enum Mode: Equatable { case numpad, calculator, picker }

    @State private var mode: Mode = .numpad
    @State private var displayString: String = "0"
    @State private var isSelectAll = true
    @State private var calculator = CalculatorEngine()
    @State private var isCapsuleExpanded = false

    // MARK: - Full initializer

    public init(
        value: Binding<Double>,
        configuration: Configuration = .init(),
        @ViewBuilder capsuleLabel: () -> CapsuleLabel,
        @ViewBuilder pickerContent: () -> PickerContent,
        @ViewBuilder actionButton: () -> ActionContent,
        onAction: @escaping () -> Void = {}
    ) {
        self._value = value
        self.configuration = configuration
        self.capsuleLabel = capsuleLabel()
        self.pickerContent = pickerContent()
        self.actionContent = actionButton()
        self.onAction = onAction
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            // Number display
            NumberDisplay(
                text: currentDisplay,
                isCalculatorMode: mode == .calculator
            )
            .frame(height: mode == .calculator ? 64 : 80)
            .animation(.interactiveSpring(duration: 0.35), value: mode)

            // Capsule (hidden in calculator mode or when no label provided)
            if mode != .calculator, configuration.showCapsule,
               !(CapsuleLabel.self == EmptyView.self) {
                CapsuleBar(
                    isExpanded: $isCapsuleExpanded,
                    accentColor: configuration.accentColor,
                    label: { capsuleLabel }
                )
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer().frame(height: 12)

            // Switchable content area
            Group {
                switch mode {
                case .numpad:     numPadGrid
                case .calculator: calculatorGrid
                case .picker:
                    ScrollView {
                        pickerContent.padding(.top, 4)
                    }
                }
            }
            .transition(.opacity)
        }
        .padding(.horizontal, configuration.horizontalPadding)
        .padding(.bottom, 16)
        .onAppear {
            displayString = CalculatorEngine.format(value)
            isSelectAll = true
        }
        .onChange(of: isCapsuleExpanded) { _, expanded in
            withAnimation(.interactiveSpring(duration: 0.35)) {
                mode = expanded ? .picker : .numpad
            }
        }
    }

    private var currentDisplay: String {
        mode == .calculator ? calculator.display : displayString
    }

    // MARK: - Numpad grid

    private var numPadGrid: some View {
        let s = configuration.buttonSpacing
        return Grid(horizontalSpacing: s, verticalSpacing: s) {
            GridRow {
                digit(7); digit(8); digit(9)
                btn(.standard, action: deleteAction) {
                    Image(systemName: "delete.backward")
                }
            }
            GridRow {
                digit(4); digit(5); digit(6)
                btn(.clear, action: clearAction) { Text("C") }
            }
            GridRow {
                digit(1); digit(2); digit(3)
                btn(.standard, action: decimalAction) { Text(".") }
            }
            GridRow {
                btn(.standard, action: { digitInput(0) }) { Text("0") }
                    .gridCellColumns(2)
                btn(.standard, action: enterCalculatorMode) {
                    Image(systemName: "plus.forwardslash.minus")
                }
                actionButtonCell
            }
        }
    }

    // MARK: - Calculator grid

    private var calculatorGrid: some View {
        let s = configuration.buttonSpacing
        return Grid(horizontalSpacing: s, verticalSpacing: s) {
            GridRow {
                btn(.standard, action: calcDelete) {
                    Image(systemName: "delete.backward")
                }
                .gridCellColumns(2)
                btn(.clear, action: calcClear) { Text("C") }
                btn(.operator, action: { calcOp(.divide) }) {
                    Image(systemName: "divide")
                }
            }
            GridRow {
                cDigit(7); cDigit(8); cDigit(9)
                btn(.operator, action: { calcOp(.multiply) }) {
                    Image(systemName: "multiply")
                }
            }
            GridRow {
                cDigit(4); cDigit(5); cDigit(6)
                btn(.operator, action: { calcOp(.subtract) }) {
                    Image(systemName: "minus")
                }
            }
            GridRow {
                cDigit(1); cDigit(2); cDigit(3)
                btn(.operator, action: { calcOp(.add) }) {
                    Image(systemName: "plus")
                }
            }
            GridRow {
                cDigit(0)
                btn(.standard, action: calcDecimal) { Text(".") }
                btn(.standard, action: exitCalculatorMode) {
                    Image(systemName: "number")
                }
                btn(.prominent, action: evaluateExpression) {
                    Image(systemName: "equal")
                }
            }
        }
    }

    // MARK: - Action button cell

    @ViewBuilder
    private var actionButtonCell: some View {
        let kind: ButtonKind = {
            switch configuration.actionButtonStyle {
            case .dashed:    return .dashed
            case .standard:  return .standard
            case .prominent: return .prominent
            }
        }()
        if ActionContent.self == EmptyView.self {
            btn(kind, action: {}) { Color.clear }
                .hidden()
        } else {
            btn(kind, action: onAction) { actionContent }
        }
    }

    // MARK: - Button helpers

    private func btn<L: View>(
        _ kind: ButtonKind,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> L
    ) -> some View {
        NumPadButtonView(
            kind: kind,
            accentColor: configuration.accentColor,
            clearColor: configuration.clearColor,
            cornerRadius: configuration.buttonCornerRadius,
            action: action,
            label: label
        )
    }

    private func digit(_ d: Int) -> some View {
        btn(.standard, action: { digitInput(d) }) { Text("\(d)") }
    }

    private func cDigit(_ d: Int) -> some View {
        btn(.standard, action: { calcDigitInput(d) }) { Text("\(d)") }
    }

    // MARK: - Numpad actions

    private func digitInput(_ digit: Int) {
        if isSelectAll {
            displayString = digit == 0 ? "0" : "\(digit)"
            isSelectAll = false
        } else if displayString == "0" {
            if digit != 0 { displayString = "\(digit)" }
        } else {
            displayString += "\(digit)"
        }
        syncValue()
    }

    private func decimalAction() {
        if isSelectAll {
            displayString = "0."
            isSelectAll = false
        } else if !displayString.contains(".") {
            displayString += "."
        }
    }

    private func deleteAction() {
        if isSelectAll {
            displayString = "0"
            isSelectAll = false
        } else if displayString.count > 1 {
            displayString.removeLast()
        } else {
            displayString = "0"
        }
        syncValue()
    }

    private func clearAction() {
        displayString = "0"
        isSelectAll = true
        syncValue()
    }

    private func syncValue() {
        value = Double(displayString) ?? 0
    }

    // MARK: - Calculator actions

    private func enterCalculatorMode() {
        calculator = CalculatorEngine(initialValue: Double(displayString) ?? 0)
        withAnimation(.interactiveSpring(duration: 0.35)) {
            mode = .calculator
        }
    }

    private func exitCalculatorMode() {
        let result = calculator.currentValue
        displayString = CalculatorEngine.format(result)
        value = result
        isSelectAll = true
        withAnimation(.interactiveSpring(duration: 0.35)) {
            mode = .numpad
        }
    }

    private func calcDigitInput(_ d: Int) {
        calculator.inputDigit(d)
    }

    private func calcDecimal() {
        calculator.inputDecimal()
    }

    private func calcDelete() {
        calculator.delete()
    }

    private func calcClear() {
        calculator.clear()
    }

    private func calcOp(_ op: CalculatorEngine.Operator) {
        calculator.inputOperator(op)
    }

    private func evaluateExpression() {
        let result = calculator.evaluate()
        value = result
    }
}

// MARK: - Convenience: no capsule

public extension GlassNumPad where CapsuleLabel == EmptyView, PickerContent == EmptyView {
    init(
        value: Binding<Double>,
        configuration: Configuration = .init(),
        @ViewBuilder actionButton: () -> ActionContent,
        onAction: @escaping () -> Void = {}
    ) {
        self.init(
            value: value,
            configuration: .init(
                accentColor: configuration.accentColor,
                clearColor: configuration.clearColor,
                sheetHeight: configuration.sheetHeight,
                buttonCornerRadius: configuration.buttonCornerRadius,
                buttonSpacing: configuration.buttonSpacing,
                horizontalPadding: configuration.horizontalPadding,
                actionButtonStyle: configuration.actionButtonStyle,
                showCapsule: false
            ),
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: actionButton,
            onAction: onAction
        )
    }
}

// MARK: - Convenience: no action button

public extension GlassNumPad where ActionContent == EmptyView {
    init(
        value: Binding<Double>,
        configuration: Configuration = .init(),
        @ViewBuilder capsuleLabel: () -> CapsuleLabel,
        @ViewBuilder pickerContent: () -> PickerContent
    ) {
        self.init(
            value: value,
            configuration: configuration,
            capsuleLabel: capsuleLabel,
            pickerContent: pickerContent,
            actionButton: { EmptyView() },
            onAction: {}
        )
    }
}

// MARK: - Convenience: bare

public extension GlassNumPad
where CapsuleLabel == EmptyView, PickerContent == EmptyView, ActionContent == EmptyView {
    init(
        value: Binding<Double>,
        configuration: Configuration = .init()
    ) {
        self.init(
            value: value,
            configuration: .init(
                accentColor: configuration.accentColor,
                clearColor: configuration.clearColor,
                sheetHeight: configuration.sheetHeight,
                buttonCornerRadius: configuration.buttonCornerRadius,
                buttonSpacing: configuration.buttonSpacing,
                horizontalPadding: configuration.horizontalPadding,
                actionButtonStyle: configuration.actionButtonStyle,
                showCapsule: false
            ),
            capsuleLabel: { EmptyView() },
            pickerContent: { EmptyView() },
            actionButton: { EmptyView() },
            onAction: {}
        )
    }
}
