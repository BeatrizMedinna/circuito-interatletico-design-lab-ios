import SwiftUI

/// Tela 13 — Modalidades da edição (cada uma por divisão), com busca e filtros.
/// "Minha atlética | Geral" funciona como na Início; Categoria e Divisão continuam nos filtros.
struct SportsView: View {
    @Environment(AppState.self) private var appState
    @State private var query = ""
    @State private var filters = SportsFilters()
    @State private var isShowingFilters = false
    @State private var scope: HomeScope = .favorite

    var body: some View {
        VStack(spacing: 0) {
            SportsHeader(
                hasCompetitions: hasCompetitions,
                query: $query,
                filters: $filters,
                scope: $scope,
                onOpenFilters: { isShowingFilters = true }
            )

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingFilters) {
            SportsFilterSheet(competitions: scopedCompetitions, applied: $filters)
        }
        .sensoryFeedback(.success, trigger: filters)
        .onChange(of: appState.favoriteAthletic?.id) { _, newValue in
            withAnimation { scope = newValue == nil ? .general : .favorite }
        }
    }

    private var hasCompetitions: Bool { !appState.competitions.isEmpty }

    /// Sem atlética de coração, mostra sempre todas.
    private var effectiveScope: HomeScope {
        appState.favoriteAthletic == nil ? .general : scope
    }

    private var scopedCompetitions: [Competition] {
        guard effectiveScope == .favorite, let favoriteID = appState.favoriteAthletic?.id else {
            return appState.competitions
        }
        let matches = appState.matches
        return appState.competitions.filter { $0.involves(favoriteID, matches: matches) }
    }

    // MARK: - Conteúdo por Estado

    @ViewBuilder
    private var content: some View {
        switch appState.competitionsState {
        case .loading:
            SportsLoadingSkeleton()

        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar as modalidades", systemImage: "wifi.exclamationmark")
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
                Text("Quando a próxima edição começar, as modalidades aparecem aqui.")
            }

        case .loaded(let all):
            if all.isEmpty {
                ContentUnavailableView {
                    Label("Modalidades ainda não divulgadas", systemImage: "star")
                } description: {
                    Text("As modalidades aparecem aqui quando a organização configurar a edição.")
                }
            } else {
                SportsListView(
                    all: all,
                    effectiveScope: effectiveScope,
                    scope: $scope,
                    query: $query,
                    filters: $filters
                )
            }
        }
    }
}

// MARK: - Previews

private func sportsPreview(_ scenario: LabScenario) -> some View {
    NavigationStack { SportsView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: scenario, preloaded: true))
}

#Preview("Lista") { sportsPreview(.filled) }
#Preview("Não divulgadas") { sportsPreview(.empty) }
#Preview("Carregando") { sportsPreview(.loading) }
#Preview("Erro") { sportsPreview(.error) }
