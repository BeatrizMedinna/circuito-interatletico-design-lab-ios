import SwiftUI

/// Lista de modalidades com suporte a busca, filtros, estados vazios e atualização.
struct SportsListView: View {
    @Environment(AppState.self) private var appState
    let all: [Competition]
    let effectiveScope: HomeScope
    @Binding var scope: HomeScope
    @Binding var query: String
    @Binding var filters: SportsFilters

    var body: some View {
        let base = scoped(all)
        let items = base.filter { filters.includes($0) && matchesQuery($0) }

        if base.isEmpty {
            emptyScopeView
        } else if items.isEmpty {
            emptySearchView
        } else {
            competitionList(items: items)
        }
    }

    private func scoped(_ competitions: [Competition]) -> [Competition] {
        guard effectiveScope == .favorite, let favoriteID = appState.favoriteAthletic?.id else { return competitions }
        let matches = appState.matches
        return competitions.filter { $0.involves(favoriteID, matches: matches) }
    }

    private var emptyScopeView: some View {
        ContentUnavailableView {
            Label("Sua atlética ainda não disputa modalidades", systemImage: "star")
        } description: {
            Text("Quando \(appState.favoriteAthletic?.name ?? "sua atlética") entrar em uma chave ou prova, a modalidade aparece aqui.")
        } actions: {
            Button("Ver todas as modalidades") { withAnimation { scope = .general } }
                .buttonStyle(.secondary)
        }
    }

    private var emptySearchView: some View {
        ContentUnavailableView {
            Label(query.isEmpty ? "Nenhuma modalidade com esses filtros" : "Nenhuma modalidade encontrada",
                  systemImage: query.isEmpty ? "line.3.horizontal.decrease" : "magnifyingglass")
        } description: {
            Text(query.isEmpty ? "Tente outra categoria ou divisão."
                 : filters.isEmpty ? "Confira a grafia ou tente outro nome, como Futsal ou Natação."
                 : "Nada combina com a busca e os filtros juntos. Tente limpar um deles.")
        } actions: {
            if !query.isEmpty {
                Button("Limpar busca") { query = "" }
                    .buttonStyle(.secondary)
            }
            if !filters.isEmpty {
                Button("Limpar filtros") { withAnimation { filters = SportsFilters() } }
                    .font(.subheadline.weight(.semibold))
                    .underline()
                    .foregroundStyle(.textPrimary)
            }
        }
    }

    private func competitionList(items: [Competition]) -> some View {
        let matches = appState.matches
        return ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(items) { competition in
                    NavigationLink(value: AppRoute.competition(competition.id)) {
                        CompetitionRow(
                            competition: competition,
                            progress: competition.progress(matches: matches),
                            isLive: competition.hasLiveMatch(in: matches)
                        )
                    }
                    .buttonStyle(.pressableCard)
                }
            }
            .padding(.vertical, Spacing.s)
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable { await appState.refresh() }
    }

    /// Busca por modalidade, prova ou esporte, ignorando maiúsculas e acentos.
    private func matchesQuery(_ competition: Competition) -> Bool {
        let term = query.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return true }
        return competition.title.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}

#Preview {
    NavigationStack {
        SportsListView(
            all: MockData.competitions,
            effectiveScope: .general,
            scope: .constant(.general),
            query: .constant(""),
            filters: .constant(SportsFilters())
        )
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
