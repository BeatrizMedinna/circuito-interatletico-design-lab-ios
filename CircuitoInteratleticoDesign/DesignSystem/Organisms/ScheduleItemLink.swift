import SwiftUI

/// Partida ou prova do cronograma como link (partida → detalhe; prova → modalidade).
/// Usado na linha do tempo e nas agendas de Atlética e Modalidade.
struct ScheduleItemLink: View {
    let item: ScheduleItem
    var date: Formatters.CardDate = .none
    var showsVenue = true
    /// Substitui o cabeçalho do cartão de partida (ex.: "SEMIFINAL · HOJE, 10:30").
    var matchCaption: ((Match) -> String)? = nil
    /// Cartão de partida empilha os times só em texto muito grande (nome longo
    /// mantém as colunas, com "…"). Opcional: Cronograma e agenda da Atlética ligam.
    var adaptsMatchLayout = false

    var body: some View {
        switch item {
        case .match(let match):
            NavigationLink(value: AppRoute.match(match.id)) {
                MatchCard(match: match, showsStatus: true, date: date, caption: matchCaption?(match),
                          showsVenue: showsVenue,
                          stacksAtAccessibilitySizes: adaptsMatchLayout)
            }
            .buttonStyle(.pressableCard)
        case .trial(let competition):
            NavigationLink(value: AppRoute.competition(competition.id)) {
                TrialCard(competition: competition, date: date, showsVenue: showsVenue)
            }
            .buttonStyle(.pressableCard)
        }
    }
}

#Preview(traits: .appAppearance) {
    NavigationStack {
        VStack(spacing: Spacing.s) {
            ScheduleItemLink(item: .match(MockData.matches[0]))
            if let trialComp = MockData.competitions.first(where: { $0.trial != nil }) {
                ScheduleItemLink(item: .trial(trialComp))
            }
        }
        .padding()
    }
}
