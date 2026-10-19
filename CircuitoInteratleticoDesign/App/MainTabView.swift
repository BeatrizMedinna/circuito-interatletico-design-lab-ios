import SwiftUI

/// Destinos empilhados a partir da aba Início.
enum HomeRoute: Hashable {
    case match(Match.ID)
    case notifications
    case matchList(MatchListKind, HomeScope)
}

/// App depois do onboarding: quatro abas, cada uma com sua pilha de navegação.
/// Por enquanto só Início está prototipada (Bloco 1).
struct MainTabView: View {
    @State private var appState: AppState

    init(appState: AppState) {
        _appState = State(initialValue: appState)
    }

    var body: some View {
        TabView {
            Tab("Início", systemImage: "house") {
                NavigationStack {
                    HomeView()
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .match(let id): MatchDetailView(matchID: id)
                            case .notifications: NotificationsView()
                            case .matchList(let kind, let scope): MatchListView(kind: kind, scope: scope)
                            }
                        }
                }
            }
            Tab("Cronograma", systemImage: "calendar") {
                NextBlockPlaceholder(title: "Cronograma", systemImage: "calendar")
            }
            Tab("Ranking", systemImage: "trophy") {
                NextBlockPlaceholder(title: "Ranking", systemImage: "trophy")
            }
            Tab("Modalidades", systemImage: "star") {
                NextBlockPlaceholder(title: "Modalidades", systemImage: "star")
            }
        }
        .environment(appState)
        .task { await appState.load() }
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
