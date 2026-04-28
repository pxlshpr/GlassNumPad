import SwiftUI

public struct GlassNumPad<
    CapsuleLabel: View,
    PickerContent: View,
    ActionContent: View,
    AuxiliaryContent: View,
    Header: View
>: View {

    @Environment(\.colorScheme) private var colorScheme

    @Binding var value: Double
    let configuration: Configuration
    let onAction: () -> Void
    let onAuxiliaryAction: () -> Void

    let capsuleLabel: CapsuleLabel
    let pickerContent: PickerContent
    let actionContent: ActionContent
    let auxiliaryContent: AuxiliaryContent
    let header: Header

    enum Mode: Equatable { case numpad, calculator, picker }

    @State private var mode: Mode = .numpad
    @State private var displayString: String = "0"
    @State private var isSelectAll = true
    @State private var calculator = CalculatorEngine()
    @State private var isCapsuleExpanded = false

    /// Foreground tint — white on dark, near-black on light.
    private var fg: Color { colorScheme == .dark ? .white : Color(.label) }
    /// Subtle foreground for secondary elements.
    private var fgSoft: Color { fg.opacity(colorScheme == .dark ? 0.7 : 0.5) }
    /// Button fill color.
    private var btnFill: Color { colorScheme == .dark ? .white.opacity(0.08) : Color(.label).opacity(0.06) }
    /// Button border color.
    private var btnBorder: Color { colorScheme == .dark ? .white.opacity(0.1) : Color(.label).opacity(0.08) }

    // MARK: - Sizes

    private var buttonSize: CGFloat {
        Configuration.computeButtonSize(spacing: configuration.buttonSpacing)
    }
    private var gridWidth: CGFloat {
        buttonSize * 4 + configuration.buttonSpacing * 3
    }
    private var headerHeight: CGFloat { buttonSize + 70 }

    private var isCalc: Bool { mode == .calculator }

    // MARK: - Init

    public init(
        value: Binding<Double>,
        configuration: Configuration = .init(),
        @ViewBuilder capsuleLabel: () -> CapsuleLabel,
        @ViewBuilder pickerContent: () -> PickerContent,
        @ViewBuilder actionButton: () -> ActionContent,
        @ViewBuilder auxiliaryButton: () -> AuxiliaryContent,
        @ViewBuilder header: () -> Header,
        onAction: @escaping () -> Void = {},
        onAuxiliaryAction: @escaping () -> Void = {}
    ) {
        self._value = value
        self.configuration = configuration
        self.capsuleLabel = capsuleLabel()
        self.pickerContent = pickerContent()
        self.actionContent = actionButton()
        self.auxiliaryContent = auxiliaryButton()
        self.header = header()
        self.onAction = onAction
        self.onAuxiliaryAction = onAuxiliaryAction
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            if !(Header.self == EmptyView.self) {
                // Constrain the header to the digit-grid width so callers can
                // style a container (e.g. rounded material rect) that visually
                // aligns with the keypad button columns.
                header
                    .frame(width: gridWidth)
                    .padding(.bottom, 8)
            }

            headerZone
                .frame(height: headerHeight)
                .clipped()
                .padding(.horizontal, 20)

            Spacer().frame(height: configuration.buttonSpacing)

            if mode == .picker {
                ScrollView {
                    pickerContent
                        .environment(\.dismissGlassNumPadPicker, {
                            withAnimation(.interactiveSpring(duration: 0.35)) {
                                isCapsuleExpanded = false
                            }
                        })
                        .padding(.top, 4)
                        .padding(.horizontal, 20)
                }
                .scrollBounceBehavior(.basedOnSize)
                .frame(height: buttonSize * 4 + configuration.buttonSpacing * 3)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            } else {
                digitAndBottomRows
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .onAppear {
            // Initial sync — bypass any inherited animation context (e.g. the sheet's
            // present spring) so the readout snaps to its starting value instead of
            // sliding via numericText.
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) {
                displayString = CalculatorEngine.format(value)
                isSelectAll = true
            }
        }
        .onChange(of: value) { _, newValue in
            // External value change (e.g. caller opened the pad on a different item):
            // resync the display. Also silenced so re-presentation doesn't show a
            // numericText scrub from the previous value to the new one. Internal
            // typing produces a `value` that already matches the formatted display,
            // so this branch is skipped for internal edits and their own animation
            // (NumberDisplay's contentTransition) still applies.
            let formatted = CalculatorEngine.format(newValue)
            if formatted != displayString {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    displayString = formatted
                    isSelectAll = true
                }
            }
        }
        .onChange(of: isCapsuleExpanded) { _, expanded in
            withAnimation(.interactiveSpring(duration: 0.35)) {
                mode = expanded ? .picker : .numpad
            }
        }
    }

    private var currentDisplay: String {
        isCalc ? calculator.expression : displayString
    }

    // MARK: - Header zone (fixed height)

    private var headerZone: some View {
        VStack(spacing: 0) {
            NumberDisplay(text: currentDisplay, isCalculatorMode: isCalc)
                .frame(maxHeight: .infinity)

            if isCalc {
                Spacer().frame(height: 10)
                operatorRow.frame(height: buttonSize)
            } else if configuration.showCapsule, !(CapsuleLabel.self == EmptyView.self) {
                CapsuleBar(
                    isExpanded: $isCapsuleExpanded,
                    accentColor: configuration.accentColor,
                    label: { capsuleLabel }
                )
            }
        }
        .animation(.interactiveSpring(duration: 0.35), value: mode)
    }

    // MARK: - Operator row (slides in from top)

    private var operatorRow: some View {
        let s = configuration.buttonSpacing
        let sz = buttonSize
        let cr = configuration.buttonCornerRadius
        return HStack(spacing: s) {
            // ⌫ — smaller icon (22pt)
            Button { calcDelete() } label: {
                Image(systemName: "delete.backward")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(fg)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(standardBg(cr))
            }
            .buttonStyle(NumPadPressStyle())
            .frame(width: sz * 2 + s, height: sz)

            // C — smaller font (24pt)
            Button { calcClear() } label: {
                Text("C")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(configuration.clearColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(standardBg(cr))
            }
            .buttonStyle(NumPadPressStyle())
            .frame(width: sz, height: sz)

            // ÷ — smaller icon (22pt)
            Button { calcOp(.divide) } label: {
                Image(systemName: "divide")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(configuration.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(standardBg(cr))
            }
            .buttonStyle(NumPadPressStyle())
            .frame(width: sz, height: sz)
        }
        .frame(width: gridWidth)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Digit rows + bottom (always same Y)

    private var digitAndBottomRows: some View {
        let s = configuration.buttonSpacing
        let sz = buttonSize
        return VStack(spacing: s) {
            HStack(spacing: s) { digit(7, sz); digit(8, sz); digit(9, sz); rightButton(row: 0, size: sz) }
            HStack(spacing: s) { digit(4, sz); digit(5, sz); digit(6, sz); rightButton(row: 1, size: sz) }
            HStack(spacing: s) { digit(1, sz); digit(2, sz); digit(3, sz); rightButton(row: 2, size: sz) }
            bottomRow
        }
        .frame(width: gridWidth)
    }

    // MARK: - Right column: persistent background, content cross-fades

    private func rightButton(row: Int, size: CGFloat) -> some View {
        let cr = configuration.buttonCornerRadius

        return Button {
            rightButtonAction(row: row)
        } label: {
            ZStack {
                // Numpad labels
                Group {
                    switch row {
                    case 0:
                        Image(systemName: "delete.backward")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(fg)
                    case 1:
                        Text("C")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(configuration.clearColor)
                    default:
                        Text(".")
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundStyle(fg)
                    }
                }
                .opacity(isCalc ? 0 : 1)

                // Calculator labels
                Group {
                    switch row {
                    case 0:
                        Image(systemName: "multiply")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(configuration.accentColor)
                    case 1:
                        Image(systemName: "minus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(configuration.accentColor)
                    default:
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(configuration.accentColor)
                    }
                }
                .opacity(isCalc ? 1 : 0)
            }
            .frame(width: size, height: size)
            .background(standardBg(cr))
        }
        .buttonStyle(NumPadPressStyle())
        .animation(.easeInOut(duration: 0.3), value: mode)
    }

    private func rightButtonAction(row: Int) {
        if isCalc {
            switch row {
            case 0:  calcOp(.multiply)
            case 1:  calcOp(.subtract)
            default: calcOp(.add)
            }
        } else {
            switch row {
            case 0:  deleteAction()
            case 1:  clearAction()
            default: decimalAction()
            }
        }
    }

    // MARK: - Bottom row: 0 width animates, content cross-fades

    private var bottomRow: some View {
        let s = configuration.buttonSpacing
        let sz = buttonSize
        let cr = configuration.buttonCornerRadius

        // Whether the slot between `0` and the action button is occupied.
        // - showsCalculator → +/− toggle (or # in calc mode)
        // - !showsCalculator + non-empty AuxiliaryContent → caller-provided button
        // - Neither → slot collapses; `0` widens to fill it
        let hasAux = !(AuxiliaryContent.self == EmptyView.self)
        let showsAuxSlot = configuration.showsCalculator || hasAux

        // 0 button width:
        // - calc mode: single (period appears in the slot to its right)
        // - shows aux slot: double-wide
        // - no aux slot: triple-wide (fills the missing slot)
        let zeroWidth: CGFloat = isCalc ? sz : (showsAuxSlot ? sz * 2 + s : sz * 3 + s * 2)

        return HStack(spacing: s) {
            // ── 0 button: width animates between single, double, triple ──
            Button { handleDigit(0) } label: {
                Text("0")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(fg)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(standardBg(cr))
            }
            .buttonStyle(NumPadPressStyle())
            .frame(width: zeroWidth, height: sz)

            // ── Period: slides in from behind the 0 ──
            if isCalc {
                btn(.standard, sz, action: { calcDecimal() }) { Text(".") }
                    .transition(.asymmetric(
                        insertion: .push(from: .leading),
                        removal: .push(from: .trailing)
                    ))
            }

            // ── Aux slot: +/− (calc on), # (in calc mode), or caller-provided button ──
            if showsAuxSlot {
                if configuration.showsCalculator {
                    Button {
                        if isCalc { exitCalculatorMode() } else { enterCalculatorMode() }
                    } label: {
                        ZStack {
                            Image(systemName: "plus.forwardslash.minus")
                                .font(.system(size: 22, weight: .medium))
                                .opacity(isCalc ? 0 : 1)
                            Image(systemName: "number")
                                .font(.system(size: 22, weight: .medium))
                                .opacity(isCalc ? 1 : 0)
                        }
                        .foregroundStyle(fg)
                        .frame(width: sz, height: sz)
                        .background(standardBg(cr))
                    }
                    .buttonStyle(NumPadPressStyle())
                } else {
                    Button {
                        onAuxiliaryAction()
                    } label: {
                        auxiliaryContent
                            .frame(width: sz, height: sz)
                            .background(standardBg(cr))
                    }
                    .buttonStyle(NumPadPressStyle())
                }
            }

            // ── Action or =: persistent button, content cross-fades ──
            actionOrEquals(sz, cr)
        }
        .animation(.interactiveSpring(duration: 0.35), value: mode)
    }

    @ViewBuilder
    private func actionOrEquals(_ sz: CGFloat, _ cr: CGFloat) -> some View {
        let isProminent = configuration.actionButtonStyle == .prominent && !isCalc
        let isDashed = configuration.actionButtonStyle == .dashed && !isCalc

        Button {
            if isCalc {
                evaluateExpression()
            } else {
                onAction()
            }
        } label: {
            ZStack {
                actionContent.opacity(isCalc ? 0 : 1)
                Image(systemName: "equal")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(configuration.accentColor)
                    .opacity(isCalc ? 1 : 0)
            }
            .font(.system(size: 30, weight: .medium, design: .rounded))
            .foregroundStyle(isProminent ? .white : (isDashed ? fg.opacity(0.4) : fg))
            .frame(width: sz, height: sz)
            .background(
                ZStack {
                    // Subtle accent highlight for = in calculator mode
                    RoundedRectangle(cornerRadius: cr, style: .continuous)
                        .fill(configuration.accentColor.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: cr, style: .continuous)
                                .strokeBorder(configuration.accentColor.opacity(0.3), lineWidth: 1)
                        )
                        .opacity(isCalc ? 1 : 0)
                    // Standard fill (non-calc, standard style)
                    standardBg(cr)
                        .opacity(isCalc ? 0 : (!isProminent && !isDashed ? 1 : 0))
                    // Prominent fill
                    RoundedRectangle(cornerRadius: cr, style: .continuous)
                        .fill(configuration.accentColor.gradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: cr, style: .continuous)
                                .strokeBorder(fg.opacity(0.12), lineWidth: 1)
                        )
                        .opacity(isProminent ? 1 : 0)
                    // Dashed
                    RoundedRectangle(cornerRadius: cr, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .foregroundStyle(fg.opacity(0.2))
                        .opacity(isDashed ? 1 : 0)
                }
            )
        }
        .buttonStyle(NumPadPressStyle())
        .animation(.easeInOut(duration: 0.3), value: mode)
    }

    // MARK: - Shared button background

    private func standardBg(_ cr: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cr, style: .continuous)
            .fill(btnFill)
            .overlay(
                RoundedRectangle(cornerRadius: cr, style: .continuous)
                    .strokeBorder(btnBorder, lineWidth: 1)
            )
    }

    // MARK: - Button helpers

    private func btn<L: View>(
        _ kind: ButtonKind, _ size: CGFloat,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> L
    ) -> some View {
        NumPadButtonView(
            kind: kind, accentColor: configuration.accentColor,
            clearColor: configuration.clearColor,
            cornerRadius: configuration.buttonCornerRadius,
            action: action, label: label
        ).frame(width: size, height: size)
    }

    private func btn<L: View>(
        _ kind: ButtonKind, _ size: CGSize,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> L
    ) -> some View {
        NumPadButtonView(
            kind: kind, accentColor: configuration.accentColor,
            clearColor: configuration.clearColor,
            cornerRadius: configuration.buttonCornerRadius,
            action: action, label: label
        ).frame(width: size.width, height: size.height)
    }

    private func digit(_ d: Int, _ size: CGFloat) -> some View {
        btn(.standard, size, action: { handleDigit(d) }) { Text("\(d)") }
    }

    private func handleDigit(_ d: Int) {
        if isCalc { calculator.inputDigit(d) } else { digitInput(d) }
    }

    // MARK: - Numpad actions

    private func digitInput(_ digit: Int) {
        if isSelectAll {
            displayString = digit == 0 ? "0" : "\(digit)"
            isSelectAll = false
        } else if displayString == "0" {
            if digit != 0 { displayString = "\(digit)" }
        } else {
            guard CalculatorEngine.digitCount(in: displayString) < configuration.maxDigitCount else { return }
            displayString += "\(digit)"
        }
        syncValue()
    }

    private func decimalAction() {
        if isSelectAll { displayString = "0."; isSelectAll = false }
        else if !displayString.contains(".") { displayString += "." }
    }

    private func deleteAction() {
        if isSelectAll { displayString = "0"; isSelectAll = false }
        else if displayString.count > 1 { displayString.removeLast() }
        else { displayString = "0" }
        syncValue()
    }

    private func clearAction() {
        displayString = "0"; isSelectAll = true; syncValue()
    }

    private func syncValue() { value = Double(displayString) ?? 0 }

    // MARK: - Calculator actions

    private func enterCalculatorMode() {
        calculator = CalculatorEngine(
            initialValue: Double(displayString) ?? 0,
            maxDigitCount: configuration.maxDigitCount
        )
        withAnimation(.interactiveSpring(duration: 0.35)) { mode = .calculator }
    }

    private func exitCalculatorMode() {
        let result = calculator.currentValue
        displayString = CalculatorEngine.format(result)
        value = result; isSelectAll = true
        withAnimation(.interactiveSpring(duration: 0.35)) { mode = .numpad }
    }

    private func calcDecimal() { calculator.inputDecimal() }
    private func calcDelete()  { calculator.delete() }
    private func calcClear()   { calculator.clear() }
    private func calcOp(_ op: CalculatorEngine.Operator) { calculator.inputOperator(op) }
    private func evaluateExpression() { value = calculator.evaluate() }
}

// MARK: - Convenience initializers

public extension GlassNumPad where AuxiliaryContent == EmptyView, Header == EmptyView {
    /// Standard initializer — no auxiliary button, no header (matches pre-aux callers).
    init(
        value: Binding<Double>,
        configuration: Configuration = .init(),
        @ViewBuilder capsuleLabel: () -> CapsuleLabel,
        @ViewBuilder pickerContent: () -> PickerContent,
        @ViewBuilder actionButton: () -> ActionContent,
        onAction: @escaping () -> Void = {}
    ) {
        self.init(
            value: value, configuration: configuration,
            capsuleLabel: capsuleLabel, pickerContent: pickerContent,
            actionButton: actionButton, auxiliaryButton: { EmptyView() },
            header: { EmptyView() },
            onAction: onAction, onAuxiliaryAction: {}
        )
    }
}

public extension GlassNumPad
where CapsuleLabel == EmptyView, PickerContent == EmptyView, AuxiliaryContent == EmptyView, Header == EmptyView {
    init(value: Binding<Double>, configuration: Configuration = .init(),
         @ViewBuilder actionButton: () -> ActionContent, onAction: @escaping () -> Void = {}) {
        self.init(value: value,
                  configuration: .init(accentColor: configuration.accentColor, clearColor: configuration.clearColor,
                                       sheetHeight: configuration.sheetHeight, buttonCornerRadius: configuration.buttonCornerRadius,
                                       buttonSpacing: configuration.buttonSpacing, actionButtonStyle: configuration.actionButtonStyle,
                                       showCapsule: false, showsCalculator: configuration.showsCalculator,
                                       maxDigitCount: configuration.maxDigitCount),
                  capsuleLabel: { EmptyView() }, pickerContent: { EmptyView() },
                  actionButton: actionButton, auxiliaryButton: { EmptyView() },
                  header: { EmptyView() },
                  onAction: onAction, onAuxiliaryAction: {})
    }
}

public extension GlassNumPad where ActionContent == EmptyView, AuxiliaryContent == EmptyView, Header == EmptyView {
    init(value: Binding<Double>, configuration: Configuration = .init(),
         @ViewBuilder capsuleLabel: () -> CapsuleLabel, @ViewBuilder pickerContent: () -> PickerContent) {
        self.init(value: value, configuration: configuration,
                  capsuleLabel: capsuleLabel, pickerContent: pickerContent,
                  actionButton: { EmptyView() }, auxiliaryButton: { EmptyView() },
                  header: { EmptyView() },
                  onAction: {}, onAuxiliaryAction: {})
    }
}

public extension GlassNumPad
where CapsuleLabel == EmptyView, PickerContent == EmptyView, ActionContent == EmptyView, AuxiliaryContent == EmptyView, Header == EmptyView {
    init(value: Binding<Double>, configuration: Configuration = .init()) {
        self.init(value: value,
                  configuration: .init(accentColor: configuration.accentColor, clearColor: configuration.clearColor,
                                       sheetHeight: configuration.sheetHeight, buttonCornerRadius: configuration.buttonCornerRadius,
                                       buttonSpacing: configuration.buttonSpacing, actionButtonStyle: configuration.actionButtonStyle,
                                       showCapsule: false, showsCalculator: configuration.showsCalculator,
                                       maxDigitCount: configuration.maxDigitCount),
                  capsuleLabel: { EmptyView() }, pickerContent: { EmptyView() },
                  actionButton: { EmptyView() }, auxiliaryButton: { EmptyView() },
                  header: { EmptyView() },
                  onAction: {}, onAuxiliaryAction: {})
    }
}
