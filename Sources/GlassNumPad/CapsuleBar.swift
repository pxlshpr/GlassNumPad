import SwiftUI

struct CapsuleBar<Label: View>: View {

    @Binding var isExpanded: Bool
    let accentColor: Color
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button {
            Haptic.medium()
            withAnimation(.interactiveSpring(duration: 0.35)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                label()
                    .foregroundStyle(isExpanded ? accentColor : .white.opacity(0.7))
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isExpanded ? accentColor : .white.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background {
                Capsule(style: .continuous)
                    .fill(isExpanded
                        ? accentColor.opacity(0.2)
                        : .white.opacity(0.08)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
