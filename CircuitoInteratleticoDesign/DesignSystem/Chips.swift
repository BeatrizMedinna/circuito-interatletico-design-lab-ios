import SwiftUI

/// Opção de escolha única em formato de pílula (Categoria, Divisão).
/// Selecionada: fundo preto, texto branco e ✓; tocar de novo desmarca.
struct ChoiceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
                Text(title)
                    .lineLimit(1)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? Color.textOnAccent : Color.textPrimary)
            .padding(.horizontal, Spacing.m)
            .frame(minHeight: 40)
            .background(isSelected ? Color.actionPrimary : Color.surface, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

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
    VStack(spacing: Spacing.m) {
        HStack {
            ChoiceChip(title: "Masculino", isSelected: true) {}
            ChoiceChip(title: "Feminino", isSelected: false) {}
        }
        RemovableChip(title: "Futsal") {}
    }
    .padding()
}
