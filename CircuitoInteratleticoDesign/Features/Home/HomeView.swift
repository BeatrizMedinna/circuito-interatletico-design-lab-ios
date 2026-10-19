import SwiftUI

/// Tela 02 — Início: ao vivo, próximos e últimos jogos, com acesso às notificações.
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var scope: HomeScope = .favorite
    @State private var isPickingFavorite = false

    var body: some View {
        VStack(spacing: 0) {
            HomeHeader(scope: $scope, onPickFavorite: { isPickingFavorite = true })
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isPickingFavorite) {
            FavoriteAthleticSheet()
        }
        .onChange(of: appState.favoriteAthletic?.id) { _, newValue in
            withAnimation { scope = newValue == nil ? .general : .favorite }
        }
    }

    /// Sem atlética de coração, a Home mostra sempre todos os jogos.
    private var effectiveScope: HomeScope {
        appState.favoriteAthletic == nil ? .general : scope
    }

    // MARK: - Conteúdo por Estado

    @ViewBuilder
    private var content: some View {
        switch appState.matchesState {
        case .loading:
            HomeLoadingSkeleton()

        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar os jogos", systemImage: "wifi.exclamationmark")
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
                Text("Quando a próxima edição começar, os jogos aparecem aqui.")
            }

        case .loaded(let allMatches):
            HomeFeedView(
                allMatches: allMatches,
                effectiveScope: effectiveScope,
                scope: $scope
            )
        }
    }
}

// MARK: - Previews

#Preview("Minha atlética") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}

#Preview("Atlética sem jogos") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-poraque"), scenario: .filled, preloaded: true))
}

#Preview("Sem atlética de coração") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: nil, scenario: .filled, preloaded: true))
}

#Preview("Cronograma não publicado") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .empty, preloaded: true))
}

#Preview("Carregando") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .loading, preloaded: true))
}

#Preview("Erro") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .error, preloaded: true))
}

#Preview("Sem edição ativa") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .unavailable, preloaded: true))
}
