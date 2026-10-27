import SwiftUI

/// Tela 02 — Início: ao vivo, próximos e últimos jogos, com acesso às notificações.
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var scope: HomeScope = .favorite
    @State private var isPickingFavorite = false

    var body: some View {
        // Uma única rolagem: o cabeçalho sobe com o conteúdo e as abas "Minha atlética |
        // Geral" ficam fixas no topo (seção fixa nativa do LazyVStack).
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                HomeHeader(scope: $scope, onPickFavorite: { isPickingFavorite = true })
                Section {
                    content
                        .frame(maxWidth: .infinity)
                } header: {
                    HomeScopeTabs(scope: $scope)
                }
            }
        }
        .refreshableIf(canRefresh) { await appState.refresh() }
        // Faixa da área da barra de status no mesmo fundo das abas fixas: o conteúdo
        // que rola não aparece atrás do relógio e do Dynamic Island.
        .overlay(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)
                .accessibilityHidden(true)
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

    /// "Puxar para atualizar" só com jogos na tela, como antes (não nos estados vazios).
    private var canRefresh: Bool {
        guard case .loaded(let all) = appState.matchesState, !all.isEmpty else { return false }
        return !HomeFeedView.visibleMatches(all, scope: effectiveScope, favoriteID: appState.favoriteAthletic?.id).isEmpty
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
            // Dentro da rolagem da Início: altura mínima para o aviso ficar centralizado.
            .frame(minHeight: 420)

        case .unavailable:
            ContentUnavailableView {
                Label("Nenhuma edição em andamento", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Quando a próxima edição começar, os jogos aparecem aqui.")
            }
            // Dentro da rolagem da Início: altura mínima para o aviso ficar centralizado.
            .frame(minHeight: 420)

        case .loaded(let allMatches):
            HomeFeedView(
                allMatches: allMatches,
                effectiveScope: effectiveScope,
                scope: $scope
            )
        }
    }
}

private extension View {
    /// Aplica `refreshable` só quando permitido (sem mudar os estados que não atualizam).
    @ViewBuilder
    func refreshableIf(_ condition: Bool, action: @escaping @Sendable () async -> Void) -> some View {
        if condition { refreshable(action: action) } else { self }
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
