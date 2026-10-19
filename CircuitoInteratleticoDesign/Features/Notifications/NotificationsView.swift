import SwiftUI
import UIKit

/// Tela 06 — Notificações, separadas em "Minha atlética" e "Geral".
/// Não lidas têm barra à esquerda e título em negrito; abrir um aviso o marca como lido.
/// Avisos ligados a uma partida abrem o detalhe dela.
struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) private var openURL
    @State private var scope: HomeScope = .favorite
    @State private var isShowingSystemPrompt = false

    var body: some View {
        VStack(spacing: 0) {
            if appState.favoriteAthletic != nil {
                UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
                    .padding(.horizontal, Spacing.l)
                    .background(Color.appBackground)
            }
            Divider()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if appState.unreadCount > 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ler todas") { appState.markAllAsRead() }
                        .accessibilityLabel("Marcar todas como lidas")
                }
            }
        }
        // Simulação do alerta do iOS: o protótipo não pede permissão real.
        .alert("“\(MockData.edition.name)” deseja enviar notificações", isPresented: $isShowingSystemPrompt) {
            Button("Não Permitir", role: .cancel) { appState.resolveNotificationPermission(allowed: false) }
            Button("Permitir") { appState.resolveNotificationPermission(allowed: true) }
        } message: {
            Text("As notificações podem incluir alertas, sons e indicadores no ícone. Você pode configurá-las nos Ajustes.")
        }
    }

    private var effectiveScope: HomeScope {
        appState.favoriteAthletic == nil ? .general : scope
    }

    @ViewBuilder
    private var content: some View {
        switch appState.notificationsState {
        case .loading:
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
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar as notificações", systemImage: "wifi.exclamationmark")
            } description: {
                Text("Verifique sua conexão e tente novamente.")
            } actions: {
                Button("Tentar novamente") { Task { await appState.retry() } }
                    .buttonStyle(.secondary)
            }
        case .unavailable:
            ContentUnavailableView {
                Label("Nenhuma edição em andamento", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Os avisos da próxima edição aparecem aqui.")
            }
        case .loaded(let all):
            list(all)
        }
    }

    @ViewBuilder
    private func list(_ all: [AppNotification]) -> some View {
        let favoriteID = appState.favoriteAthletic?.id ?? ""
        let items = (effectiveScope == .favorite ? all.filter { $0.athleticIDs.contains(favoriteID) } : all)
            .sorted { $0.date > $1.date }

        if items.isEmpty {
            VStack(spacing: 0) {
                permissionCard
                    .padding(Spacing.l)
                if effectiveScope == .favorite && !all.isEmpty {
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
        } else {
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
    }

    // MARK: - Permissão (RN-87)

    /// Convite no contexto em que o valor é claro: na lista de avisos, antes do alerta do sistema.
    @ViewBuilder
    private var permissionCard: some View {
        switch appState.notificationPermission {
        case .notDetermined where !appState.hasDeferredNotificationPrompt:
            PermissionCard(
                symbol: "bell.badge",
                title: "Receba avisos dos jogos",
                message: "Saiba na hora quando um jogo vai começar ou quando o horário ou o local mudar.",
                primaryTitle: "Ativar notificações",
                primaryAction: { isShowingSystemPrompt = true },
                secondaryTitle: "Agora não",
                secondaryAction: { withAnimation { appState.hasDeferredNotificationPrompt = true } })
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
                secondaryAction: nil)
        default:
            EmptyView()
        }
    }

    // MARK: - Linhas

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

private struct PermissionCard: View {
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

private struct NotificationRow: View {
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

private func notificationsPreview(_ scenario: LabScenario, favorite: Athletic.ID? = "ath-bufalos",
                                  permission: NotificationPermission = .notDetermined) -> some View {
    NavigationStack { NotificationsView() }
        .environment(AppState(favoriteAthletic: favorite.map { MockData.athletic($0) }, scenario: scenario,
                              notificationPermission: permission, preloaded: true))
}

#Preview("Com avisos") { notificationsPreview(.filled) }
#Preview("Permissão negada") { notificationsPreview(.filled, permission: .denied) }
#Preview("Permissão concedida") { notificationsPreview(.filled, permission: .authorized) }
#Preview("Sem atlética de coração") { notificationsPreview(.filled, favorite: nil) }
#Preview("Atlética sem avisos") { notificationsPreview(.filled, favorite: "ath-poraque") }
#Preview("Vazio") { notificationsPreview(.empty) }
#Preview("Carregando") { notificationsPreview(.loading) }
#Preview("Erro") { notificationsPreview(.error) }
