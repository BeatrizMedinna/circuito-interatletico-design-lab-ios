import SwiftUI

/// Cabeçalho da tela de Modalidades: título, botão de filtros com badge, busca, abas de escopo e filtros ativos.
struct SportsHeader: View {
    @Environment(AppState.self) private var appState
    let hasCompetitions: Bool
    @Binding var query: String
    @Binding var filters: SportsFilters
    @Binding var scope: HomeScope
    let onOpenFilters: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Text("Modalidades")
                    .font(.title.bold())
                    .foregroundStyle(.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                if hasCompetitions {
                    Button(action: onOpenFilters) {
                        CircleIconLabel(systemName: "line.3.horizontal.decrease", isActive: !filters.isEmpty)
                            .overlay(alignment: .topTrailing) { CountBadge(count: filters.activeCount) }
                    }
                    .buttonStyle(.pressableCard)
                    .accessibilityLabel(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos")
                }
            }

            if hasCompetitions {
                SearchField(prompt: "Buscar modalidade", text: $query)

                if appState.favoriteAthletic != nil {
                    UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
                }

                if !filters.isEmpty {
                    activeFilters
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.xs)
        .padding(.bottom, Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    private var activeFilters: some View {
        ActiveFiltersBar(onClearAll: { withAnimation { filters = SportsFilters() } }) {
            if let gender = filters.gender {
                RemovableChip(title: gender.label) { withAnimation { filters.gender = nil } }
            }
            if let division = MockData.divisions.first(where: { $0.id == filters.divisionID }) {
                RemovableChip(title: division.name) { withAnimation { filters.divisionID = nil } }
            }
        }
        .padding(.horizontal, -Spacing.l)
    }
}

#Preview {
    SportsHeader(
        hasCompetitions: true,
        query: .constant(""),
        filters: .constant(SportsFilters()),
        scope: .constant(.favorite),
        onOpenFilters: {}
    )
    .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}
