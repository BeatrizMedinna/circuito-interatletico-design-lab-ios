import SwiftUI

/// Filtro ativo que pode ser removido com um toque ("Futsal ✕").
struct RemovableChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: Spacing.xxs) {
                Text(title)
                    .lineLimit(1)
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, Spacing.s)
            .frame(minHeight: 32)
            .background(.appBackground, in: Capsule())
            .overlay { Capsule().strokeBorder(.borderStrong, lineWidth: 1) }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remover filtro \(title)")
    }
}

#Preview {
    RemovableChip(title: "Futsal") {}
        .padding()
}
