import Foundation

/// A simple four-function calculator that builds up a multi-term expression
/// and only evaluates when `=` is pressed (left-to-right, no precedence).
struct CalculatorEngine {

    enum Operator: String {
        case add = "+"
        case subtract = "−"
        case multiply = "×"
        case divide = "÷"
    }

    /// The raw operand being typed.
    private(set) var display: String = "0"

    /// The full expression string shown to the user (e.g. "50+3+7").
    private(set) var expression: String = "0"

    /// Committed terms in the expression.
    private var terms: [Double] = []
    /// Operators between terms. Count is always `terms.count` or `terms.count - 1`.
    private var ops: [Operator] = []
    private var isTyping = false

    /// Initialize with a starting value (carried over from the numpad).
    init(initialValue: Double = 0) {
        let formatted = Self.format(initialValue)
        display = formatted
        expression = formatted
        terms = [initialValue]
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
        rebuildExpression()
    }

    mutating func inputDecimal() {
        if !isTyping {
            display = "0."
            isTyping = true
        } else if !display.contains(".") {
            display += "."
        }
        rebuildExpression()
    }

    mutating func inputOperator(_ op: Operator) {
        if isTyping {
            commitCurrentInput()
            ops.append(op)
        } else if ops.count == terms.count {
            // User changed operator without typing a number — replace last op
            ops[ops.count - 1] = op
        } else {
            // After evaluate or init — just add the operator
            ops.append(op)
        }
        isTyping = false
        rebuildExpression()
    }

    /// Evaluate the full expression and return the result.
    @discardableResult
    mutating func evaluate() -> Double {
        if isTyping {
            commitCurrentInput()
        }

        let result = Self.evaluateAll(terms: terms, ops: ops)

        terms = [result]
        ops = []
        isTyping = false
        display = Self.format(result)
        expression = Self.format(result)
        return result
    }

    mutating func clear() {
        terms = [0]
        ops = []
        display = "0"
        expression = "0"
        isTyping = false
    }

    mutating func delete() {
        guard isTyping else { return }
        if display.count > 1 {
            display.removeLast()
        } else {
            display = "0"
        }
        rebuildExpression()
    }

    /// The value that would result if `=` were pressed right now.
    var currentValue: Double {
        var allTerms = terms
        if isTyping {
            let value = Double(display) ?? 0
            if ops.count >= allTerms.count {
                allTerms.append(value)
            } else {
                allTerms[allTerms.count - 1] = value
            }
        }
        return Self.evaluateAll(terms: allTerms, ops: ops)
    }

    // MARK: - Private

    /// Commit the current display as a term.
    private mutating func commitCurrentInput() {
        let value = Double(display) ?? 0
        if ops.count < terms.count {
            // User typed over the current (last) term — replace it
            terms[terms.count - 1] = value
        } else {
            // Pending operator waiting for a new term — append
            terms.append(value)
        }
        isTyping = false
    }

    /// Evaluate terms left-to-right with the given operators.
    private static func evaluateAll(terms: [Double], ops: [Operator]) -> Double {
        guard let first = terms.first else { return 0 }
        var result = first
        for i in 0..<ops.count {
            guard i + 1 < terms.count else { break }
            switch ops[i] {
            case .add:      result += terms[i + 1]
            case .subtract: result -= terms[i + 1]
            case .multiply: result *= terms[i + 1]
            case .divide:   result = terms[i + 1] != 0 ? result / terms[i + 1] : 0
            }
        }
        return result
    }

    /// Rebuilds the expression string from current state.
    private mutating func rebuildExpression() {
        var expr = ""
        for i in 0..<terms.count {
            expr += Self.format(terms[i])
            if i < ops.count {
                expr += ops[i].rawValue
            }
        }
        if isTyping {
            if ops.count >= terms.count {
                // Typing a new term after an operator
                expr += display
            } else {
                // Typing over the last term — replace the formatted term with display
                let lastTermStr = Self.format(terms[terms.count - 1])
                if expr.hasSuffix(lastTermStr) {
                    expr = String(expr.dropLast(lastTermStr.count)) + display
                }
            }
        }
        expression = expr.isEmpty ? "0" : expr
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
}
