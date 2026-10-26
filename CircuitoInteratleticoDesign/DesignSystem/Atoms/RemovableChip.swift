import SwiftUI

/// Filtro ativo que pode ser removido com um toque ("Futsal ✕").
struct RemovableChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: Spacing.xs) {
                Text(title)
                    .lineLimit(1)
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.textSecondary)
                    .frame(width: 18, height: 18)
                    .background(.surfaceSelected, in: Circle())
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.textPrimary)
            .padding(.leading, Spacing.s)
            .padding(.trailing, 6)
            .frame(minHeight: 32)
            .background(.surfaceInset, in: Capsule())
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remover filtro \(title)")
    }
}

#Preview(traits: .appAppearance) {
    RemovableChip(title: "Futsal") {}
        .padding()
}
