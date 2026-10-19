import Foundation
import Observation
import SwiftUI

/// Cenário de dados do protótipo. No simulador, escolha pelo argumento
/// de inicialização `-labScenario empty|loading|error|unavailable`.
enum LabScenario: String {
    case filled, empty, loading, error, unavailable

    static var fromLaunchArguments: LabScenario {
        UserDefaults.standard.string(forKey: "labScenario").flatMap(LabScenario.init) ?? .filled
    }
}

/// Permissão de notificações simulada (o protótipo não pede permissão real ao iOS).
/// No simulador: `-labNotifications authorized|denied`.
enum NotificationPermission: String {
    case notDetermined, authorized, denied

    static var fromLaunchArguments: NotificationPermission {
        UserDefaults.standard.string(forKey: "labNotifications").flatMap(NotificationPermission.init) ?? .notDetermined
    }
}

/// Estado compartilhado do app depois do onboarding: atlética de coração,
/// partidas, avisos, leitura dos avisos e permissão simulada (sem rede).
@Observable
final class AppState {
    /// `nil` = o torcedor não segue nenhuma atlética (RN-86).
    private(set) var favoriteAthletic: Athletic?
    private(set) var scenario: LabScenario
    private(set) var matchesState: LoadState<[Match]> = .loading
    private(set) var notificationsState: LoadState<[AppNotification]> = .loading
    /// Classificação geral por divisão (dados fictícios, ver Mocks/Ranking.swift).
    private(set) var rankingState: LoadState<[DivisionRanking]> = .loading
    /// Modalidades da edição (chaves e provas).
    private(set) var competitionsState: LoadState<[Competition]> = .loading
    /// Última atualização dos placares ao vivo ("Atualizado há…").
    private(set) var lastRefresh = Date()

    /// Hipótese do protótipo: leitura guardada só no aparelho, sem regra no domínio.
    private(set) var readNotificationIDs: Set<AppNotification.ID>
    var notificationPermission: NotificationPermission
    /// "Agora não" esconde o convite para ativar notificações até o app reabrir.
    var hasDeferredNotificationPrompt = false

    /// Mensagem curta exibida acima da barra de abas.
    private(set) var toast: String?
    private var toastTask: Task<Void, Never>?

    /// `preloaded` monta o estado na hora (previews); senão, `load()` simula a espera.
    init(favoriteAthletic: Athletic?,
         scenario: LabScenario = .fromLaunchArguments,
         notificationPermission: NotificationPermission = .fromLaunchArguments,
         preloaded: Bool = false) {
        self.favoriteAthletic = favoriteAthletic
        self.scenario = scenario
        self.notificationPermission = notificationPermission
        readNotificationIDs = Set(MockData.notifications.filter { !Calendar.current.isDateInToday($0.date) }.map(\.id))
        if preloaded { apply() }
    }

    // MARK: - Carregamento

    func load() async {
        matchesState = .loading
        notificationsState = .loading
        rankingState = .loading
        competitionsState = .loading
        guard scenario != .loading else { return }
        try? await Task.sleep(for: .seconds(0.8))
        apply()
    }

    /// "Tentar novamente": a segunda tentativa sempre funciona.
    func retry() async {
        scenario = .filled
        await load()
    }

    /// Puxar para atualizar mantém o conteúdo e renova o horário.
    func refresh() async {
        try? await Task.sleep(for: .seconds(0.8))
        lastRefresh = Date()
    }

    func match(id: Match.ID) -> Match? {
        guard case .loaded(let matches) = matchesState else { return nil }
        return matches.first { $0.id == id }
    }

    /// Partidas carregadas (vazio enquanto carrega ou com erro).
    var matches: [Match] {
        guard case .loaded(let matches) = matchesState else { return [] }
        return matches
    }

    var competitions: [Competition] {
        guard case .loaded(let competitions) = competitionsState else { return [] }
        return competitions
    }

    func competition(id: Competition.ID) -> Competition? {
        competitions.first { $0.id == id }
    }

    /// Posição da atlética na classificação da divisão, se já houver.
    func rankingEntry(for athleticID: Athletic.ID) -> RankingEntry? {
        guard case .loaded(let rankings) = rankingState else { return nil }
        return rankings.lazy.flatMap(\.entries).first { $0.athletic.id == athleticID }
    }

    // MARK: - Atlética de coração

    func setFavorite(_ athletic: Athletic?) {
        guard athletic?.id != favoriteAthletic?.id else { return }
        favoriteAthletic = athletic
        if let athletic {
            showToast("Agora você torce por \(athletic.name)")
        } else {
            showToast("Você não segue nenhuma atlética")
        }
    }

    // MARK: - Notificações

    var unreadCount: Int {
        guard case .loaded(let notifications) = notificationsState else { return 0 }
        return notifications.filter { !readNotificationIDs.contains($0.id) }.count
    }

    func isRead(_ notification: AppNotification) -> Bool {
        readNotificationIDs.contains(notification.id)
    }

    func setRead(_ notification: AppNotification, _ isRead: Bool) {
        if isRead {
            readNotificationIDs.insert(notification.id)
        } else {
            readNotificationIDs.remove(notification.id)
        }
    }

    func markAllAsRead() {
        guard case .loaded(let notifications) = notificationsState else { return }
        readNotificationIDs.formUnion(notifications.map(\.id))
        showToast("Todas as notificações foram lidas")
    }

    func resolveNotificationPermission(allowed: Bool) {
        notificationPermission = allowed ? .authorized : .denied
        showToast(allowed ? "Notificações ativadas" : "Notificações desativadas")
    }

    // MARK: - Aviso rápido

    func showToast(_ message: String) {
        toastTask?.cancel()
        withAnimation(.snappy) { toast = message }
        AccessibilityNotification.Announcement(message).post()
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            withAnimation(.snappy) { toast = nil }
        }
    }

    // MARK: - Cenários

    private func apply() {
        matchesState = resolve(MockData.matches)
        notificationsState = resolve(MockData.notifications)
        rankingState = resolve(MockData.rankings)
        competitionsState = resolve(MockData.competitions)
        lastRefresh = Date()
    }

    private func resolve<Item>(_ items: [Item]) -> LoadState<[Item]> {
        switch scenario {
        case .filled: .loaded(items)
        case .empty: .loaded([])
        case .loading: .loading
        case .error: .failed
        case .unavailable: .unavailable
        }
    }
}
