import SwiftUI

/// The pill-shaped bar beneath the number display that hosts custom content
/// (e.g., a unit picker label). Tapping toggles between collapsed and expanded states.
struct CapsuleBar<Label: View>: View {

    @Binding var isExpanded: Bool
    let accentColor: Color
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button {
            withAnimation(.interactiveSpring(duration: 0.35)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                label()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isExpanded ? accentColor : .secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Capsule(style: .continuous)
                    .fill(isExpanded
                        ? accentColor.opacity(0.18)
                        : Color.primary.opacity(0.08)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(isExpanded ? 0 : 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
