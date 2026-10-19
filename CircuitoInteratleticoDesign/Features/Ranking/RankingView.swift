import SwiftUI

/// Tela 09 — Classificação geral por divisão: pódio, lista, busca e acesso às atléticas.
/// Pontos são fictícios (classificação 📝 no domínio, P-08).
struct RankingView: View {
    @Environment(AppState.self) private var appState
    @State private var divisionID: Division.ID = MockData.divisions[0].id
    @State private var query = ""
    @State private var didPickInitialDivision = false

    var body: some View {
        VStack(spacing: 0) {
            RankingHeader(
                hasAnyRanking: hasAnyRanking,
                query: $query,
                divisionID: $divisionID
            )

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: handleInitialDivision)
        .onChange(of: appState.favoriteAthletic?.id) { _, _ in syncDivisionWithFavorite() }
    }

    private var rankings: [DivisionRanking] {
        guard case .loaded(let rankings) = appState.rankingState else { return [] }
        return rankings
    }

    private var hasAnyRanking: Bool {
        rankings.contains { !$0.entries.isEmpty }
    }

    // MARK: - Conteúdo por Estado

    @ViewBuilder
    private var content: some View {
        switch appState.rankingState {
        case .loading:
            RankingLoadingSkeleton()

        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar o ranking", systemImage: "wifi.exclamationmark")
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
                Text("Quando a próxima edição começar, o ranking aparece aqui.")
            }

        case .loaded:
            if !hasAnyRanking {
                ContentUnavailableView {
                    Label("Ranking ainda não disponível", systemImage: "trophy")
                } description: {
                    Text("A classificação geral aparece aqui quando houver resultados.")
                }
            } else if !query.isEmpty {
                RankingSearchResultsView(query: $query)
            } else {
                DivisionRankingContent(
                    ranking: rankings.first { $0.division.id == divisionID },
                    fallbackRanking: rankings.first { !$0.entries.isEmpty },
                    onSelectFallback: { divisionID = $0 }
                )
            }
        }
    }

    // MARK: - Sincronização da Divisão Inicial

    private func handleInitialDivision() {
        guard !didPickInitialDivision else { return }
        didPickInitialDivision = true
        syncDivisionWithFavorite()
    }

    private func syncDivisionWithFavorite() {
        if let division = appState.favoriteAthletic?.division {
            divisionID = division.id
        }
    }
}

// MARK: - Previews

private func rankingPreview(_ scenario: LabScenario, favorite: Athletic.ID? = "ath-bufalos") -> some View {
    NavigationStack { RankingView() }
        .environment(AppState(favoriteAthletic: favorite.map { MockData.athletic($0) }, scenario: scenario, preloaded: true))
}

#Preview("Série Ouro") { rankingPreview(.filled) }
#Preview("Empate no pódio (Prata)") { rankingPreview(.filled, favorite: "ath-diastolica") }
#Preview("Divisão sem classificação") { rankingPreview(.filled, favorite: "ath-severa") }
#Preview("Não disponível") { rankingPreview(.empty) }
#Preview("Carregando") { rankingPreview(.loading) }
#Preview("Erro") { rankingPreview(.error) }
