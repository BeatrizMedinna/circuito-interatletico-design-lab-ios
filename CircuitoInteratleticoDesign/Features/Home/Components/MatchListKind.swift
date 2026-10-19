import Foundation

/// Seções "Próximos jogos" e "Últimos jogos" da Início.
enum MatchListKind: Hashable {
    case upcoming, recent

    var title: String {
        switch self {
        case .upcoming: "Próximos jogos"
        case .recent: "Últimos jogos"
        }
    }

    var emptyMessage: String {
        switch self {
        case .upcoming: "Nenhum jogo agendado por enquanto."
        case .recent: "Nenhum jogo encerrado ainda."
        }
    }

    var emptySymbol: String {
        switch self {
        case .upcoming: "calendar"
        case .recent: "flag.checkered"
        }
    }

    /// Próximos: do mais cedo ao mais tarde. Últimos: do mais recente ao mais antigo.
    func select(from matches: [Match]) -> [Match] {
        switch self {
        case .upcoming:
            matches.filter { $0.status == .scheduled }.sorted { $0.startDate < $1.startDate }
        case .recent:
            matches.filter { $0.status == .finished }.sorted { $0.startDate > $1.startDate }
        }
    }
}
