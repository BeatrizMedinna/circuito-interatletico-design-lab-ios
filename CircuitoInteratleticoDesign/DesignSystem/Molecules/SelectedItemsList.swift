import SwiftUI

/// Escolhas de um campo dentro da sheet de filtros, em lista vertical (fácil de ler):
/// linhas retangulares como as de seleção, cada uma com ✕ para remover.
/// A barra horizontal de pílulas fica só na tela, depois de aplicar.
struct SelectedItemsList<Item: Hashable, Leading: View>: View {
    let items: [Item]
    let title: (Item) -> String
    let onRemove: (Item) -> Void
    /// "Remover todas" aparece com duas ou mais escolhas.
    let onRemoveAll: () -> Void
    @ViewBuilder var leading: (Item) -> Leading

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    if index > 0 {
                        Rectangle().fill(Color.separatorLine).frame(height: 1)
                            .padding(.leading, Spacing.m)
                    }
                    row(item)
                }
            }
            .cardSurface(cornerRadius: Radius.control)

            if items.count > 1 {
                Button("Remover todas") { withAnimation { onRemoveAll() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .underline()
                    .frame(minHeight: 44)
            }
        }
    }

    private func row(_ item: Item) -> some View {
        HStack(spacing: Spacing.s) {
            leading(item)
            Text(title(item))
                .font(.body)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.xs)
            Button {
                withAnimation { onRemove(item) }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(.surfaceSelected, in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.pressableCard)
            .accessibilityLabel("Remover \(title(item))")
        }
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.xxs)
        .frame(minHeight: 52)
    }
}
