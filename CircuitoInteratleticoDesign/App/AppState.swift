import Foundation
import Observation

/// Cenário de dados do protótipo. No simulador, escolha pelo argumento
/// de inicialização `-labScenario empty|loading|error|unavailable`.
enum LabScenario: String {
    case filled, empty, loading, error, unavailable

    static var fromLaunchArguments: LabScenario {
        UserDefaults.standard.string(forKey: "labScenario").flatMap(LabScenario.init) ?? .filled
    }
}

/// Estado compartilhado do app depois do onboarding: atlética de coração,
/// partidas e avisos simulados (sem rede).
@Observable
final class AppState {
    let favoriteAthletic: Athletic
    private(set) var scenario: LabScenario
    private(set) var matchesState: LoadState<[Match]> = .loading
    private(set) var notificationsState: LoadState<[AppNotification]> = .loading
    /// Última atualização dos placares ao vivo ("Atualizado há…").
    private(set) var lastRefresh = Date()

    /// `preloaded` monta o estado na hora (previews); senão, `load()` simula a espera.
    init(favoriteAthletic: Athletic, scenario: LabScenario = .fromLaunchArguments, preloaded: Bool = false) {
        self.favoriteAthletic = favoriteAthletic
        self.scenario = scenario
        if preloaded { apply() }
    }

    func load() async {
        matchesState = .loading
        notificationsState = .loading
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

    private func apply() {
        matchesState = resolve(MockData.matches)
        notificationsState = resolve(MockData.notifications)
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
