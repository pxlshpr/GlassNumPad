# GlassNumPad

A glass-style numeric keypad for SwiftUI with an integrated calculator mode, presented in a detented sheet.

## Features

- Translucent glass sheet with drag handle
- Standard numpad layout (7-8-9 / 4-5-6 / 1-2-3 / 0)
- Built-in calculator mode (tap +/− to switch)
- Customizable capsule slot (unit picker, currency selector, etc.)
- Customizable action button (checkmark, save, etc.)
- Smooth animated transitions between modes
- Configurable accent colors, button styles, and dimensions

## Requirements

- iOS 17+
- Swift 5.9+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/pxlshpr/GlassNumPad.git", from: "0.1.0")
]
```

## Usage

### Basic — bare numpad

```swift
import GlassNumPad

struct ContentView: View {
    @State private var show = false
    @State private var amount: Double = 0

    var body: some View {
        Button("Enter amount") { show = true }
            .glassNumPad(isPresented: $show, value: $amount)
    }
}
```

### With action button

```swift
.glassNumPad(isPresented: $show, value: $amount) {
    Image(systemName: "checkmark")
} onAction: {
    save()
}
```

### With capsule + picker + action

```swift
.glassNumPad(
    isPresented: $show,
    value: $amount,
    configuration: .init(accentColor: .green, actionButtonStyle: .prominent)
) {
    // Capsule label — shown inside the pill
    Text("kg")
        .font(.system(size: 16, weight: .semibold))
} pickerContent: {
    // Replaces the numpad when the capsule is tapped
    UnitPickerGrid(selectedUnit: $unit)
} actionButton: {
    Image(systemName: "checkmark")
} onAction: {
    quickSave()
}
```

### Direct embedding (no sheet)

```swift
GlassNumPad(value: $amount, configuration: .init(accentColor: .orange)) {
    Text("USD")
} pickerContent: {
    CurrencyPicker()
} actionButton: {
    Image(systemName: "checkmark")
} onAction: {
    confirm()
}
```

## Configuration

| Property | Default | Description |
|---|---|---|
| `accentColor` | `.blue` | Color for prominent buttons and highlights |
| `clearColor` | `.orange` | Color for the C (clear) button |
| `sheetHeight` | `480` | Fixed height of the sheet detent |
| `buttonCornerRadius` | `12` | Corner radius on buttons |
| `buttonSpacing` | `8` | Gap between buttons |
| `horizontalPadding` | `16` | Side padding |
| `actionButtonStyle` | `.prominent` | `.dashed`, `.standard`, or `.prominent` |
| `showCapsule` | `true` | Whether to show the capsule bar |

## Modes

### Numpad (default)
Standard number entry. The bottom row has a double-wide 0 button, a +/− toggle, and the custom action slot.

### Calculator (tap +/−)
Full four-function calculator. An extra operator row appears at the top, operators line the right column. Tap `#` to return to the numpad with the result, or `=` to evaluate.

### Picker (tap capsule)
The capsule expands and the numpad is replaced with your custom picker content (e.g., a unit grid). Tap the capsule again to collapse back to the numpad.

## License

MIT
