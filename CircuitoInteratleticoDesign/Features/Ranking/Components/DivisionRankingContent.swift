import SwiftUI

/// Conteúdo da divisão no Ranking: pódio e lista de classificação, ou estado de divisão vazia.
struct DivisionRankingContent: View {
    @Environment(AppState.self) private var appState
    let ranking: DivisionRanking?
    let fallbackRanking: DivisionRanking?
    let onSelectFallback: ((Division.ID) -> Void)?

    var body: some View {
        let entries = ranking?.entries ?? []
        if entries.isEmpty {
            emptyView
        } else {
            rankingList(entries: entries)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("Classificação ainda não disponível", systemImage: "trophy")
        } description: {
            Text("A classificação da \(ranking?.division.name ?? "divisão") aparece quando houver resultados.")
        } actions: {
            if let fallback = fallbackRanking {
                Button("Ver \(fallback.division.name)") {
                    withAnimation { onSelectFallback?(fallback.division.id) }
                }
                .buttonStyle(.secondary)
            }
        }
    }

    private func rankingList(entries: [RankingEntry]) -> some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                Podium(entries: Array(entries.prefix(3)), favoriteID: appState.favoriteAthletic?.id)
                    .padding(.horizontal, Spacing.l)

                if entries.count > 3 {
                    VStack(spacing: 1) {
                        ForEach(entries.dropFirst(3)) { entry in
                            NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
                                RankingRow(position: entry.position, athletic: entry.athletic,
                                           detail: Formatters.points(entry.points), isTied: entry.isTied,
                                           isFavorite: entry.athletic.id == appState.favoriteAthletic?.id)
                            }
                            .buttonStyle(.pressableCard)
                        }
                    }
                    .background(Color.canvas)
                }
            }
            .padding(.vertical, Spacing.l)
        }
        .refreshable { await appState.refresh() }
    }
}

#Preview("Com dados") {
    DivisionRankingContent(
        ranking: MockData.rankings.first,
        fallbackRanking: nil,
        onSelectFallback: nil
    )
    .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}

#Preview("Divisão vazia") {
    DivisionRankingContent(
        ranking: DivisionRanking(division: MockData.serieBronze, entries: []),
        fallbackRanking: MockData.rankings.first,
        onSelectFallback: { _ in }
    )
    .environment(AppState(favoriteAthletic: nil, scenario: .filled, preloaded: true))
}
