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
                            .overlay(alignment: .topTrailing) { CountBadge(count: filters.activeCount, onAccent: true) }
                    }
                    .buttonStyle(.pressableCard)
                    // Botão de tamanho fixo (44 pt): o ícone e o contador param de crescer no
                    // maior tamanho padrão; acima disso, tocar e segurar amplia (como o sino da Início).
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .accessibilityLabel(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos")
                    .accessibilityShowsLargeContentViewer {
                        Label(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos",
                              systemImage: "line.3.horizontal.decrease")
                    }
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
        // Trilho de ponta a ponta sob o cabeçalho, como na Início e no Ranking.
        .overlay(alignment: .bottom) {
            if hasCompetitions {
                Rectangle().fill(.separatorLine).frame(height: 1)
            }
        }
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    private var activeFilters: some View {
        ActiveFiltersBar(onClearAll: { withAnimation { filters = SportsFilters() } }) {
            ForEach([Gender.male, .female, .mixed].filter(filters.genders.contains), id: \.self) { gender in
                RemovableChip(title: gender.label) { withAnimation { _ = filters.genders.remove(gender) } }
            }
            ForEach(MockData.divisions.filter { filters.divisionIDs.contains($0.id) }) { division in
                RemovableChip(title: division.name) { withAnimation { _ = filters.divisionIDs.remove(division.id) } }
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
