import SwiftUI

/// Linha de escolha única. A seleção aparece no fundo, no contorno Lime e no ✓,
/// não só na cor.
struct SelectionRow<Leading: View>: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder var leading: Leading

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                leading
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                    }
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: Spacing.xs)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.brandPrimary : Color.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(Spacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.surfaceSelected : Color.surface,
                        in: RoundedRectangle(cornerRadius: Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.card)
                    .strokeBorder(isSelected ? Color.actionPrimary : Color.separatorLine,
                                  lineWidth: isSelected ? 2 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: Radius.card))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.s) {
        SelectionRow(title: "Opção Selecionada", subtitle: "Detalhes aqui", isSelected: true, action: {}) {
            Image(systemName: "star.fill").frame(width: 44, height: 44)
        }
        SelectionRow(title: "Opção Padrão", subtitle: "Outros detalhes", isSelected: false, action: {}) {
            Image(systemName: "star").frame(width: 44, height: 44)
        }
    }
    .padding()
}
