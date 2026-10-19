import SwiftUI

/// Destinos empilhados em todas as abas.
enum AppRoute: Hashable {
    case match(Match.ID)
    case notifications
    /// `nil` = jogos de todas as atléticas.
    case matchList(MatchListKind, Athletic.ID?)
    case athletic(Athletic.ID)
    case competition(Competition.ID)
}

/// App depois do onboarding: quatro abas, cada uma com sua pilha de navegação.
/// Início (Bloco 1), Cronograma (Bloco 2), Ranking (Bloco 3) e Modalidades (Bloco 4).
struct MainTabView: View {
    @State private var appState: AppState

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }

    var body: some View {
        TabView {
            Tab("Início", systemImage: "house") {
                NavigationStack {
                    HomeView().withAppRoutes()
                }
            }
            Tab("Cronograma", systemImage: "calendar") {
                NavigationStack {
                    ScheduleView().withAppRoutes()
                }
            }
            Tab("Ranking", systemImage: "trophy") {
                NavigationStack {
                    RankingView().withAppRoutes()
                }
            }
            Tab("Modalidades", systemImage: "star") {
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
            case .matchList(let kind, let athleticID): MatchListView(kind: kind, athleticID: athleticID)
            case .athletic(let id): AthleticDetailView(athleticID: id)
            case .competition(let id): CompetitionDetailView(competitionID: id)
            }
        }
    }
}

#Preview {
    MainTabView(appState: AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled))
}
