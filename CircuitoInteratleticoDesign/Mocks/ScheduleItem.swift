import Foundation

/// Item do cronograma publicado: uma partida ou uma prova (RN-52).
enum ScheduleItem: Identifiable, Hashable {
    case match(Match)
    case trial(Competition)

    var id: String {
        switch self {
        case .match(let match): match.id
        case .trial(let competition): competition.id
        }
    }

    var startDate: Date {
        switch self {
        case .match(let match): match.startDate
        case .trial(let competition): competition.trial?.startDate ?? .distantFuture
        }
    }

    var sport: Sport {
        switch self {
        case .match(let match): match.sport
        case .trial(let competition): competition.sport
        }
    }

    /// Partida ainda não encerrada ou prova ainda aberta.
    var isOpen: Bool {
        switch self {
        case .match(let match): match.status != .finished
        case .trial(let competition): competition.trial?.isClosed == false
        }
    }

    /// Partida ao vivo ou prova com resultados parciais (em andamento).
    var isLive: Bool {
        switch self {
        case .match(let match): match.status == .live
        case .trial(let competition): competition.trial?.hasPartialResults ?? false
        }
    }
}
