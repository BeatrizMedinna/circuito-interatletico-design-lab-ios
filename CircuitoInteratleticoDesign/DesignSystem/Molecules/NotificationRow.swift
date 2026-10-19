import SwiftUI

/// Linha de notificação na lista de avisos com indicador visual de lida/não lida.
struct NotificationRow: View {
    let notification: AppNotification
    let isRead: Bool
    let opensMatch: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: notification.kind.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(notification.title)
                        .font(isRead ? .body : .headline)
                        .foregroundStyle(.textPrimary)
                    Spacer(minLength: 0)
                    Text(Formatters.time(notification.date))
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.textSecondary)
                }
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(isRead ? Color.textSecondary : Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if opensMatch {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textSecondary)
                    .padding(.top, 4)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, Spacing.m)
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        // Barra à esquerda (do wireframe 06) marca o aviso não lido.
        .overlay(alignment: .leading) {
            if !isRead {
                Rectangle().fill(.textPrimary).frame(width: 4)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue(isRead ? "" : "Não lida")
        .accessibilityHint(opensMatch ? "Abre a partida" : "")
    }
}

#Preview {
    VStack(spacing: 0) {
        NotificationRow(notification: MockData.notifications[0], isRead: false, opensMatch: true)
        NotificationRow(notification: MockData.notifications[1], isRead: true, opensMatch: false)
    }
}
