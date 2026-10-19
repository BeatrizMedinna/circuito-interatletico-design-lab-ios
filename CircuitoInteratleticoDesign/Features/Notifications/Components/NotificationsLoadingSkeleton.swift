import SwiftUI

/// Esqueleto de carregamento da lista de notificações.
struct NotificationsLoadingSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(MockData.notifications.prefix(3)) { notification in
                NotificationRow(notification: notification, isRead: true, opensMatch: false)
                Divider().padding(.leading, Spacing.l)
            }
            Spacer(minLength: 0)
        }
        .redacted(reason: .placeholder)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carregando notificações")
    }
}

#Preview {
    NotificationsLoadingSkeleton()
}
