import SwiftUI
import GlassNumPad

struct ContentView: View {

    @State private var showNumPad = false
    @State private var amount: Double = 1
    @State private var unit = "medium"

    // USDA Banana (raw) — diverse unit set
    let servingUnits = ["serving"]
    let weightUnits  = ["g", "mg", "kg", "oz", "lb"]
    let volumeUnits  = ["cup", "mL", "tbsp", "tsp", "L", "fl oz"]
    let sizeUnits    = ["extra small", "small", "medium", "large", "extra large"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.green.opacity(0.3), .black, .blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Banana, Raw")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("USDA")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))

                VStack(spacing: 4) {
                    Text(formattedAmount)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.interactiveSpring, value: amount)
                    Text(unit)
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Decorative nutrition cards
                HStack(spacing: 12) {
                    nutrientCard(name: "Energy", value: "89", unit: "kcal")
                    nutrientCard(name: "Protein", value: "1.1", unit: "g")
                    nutrientCard(name: "Carbs", value: "22.8", unit: "g")
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    nutrientCard(name: "Fat", value: "0.3", unit: "g")
                    nutrientCard(name: "Fiber", value: "2.6", unit: "g")
                    nutrientCard(name: "Potassium", value: "358", unit: "mg")
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    showNumPad = true
                } label: {
                    Label("Enter Amount", systemImage: "number.square")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Spacer().frame(height: 40)
            }
        }
        .glassNumPad(
            isPresented: $showNumPad,
            value: $amount,
            configuration: .init(
                accentColor: .green,
                actionButtonStyle: .prominent
            )
        ) {
            // Capsule label
            Text(unit)
                .font(.system(size: 16, weight: .semibold))
        } pickerContent: {
            // Sectioned unit picker
            unitPicker
        } actionButton: {
            Image(systemName: "checkmark")
        } onAction: {
            showNumPad = false
        }
    }

    // MARK: - Helpers

    private var formattedAmount: String {
        if amount == floor(amount) && amount < 1e10 {
            return String(format: "%.0f", amount)
        }
        return String(format: "%.2f", amount)
    }

    private func nutrientCard(name: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(.white)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Unit picker (sectioned)

    private var unitPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Serving
            unitSection(title: nil, units: servingUnits)

            // Weights
            unitSection(title: "WEIGHTS", units: weightUnits)

            // Volumes
            unitSection(title: "VOLUMES", units: volumeUnits)

            // Sizes
            unitSection(title: "SIZES", units: sizeUnits)
        }
    }

    @ViewBuilder
    private func unitSection(title: String?, units: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.leading, 2)
            }
            FlowLayout(spacing: 8) {
                ForEach(units, id: \.self) { u in
                    unitChip(u)
                }
            }
        }
    }

    private func unitChip(_ u: String) -> some View {
        let selected = unit == u
        return Button {
            unit = u
        } label: {
            Text(u)
                .font(.system(size: 15, weight: selected ? .bold : .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selected
                              ? AnyShapeStyle(Color.green.gradient)
                              : AnyShapeStyle(Color.white.opacity(0.1)))
                )
                .foregroundStyle(selected ? .white : .white.opacity(0.8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Simple flow layout for chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (origins: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalWidth = max(totalWidth, x - spacing)
            totalHeight = y + rowHeight
        }

        return (origins, CGSize(width: totalWidth, height: totalHeight))
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
