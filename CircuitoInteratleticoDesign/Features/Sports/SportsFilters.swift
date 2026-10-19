import SwiftUI

/// Critérios da lista de Modalidades (tela 17): uma opção por campo, combináveis.
struct SportsFilters: Equatable {
    var gender: Gender?
    var divisionID: Division.ID?

    var activeCount: Int { [gender != nil, divisionID != nil].filter { $0 }.count }
    var isEmpty: Bool { activeCount == 0 }

    func includes(_ competition: Competition) -> Bool {
        (gender == nil || competition.sport.gender == gender)
            && (divisionID == nil || competition.division.id == divisionID)
    }
}
