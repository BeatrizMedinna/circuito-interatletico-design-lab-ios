import SwiftUI

/// Lista de notificações agrupadas por data com gerenciamento de permissão e estado lido/não lido.
struct NotificationsListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL
    let all: [AppNotification]
    let effectiveScope: HomeScope
    @Binding var scope: HomeScope
    let onRequestSystemPrompt: () -> Void

    var body: some View {
        let favoriteID = appState.favoriteAthletic?.id ?? ""
        let items = (effectiveScope == .favorite ? all.filter { $0.athleticIDs.contains(favoriteID) } : all)
            .sorted { $0.date > $1.date }

        if items.isEmpty {
            emptyView(allCount: all.count)
        } else {
            notificationList(items: items)
        }
    }

    private func emptyView(allCount: Int) -> some View {
        VStack(spacing: 0) {
            permissionCard
                .padding(Spacing.l)

            if effectiveScope == .favorite && allCount > 0 {
                ContentUnavailableView {
                    Label("Nenhum aviso da sua atlética", systemImage: "bell.slash")
                } description: {
                    Text("Avisos sobre os jogos de \(appState.favoriteAthletic?.name ?? "sua atlética") aparecem aqui.")
                } actions: {
                    Button("Ver avisos gerais") { withAnimation { scope = .general } }
                        .buttonStyle(.secondary)
                }
            } else {
                ContentUnavailableView {
                    Label("Nenhuma notificação", systemImage: "bell.slash")
                } description: {
                    Text("Avisos de jogos e mudanças de horário ou local aparecem aqui.")
                }
            }
        }
    }

    private func notificationList(items: [AppNotification]) -> some View {
        ScrollView {
            permissionCard
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.m)

            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(groups(items), id: \.day) { group in
                    Section {
                        ForEach(group.items) { notification in
                            row(notification)
                            Divider().padding(.leading, Spacing.l)
                        }
                    } header: {
                        Text(Formatters.dayLabel(group.day))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.textSecondary)
                            .padding(.horizontal, Spacing.l)
                            .padding(.vertical, Spacing.xs)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.canvas)
                            .accessibilityAddTraits(.isHeader)
                    }
                }
            }
        }
        .refreshable { await appState.refresh() }
    }

    @ViewBuilder
    private var permissionCard: some View {
        switch appState.notificationPermission {
        case .notDetermined where !appState.hasDeferredNotificationPrompt:
            PermissionCard(
                symbol: "bell.badge",
                title: "Receba avisos dos jogos",
                message: "Saiba na hora quando um jogo vai começar ou quando o horário ou o local mudar.",
                primaryTitle: "Ativar notificações",
                primaryAction: onRequestSystemPrompt,
                secondaryTitle: "Agora não",
                secondaryAction: { withAnimation { appState.hasDeferredNotificationPrompt = true } }
            )
        case .denied:
            PermissionCard(
                symbol: "bell.slash",
                title: "Notificações desativadas",
                message: "Você continua vendo os avisos aqui, mas não recebe alertas. Para recebê-los, ative nos Ajustes do iPhone.",
                primaryTitle: "Abrir Ajustes",
                primaryAction: {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                },
                secondaryTitle: nil,
                secondaryAction: nil
            )
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func row(_ notification: AppNotification) -> some View {
        let isRead = appState.isRead(notification)
        Group {
            if let matchID = notification.matchID, appState.match(id: matchID) != nil {
                NavigationLink(value: AppRoute.match(matchID)) {
                    NotificationRow(notification: notification, isRead: isRead, opensMatch: true)
                }
                .buttonStyle(.pressableCard)
                .simultaneousGesture(TapGesture().onEnded { appState.setRead(notification, true) })
            } else {
                Button {
                    appState.setRead(notification, true)
                } label: {
                    NotificationRow(notification: notification, isRead: isRead, opensMatch: false)
                }
                .buttonStyle(.pressableCard)
            }
        }
        .contextMenu {
            Button(isRead ? "Marcar como não lida" : "Marcar como lida",
                   systemImage: isRead ? "envelope.badge" : "envelope.open") {
                appState.setRead(notification, !isRead)
            }
        }
    }

    private func groups(_ items: [AppNotification]) -> [(day: Date, items: [AppNotification])] {
        let calendar = Calendar.current
        var result: [(day: Date, items: [AppNotification])] = []
        for item in items {
            let day = calendar.startOfDay(for: item.date)
            if let last = result.indices.last, result[last].day == day {
                result[last].items.append(item)
            } else {
                result.append((day, [item]))
            }
        }
        return result
    }
}

#Preview {
    NavigationStack {
        NotificationsListView(
            all: MockData.notifications,
            effectiveScope: .favorite,
            scope: .constant(.favorite),
            onRequestSystemPrompt: {}
        )
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
