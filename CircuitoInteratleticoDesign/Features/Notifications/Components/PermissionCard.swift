import SwiftUI

/// Cartão contextual de permissão de notificações do iOS (RN-87).
struct PermissionCard: View {
    let symbol: String
    let title: String
    let message: String
    let primaryTitle: String
    let primaryAction: () -> Void
    let secondaryTitle: String?
    let secondaryAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
                Image(systemName: symbol)
                    .font(.headline)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundStyle(.textPrimary)

            HStack(spacing: Spacing.s) {
                Button(primaryTitle, action: primaryAction)
                    .buttonStyle(.secondary)
                if let secondaryTitle, let secondaryAction {
                    Button(secondaryTitle, action: secondaryAction)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textPrimary)
                        .frame(minHeight: 44)
                }
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}

#Preview {
    PermissionCard(
        symbol: "bell.badge",
        title: "Receba avisos dos jogos",
        message: "Saiba na hora quando um jogo vai começar ou quando o horário mudar.",
        primaryTitle: "Ativar notificações",
        primaryAction: {},
        secondaryTitle: "Agora não",
        secondaryAction: {}
    )
    .padding()
}
