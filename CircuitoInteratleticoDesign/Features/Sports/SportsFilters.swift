import SwiftUI

/// Critérios da lista de Modalidades (tela 17): várias opções por campo, combináveis.
/// Campo vazio = "Todas".
struct SportsFilters: Equatable {
    var genders: Set<Gender> = []
    var divisionIDs: Set<Division.ID> = []

    var activeCount: Int { [!genders.isEmpty, !divisionIDs.isEmpty].filter { $0 }.count }
    var isEmpty: Bool { activeCount == 0 }

    func includes(_ competition: Competition) -> Bool {
        (genders.isEmpty || genders.contains(competition.sport.gender))
            && (divisionIDs.isEmpty || divisionIDs.contains(competition.division.id))
    }
}
