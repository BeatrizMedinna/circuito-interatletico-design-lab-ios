import SwiftUI

/// Linha de notificação na lista de avisos com indicador visual de lida/não lida.
struct NotificationRow: View {
    let notification: AppNotification
    let isRead: Bool
    let opensMatch: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            // Não lida: ponto Lime + título em negrito.
            Circle()
                .fill(isRead ? Color.clear : Color.actionPrimary)
                .frame(width: 8, height: 8)
                .padding(.top, 7)
                .accessibilityHidden(true)
            Image(systemName: notification.kind.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(iconColor)
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
        .padding(.leading, Spacing.s)
        .padding(.trailing, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue(isRead ? "" : "Não lida")
        .accessibilityHint(opensMatch ? "Abre a partida" : "")
    }

    /// Mudança de horário ou local em amarelo de atenção; os demais avisos em cinza.
    private var iconColor: Color {
        switch notification.kind {
        case .venueChange, .timeChange: .warning
        default: .textSecondary
        }
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: 0) {
        NotificationRow(notification: MockData.notifications[0], isRead: false, opensMatch: true)
        NotificationRow(notification: MockData.notifications[1], isRead: true, opensMatch: false)
    }
}
