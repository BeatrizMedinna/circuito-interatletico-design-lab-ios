import SwiftUI

/// Seção de lista de partidas (próximos ou últimos jogos) com cabeçalho e "Ver mais".
struct HomeMatchSection: View {
    @Environment(AppState.self) private var appState
    let kind: MatchListKind
    let matches: [Match]
    let isFavoriteScope: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: kind.title) {
                if !matches.isEmpty {
                    Button("Ver mais") {
                        appState.openSchedule(
                            filters: ScheduleFilters(athleticID: isFavoriteScope ? appState.favoriteAthletic?.id : nil),
                            focus: kind == .upcoming ? .upcoming : .recent
                        )
                    }
                    .frame(minHeight: 44)
                    .accessibilityLabel(kind == .upcoming ? "Ver mais próximos jogos no cronograma" : "Ver mais resultados no cronograma")
                }
            }
            .padding(.horizontal, Spacing.l)

            if matches.isEmpty {
                InlineNote(systemImage: kind.emptySymbol, text: kind.emptyMessage)
                    .padding(.horizontal, Spacing.l)
            } else {
                MatchCarousel(matches: Array(matches.prefix(5)))
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeMatchSection(
            kind: .upcoming,
            matches: MockData.matches.filter { $0.status == .scheduled },
            isFavoriteScope: true
        )
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
