import SwiftUI

/// Tela 06 — Notificações, separadas em "Minha atlética" e "Geral".
/// Não lidas têm barra à esquerda e título em negrito; abrir um aviso o marca como lido.
/// Avisos ligados a uma partida abrem o detalhe dela.
struct NotificationsView: View {
    @Environment(AppState.self) private var appState
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
                        .barControlNeutral()
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

    // MARK: - Conteúdo por Estado

    @ViewBuilder
    private var content: some View {
        switch appState.notificationsState {
        case .loading:
            NotificationsLoadingSkeleton()

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
                Text("As notificações da próxima edição aparecem aqui.")
            }

        case .loaded(let all):
            NotificationsListView(
                all: all,
                effectiveScope: effectiveScope,
                scope: $scope,
                onRequestSystemPrompt: { isShowingSystemPrompt = true }
            )
        }
    }
}

// MARK: - Previews

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
