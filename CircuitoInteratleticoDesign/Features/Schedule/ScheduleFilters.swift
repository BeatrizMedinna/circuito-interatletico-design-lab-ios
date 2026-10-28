import SwiftUI

/// Critérios do cronograma. Cada campo aceita várias opções (qualquer uma vale);
/// campos diferentes se combinam (todos precisam valer). Campo vazio = "Todas".
struct ScheduleFilters: Hashable {
    var sportNames: Set<String> = []
    var genders: Set<Gender> = []
    var athleticIDs: Set<Athletic.ID> = []
    var divisionIDs: Set<Division.ID> = []

    /// Atalho dos fluxos de contexto ("Ver mais", "Ver todos"): uma opção por campo.
    init(sportName: String? = nil, gender: Gender? = nil,
         athleticID: Athletic.ID? = nil, divisionID: Division.ID? = nil) {
        sportNames = Set([sportName].compactMap { $0 })
        genders = Set([gender].compactMap { $0 })
        athleticIDs = Set([athleticID].compactMap { $0 })
        divisionIDs = Set([divisionID].compactMap { $0 })
    }

    /// Quantos campos estão filtrados (não quantas opções).
    var activeCount: Int {
        [!sportNames.isEmpty, !genders.isEmpty, !athleticIDs.isEmpty, !divisionIDs.isEmpty].filter { $0 }.count
    }

    var isEmpty: Bool { activeCount == 0 }

    func includes(_ match: Match) -> Bool {
        (sportNames.isEmpty || sportNames.contains(match.sport.name))
            && (genders.isEmpty || genders.contains(match.sport.gender))
            && (athleticIDs.isEmpty || athleticIDs.contains(where: match.involves))
            && (divisionIDs.isEmpty || divisionIDs.contains(match.division.id))
    }

    func includes(_ item: ScheduleItem) -> Bool {
        switch item {
        case .match(let match):
            return includes(match)
        case .trial(let competition):
            let participants = competition.trial?.participants ?? []
            return (sportNames.isEmpty || sportNames.contains(competition.sport.name))
                && (genders.isEmpty || genders.contains(competition.sport.gender))
                && (athleticIDs.isEmpty || participants.contains { athleticIDs.contains($0.id) })
                && (divisionIDs.isEmpty || divisionIDs.contains(competition.division.id))
        }
    }
}
