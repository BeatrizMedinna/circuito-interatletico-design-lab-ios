import SwiftUI

/// Destinos empilhados em todas as abas.
enum AppRoute: Hashable {
    case match(Match.ID)
    case notifications
    case athletic(Athletic.ID)
    case competition(Competition.ID)
}

/// App depois do onboarding: quatro abas, cada uma com sua pilha de navegação.
/// Início (Bloco 1), Cronograma (Bloco 2), Ranking (Bloco 3) e Modalidades (Bloco 4).
struct MainTabView: View {
    @State private var appState: AppState
    @State private var schedulePath = NavigationPath()

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Tab("Início", systemImage: "house", value: AppTab.home) {
                NavigationStack {
                    HomeView().withAppRoutes()
                }
            }
            Tab("Cronograma", systemImage: "calendar", value: AppTab.schedule) {
                NavigationStack(path: $schedulePath) {
                    ScheduleView().withAppRoutes()
                }
            }
            Tab("Ranking", systemImage: "trophy", value: AppTab.ranking) {
                NavigationStack {
                    RankingView().withAppRoutes()
                }
            }
            Tab("Modalidades", systemImage: "star", value: AppTab.sports) {
                NavigationStack {
                    SportsView().withAppRoutes()
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let message = appState.toast {
                Toast(message: message)
                    .padding(.bottom, 96)
                    .allowsHitTesting(false)
            }
        }
        // Um pedido de outra tela volta o Cronograma para a raiz antes de filtrar.
        .onChange(of: appState.scheduleRequest?.id) { _, request in
            if request != nil { schedulePath = NavigationPath() }
        }
        .environment(appState)
        .task { await appState.load() }
    }
}

private extension View {
    func withAppRoutes() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .match(let id): MatchDetailView(matchID: id)
            case .notifications: NotificationsView()
            case .athletic(let id): AthleticDetailView(athleticID: id)
            case .competition(let id): CompetitionDetailView(competitionID: id)
            }
        }
    }
}

#Preview {
    MainTabView(appState: AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled))
}
