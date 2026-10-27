import SwiftUI

/// Resultados da busca de atléticas na tela de Ranking.
struct RankingSearchResultsView: View {
    @Environment(AppState.self) private var appState
    @Binding var query: String

    var body: some View {
        let term = query.trimmingCharacters(in: .whitespaces)
        let results = MockData.athletics.filter { athletic in
            [athletic.name, athletic.acronym].contains {
                $0.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }

        if results.isEmpty {
            emptyView
        } else {
            resultsList(results: results)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("Nenhuma atlética encontrada", systemImage: "magnifyingglass")
        } description: {
            Text("Confira a grafia ou busque pela sigla, como ENG ou MED.")
        } actions: {
            Button("Limpar busca") { query = "" }
                .buttonStyle(.secondary)
        }
    }

    private func resultsList(results: [Athletic]) -> some View {
        ScrollView {
            VStack(spacing: 1) {
                ForEach(results) { athletic in
                    let entry = appState.rankingEntry(for: athletic.id)
                    NavigationLink(value: AppRoute.athletic(athletic.id)) {
                        RankingRow(
                            position: entry?.position,
                            athletic: athletic,
                            detail: [athletic.division.name, entry.map { Formatters.points($0.points) } ?? "sem classificação"]
                                .joined(separator: " · "),
                            isTied: entry?.isTied ?? false,
                            isFavorite: athletic.id == appState.favoriteAthletic?.id,
                            stacksAtAccessibilitySizes: true
                        )
                    }
                    .buttonStyle(.pressableCard)
                }
            }
            .padding(.vertical, Spacing.s)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    RankingSearchResultsView(query: .constant("Buf"))
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}
