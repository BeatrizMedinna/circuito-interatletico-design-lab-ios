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

#Preview {
    HStack {
        ChoiceChip(title: "Masculino", isSelected: true) {}
        ChoiceChip(title: "Feminino", isSelected: false) {}
    }
    .padding()
}
