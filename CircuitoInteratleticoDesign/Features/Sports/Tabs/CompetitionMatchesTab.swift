import SwiftUI

/// Resumo dos jogos da modalidade: ao vivo, próximo e último encerrado, com a
/// fase no cartão. "Ver todos" abre o Cronograma filtrado por esporte, categoria e divisão.
struct CompetitionMatchesTab: View {
    @Environment(AppState.self) private var appState
    let competition: Competition

    var body: some View {
        let matches = appState.matches.filter(competition.includes)
        if matches.isEmpty {
            InlineNote(systemImage: "calendar",
                       text: "A chave desta modalidade ainda não foi definida. Os jogos aparecem aqui depois do sorteio.")
        } else {
            AgendaSummary(items: matches.map(ScheduleItem.match),
                          filters: ScheduleFilters(sportName: competition.sport.name,
                                                   gender: competition.sport.gender,
                                                   divisionID: competition.division.id),
                          originName: competition.title,
                          matchCaption: { match in
                              "\(match.phase) · \(Formatters.dayLabel(match.startDate)), \(Formatters.time(match.startDate))".uppercased()
                          })
        }
    }
}

#Preview {
    let competition = MockData.competitions[0]
    CompetitionMatchesTab(competition: competition)
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
        .padding()
}
