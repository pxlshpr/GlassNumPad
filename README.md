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

### Compound values — hours/minutes/seconds, feet/inches, stones/pounds

`GlassCompoundPad` types a value made of several parts, one part at a time. A row of part
chips ("1m · 30s") sits above the number; tap a chip to type into that part. There's no unit
capsule: the part being typed shows its name, muted, beside the number. The bound value is the
plain sum in base units (seconds, inches, pounds), and parts aren't clamped while typing.

```swift
@State private var seconds: Double = 90

.glassCompoundPad(isPresented: $show, value: $seconds, units: .minutesSeconds) {
    Image(systemName: "checkmark")
} header: {
    Text("Cue time")
} onAction: {
    save(seconds)
}
```

Presets: `.hoursMinutesSeconds`, `.hoursMinutes`, `.minutesSeconds` (base: seconds),
`.feetInches` (inches), `.stonesPounds` (pounds). Make your own with
`GlassCompoundUnits([GlassCompoundUnit(name:suffix:factor:maxDigits:), …])`. Embed
`GlassCompoundPad` directly to host it in your own sheet; `sheetHeight(headerHeight:)` gives
its detent.

### Presets — one-tap values

`.glassNumPadPresets(_:onSelect:)` puts a row of ready-made values where the unit capsule sits:
key-styled capsule buttons on a horizontal scroll, edge to edge. Tapping one hands it to
`onSelect` (typically: apply and close), while the keys still type any exact value. Works on the
plain pad and on `GlassCompoundPad` (values in its base units). Good for common values or
previously used amounts.

```swift
GlassCompoundPad(value: $seconds, units: .minutesSeconds) { … } header: { … }
    .glassNumPadPresets([
        GlassNumPadPreset(label: "15s", value: 15),
        GlassNumPadPreset(label: "1m 30s", value: 90),
    ]) { preset in save(preset.value) }
```

A plain pad can show the same muted unit beside its number with
`Configuration(showCapsule: false, displaySuffix: "kg")`.

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

## Sideways (compact height)

On an iPhone turned sideways the sheet lays the pad out side by side instead of stacked: the
caller's `header`, the number and the unit capsule (or the calculator's operator row) in a
leading column, the keys (or the unit picker) in a trailing one, both the key grid's width and
centred. The keys are sized to four rows of the sheet's height, and the sheet is attached to the
bottom edge so it keeps its corners and grabber. Only the sheet presentation does this; a
`GlassNumPad` embedded in your own layout keeps the stacked form.

The attach has to happen before the sheet's presentation begins: set from inside the sheet it
comes too late, and the sheet slides up from the unattached full-width frame, narrowing as it
rises. `SheetPresentationPrep` does it. The sheet modifier calls `expect(.edgeAttachedSheet)` as
its binding turns on, and one swizzled `present(_:animated:completion:)` applies it to the next
sheet presented within a second. It's public, so an app can prepare its own sheets the same way,
or present a full-screen cover unanimated with `.unanimatedCover`: a cover raised in a
transaction that disables animations is still presented `animated: true`.

## Where it's developed

The one working copy is `~/Developer/Packages/GlassNumPad` on each Mac (pxlbook and pxlhome),
tracking `github.com/pxlshpr/GlassNumPad`. Make every change there, then tag a release:

- **NutriKit** builds against that checkout directly (`../Packages/GlassNumPad`), so it picks
  changes up immediately; its `Package.swift` files also declare `from: "1.1.0"`.
- **Chunes, Bezlo, Crux and Overload** depend on tagged releases from GitHub (`from:` a 1.x tag,
  up-to-next-major; Overload `from: "1.2.0"` in `project.yml`). After tagging, re-resolve them
  (`xcodebuild -resolvePackageDependencies`), and raise `from:` in any that use the new API.

Pull the checkout on the other Mac after pushing, so both machines build the same code.

## License

[WTFPL](http://www.wtfpl.net/)
