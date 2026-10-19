import SwiftUI

/// Destinos empilhados nas abas Início, Cronograma e Ranking.
enum AppRoute: Hashable {
    case match(Match.ID)
    case notifications
    /// `nil` = jogos de todas as atléticas.
    case matchList(MatchListKind, Athletic.ID?)
    case athletic(Athletic.ID)
}

/// App depois do onboarding: quatro abas, cada uma com sua pilha de navegação.
/// Prototipadas: Início (Bloco 1), Cronograma (Bloco 2) e Ranking (Bloco 3).
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
                NextBlockPlaceholder(title: "Modalidades", systemImage: "star")
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
            }
        }
    }
}

/// Abas que ainda não foram prototipadas.
private struct NextBlockPlaceholder: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text("Esta área será prototipada em um próximo bloco do Design Lab.")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle(title)
        }
    }
}

#Preview {
    MainTabView(appState: AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled))
}
