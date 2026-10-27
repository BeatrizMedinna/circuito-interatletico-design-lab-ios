import SwiftUI

/// Linha de escolha única. A seleção aparece no fundo, no contorno Lime e no ✓,
/// não só na cor.
struct SelectionRow<Leading: View>: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void
    /// Em tamanhos de acessibilidade, escudo e ✓ ficam numa linha e o nome usa
    /// a largura toda abaixo. Opcional: hoje só o onboarding liga.
    var stacksAtAccessibilitySizes = false
    @ViewBuilder var leading: Leading
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            Group {
                if stacksAtAccessibilitySizes && dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            leading
                            Spacer(minLength: Spacing.xs)
                            checkmark
                        }
                        texts
                    }
                } else {
                    HStack(spacing: Spacing.s) {
                        leading
                        texts
                        Spacer(minLength: Spacing.xs)
                        checkmark
                    }
                }
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

    private var texts: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
        }
        .multilineTextAlignment(.leading)
    }

    private var checkmark: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(isSelected ? Color.brandPrimary : Color.textTertiary)
            .accessibilityHidden(true)
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
