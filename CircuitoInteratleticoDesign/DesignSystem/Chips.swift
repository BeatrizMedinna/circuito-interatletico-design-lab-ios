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

/// Barra de filtros ativos: botão preto "limpar tudo" fixo à esquerda, separado
/// por um traço, e as pílulas (cada uma com seu ✕) rolando na horizontal.
struct ActiveFiltersBar<Chips: View>: View {
    let onClearAll: () -> Void
    @ViewBuilder var chips: Chips

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Button(action: onClearAll) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.textOnAccent)
                    .frame(width: 32, height: 32)
                    .background(.actionPrimary, in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.pressableCard)
            .accessibilityLabel("Limpar todos os filtros")

            Rectangle()
                .fill(.surfaceSelected)
                .frame(width: 1, height: 24)
                .accessibilityHidden(true)

            ScrollView(.horizontal) {
                HStack(spacing: Spacing.xs) { chips }
                    .padding(.trailing, Spacing.l)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.leading, Spacing.l - 6)
    }
}

/// Pílulas que quebram linha quando não cabem (nomes longos, fonte grande).
struct FlowChips<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option?
    let title: (Option) -> String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.xs) { chips }
            VStack(alignment: .leading, spacing: Spacing.xs) { chips }
        }
    }

    private var chips: some View {
        ForEach(options, id: \.self) { option in
            ChoiceChip(title: title(option), isSelected: selection == option) {
                selection = selection == option ? nil : option
            }
        }
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
