import SwiftUI

/// Critérios do cronograma. Cada campo aceita uma opção (hipótese do protótipo);
/// campos diferentes se combinam (todos precisam valer).
struct ScheduleFilters: Equatable {
    var sportName: String?
    var gender: Gender?
    var athleticID: Athletic.ID?
    var divisionID: Division.ID?

    var activeCount: Int {
        [sportName != nil, gender != nil, athleticID != nil, divisionID != nil].filter { $0 }.count
    }

    var isEmpty: Bool { activeCount == 0 }

    func includes(_ match: Match) -> Bool {
        (sportName == nil || match.sport.name == sportName)
            && (gender == nil || match.sport.gender == gender)
            && (athleticID.map(match.involves) ?? true)
            && (divisionID == nil || match.division.id == divisionID)
    }

    func includes(_ item: ScheduleItem) -> Bool {
        switch item {
        case .match(let match):
            return includes(match)
        case .trial(let competition):
            let participants = competition.trial?.participants ?? []
            return (sportName == nil || competition.sport.name == sportName)
                && (gender == nil || competition.sport.gender == gender)
                && (athleticID.map { id in participants.contains { $0.id == id } } ?? true)
                && (divisionID == nil || competition.division.id == divisionID)
        }
    }
}
