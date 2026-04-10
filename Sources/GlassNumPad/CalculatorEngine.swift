import Foundation

/// A simple four-function calculator that evaluates expressions left-to-right.
struct CalculatorEngine {

    enum Operator: String {
        case add = "+"
        case subtract = "−"
        case multiply = "×"
        case divide = "÷"
    }

    private(set) var display: String = "0"
    private var accumulator: Double = 0
    private var pendingOp: Operator?
    private var isTyping = false

    /// Initialize with a starting value (carried over from the numpad).
    init(initialValue: Double = 0) {
        accumulator = initialValue
        display = Self.format(initialValue)
    }

    // MARK: - Input

    mutating func inputDigit(_ digit: Int) {
        if isTyping {
            if display == "0" && digit == 0 { return }
            if display == "0" {
                display = "\(digit)"
            } else {
                display += "\(digit)"
            }
        } else {
            display = "\(digit)"
            isTyping = true
        }
    }

    mutating func inputDecimal() {
        if !isTyping {
            display = "0."
            isTyping = true
        } else if !display.contains(".") {
            display += "."
        }
    }

    mutating func inputOperator(_ op: Operator) {
        if isTyping {
            performPending()
        }
        pendingOp = op
        isTyping = false
        // display keeps showing the accumulated result — does NOT clear
    }

    /// Evaluate the pending expression and return the result.
    @discardableResult
    mutating func evaluate() -> Double {
        if isTyping {
            performPending()
        }
        pendingOp = nil
        isTyping = false
        return accumulator
    }

    mutating func clear() {
        accumulator = 0
        pendingOp = nil
        display = "0"
        isTyping = false
    }

    mutating func delete() {
        guard isTyping else { return }
        if display.count > 1 {
            display.removeLast()
        } else {
            display = "0"
        }
    }

    var currentValue: Double {
        if isTyping {
            return Double(display) ?? 0
        }
        return accumulator
    }

    // MARK: - Private

    private mutating func performPending() {
        let inputValue = Double(display) ?? 0
        var wasDivision = false
        if let op = pendingOp {
            switch op {
            case .add:      accumulator += inputValue
            case .subtract: accumulator -= inputValue
            case .multiply: accumulator *= inputValue
            case .divide:
                accumulator = inputValue != 0 ? accumulator / inputValue : 0
                wasDivision = true
            }
        } else {
            accumulator = inputValue
        }
        // Division results always show 2 decimal places
        display = wasDivision
            ? Self.formatDivision(accumulator)
            : Self.format(accumulator)
    }

    static func format(_ value: Double) -> String {
        if value == .infinity || value.isNaN { return "0" }
        if value == floor(value) && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        let s = String(format: "%.10f", value)
        var trimmed = s
        while trimmed.hasSuffix("0") { trimmed.removeLast() }
        if trimmed.hasSuffix(".") { trimmed.removeLast() }
        return trimmed
    }

    /// Always 2 decimal places for division results.
    static func formatDivision(_ value: Double) -> String {
        if value == .infinity || value.isNaN { return "0" }
        return String(format: "%.2f", value)
    }
}
