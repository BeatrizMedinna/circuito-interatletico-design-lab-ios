import SwiftUI

/// Barra de filtros ativos: botão Lime "limpar tudo" fixo à esquerda, separado
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
            // O ✕ fica dentro de um círculo fixo de 32 pt: sem limite, crescia além dele
            // em texto de acessibilidade. Tocar e segurar mostra o rótulo ampliado.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .accessibilityLabel("Limpar todos os filtros")
            .accessibilityShowsLargeContentViewer {
                Label("Limpar todos os filtros", systemImage: "xmark")
            }

            Rectangle()
                .fill(.separatorLine)
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

#Preview(traits: .appAppearance) {
    ActiveFiltersBar(onClearAll: {}) {
        RemovableChip(title: "Futsal") {}
        RemovableChip(title: "Masculino") {}
    }
    .padding()
}
