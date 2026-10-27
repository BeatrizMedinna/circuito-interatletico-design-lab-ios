import SwiftUI

/// Linha de notificação na lista de avisos com indicador visual de lida/não lida.
struct NotificationRow: View {
    let notification: AppNotification
    let isRead: Bool
    let opensMatch: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            // Não lida: ponto Lime + título em negrito.
            Circle()
                .fill(isRead ? Color.clear : Color.actionPrimary)
                .frame(width: 8, height: 8)
                .padding(.top, 14)
                .accessibilityHidden(true)
            // Ícone em círculo, como nas demais listas; atenção em amarelo.
            Image(systemName: notification.kind.symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(.surfaceInset, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                // Em tamanhos de acessibilidade o horário vai para baixo do título.
                if dynamicTypeSize.isAccessibilitySize {
                    title
                    time
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        title
                        Spacer(minLength: 0)
                        time
                    }
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
                    .foregroundStyle(.textTertiary)
                    .padding(.top, 10)
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

    private var title: some View {
        Text(notification.title)
            .font(isRead ? .body : .headline)
            .foregroundStyle(.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var time: some View {
        Text(Formatters.time(notification.date))
            .font(.subheadline)
            .monospacedDigit()
            .foregroundStyle(.textSecondary)
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
