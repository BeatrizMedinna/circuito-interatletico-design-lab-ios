import SwiftUI

/// Opção de escolha única em formato de pílula (Categoria, Divisão).
/// Selecionada: Lime com texto On Lime e ✓; tocar de novo desmarca.
struct ChoiceChip: View {
    let title: String
    let isSelected: Bool
    /// Reserva a largura do ✓ também quando desmarcada, para a pílula não
    /// crescer ao ser escolhida (e não empurrar as vizinhas). Opcional.
    var keepsWidthStable = false
    let action: () -> Void

    init(title: String, isSelected: Bool, keepsWidthStable: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.keepsWidthStable = keepsWidthStable
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if keepsWidthStable {
                    label(showsCheckmark: true).hidden()
                }
                label(showsCheckmark: isSelected)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? Color.textOnAccent : Color.textPrimary)
            .padding(.horizontal, Spacing.m)
            .frame(minHeight: 40)
            .background(isSelected ? Color.actionPrimary : Color.surfaceInset, in: Capsule())
            .overlay { Capsule().strokeBorder(Color.separatorLine, lineWidth: isSelected ? 0 : 1) }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func label(showsCheckmark: Bool) -> some View {
        HStack(spacing: Spacing.xxs) {
            if showsCheckmark {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
            }
            Text(title)
                .lineLimit(1)
        }
    }
}

#Preview(traits: .appAppearance) {
    HStack {
        ChoiceChip(title: "Masculino", isSelected: true) {}
        ChoiceChip(title: "Feminino", isSelected: false) {}
    }
    .padding()
}
