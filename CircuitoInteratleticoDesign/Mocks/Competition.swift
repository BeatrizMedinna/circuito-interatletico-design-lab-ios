import Foundation

// Modalidade da edição numa divisão: é a "competição" que o torcedor acompanha.
// Eliminatória (mata-mata) tem chave e partidas; classificatória tem uma prova
// com marcas (RN-46 a RN-50). Tipos simples para a interface, não DTOs.

/// Critério da classificatória (RN-23).
enum RankingCriterion: Hashable {
    case lowerWins, higherWins

    var label: String {
        switch self {
        case .lowerWins: "Menor marca vence"
        case .higherWins: "Maior marca vence"
        }
    }
}

/// Unidade da marca (RN-23). Marcas têm até 3 casas decimais.
enum MarkUnit: Hashable {
    case time, distance, points, quantity

    var label: String {
        switch self {
        case .time: "Tempo"
        case .distance: "Distância"
        case .points: "Pontos"
        case .quantity: "Quantidade"
        }
    }

    /// "27,95 s", "1:02,35", "5,12 m", "12 pts", "15".
    func format(_ value: Double) -> String {
        let locale = Locale(identifier: "pt_BR")
        let decimal = value.formatted(.number.precision(.fractionLength(2)).locale(locale))
        switch self {
        case .time:
            guard value >= 60 else { return "\(decimal) s" }
            let minutes = Int(value) / 60
            let seconds = (value - Double(minutes * 60)).formatted(.number.precision(.integerAndFractionLength(integer: 2, fraction: 2)).locale(locale))
            return "\(minutes):\(seconds)"
        case .distance: return "\(decimal) m"
        case .points: return "\(value.formatted(.number.locale(locale))) pts"
        case .quantity: return value.formatted(.number.locale(locale))
        }
    }
}

enum CompetitionFormat: Hashable {
    case elimination
    case ranking(criterion: RankingCriterion, unit: MarkUnit, isTeamEvent: Bool)

    var label: String {
        switch self {
        case .elimination: "Eliminatória"
        case .ranking: "Classificatória"
        }
    }
}

/// Situação do resultado (RN-48). Só o válido tem marca e posição.
enum ResultSituation: Hashable {
    case valid, absent, retired, disqualified

    var label: String {
        switch self {
        case .valid: "Válido"
        case .absent: "Ausente"
        case .retired: "Desistência"
        case .disqualified: "Desclassificado"
        }
    }
}

struct TrialResult: Identifiable, Hashable {
    let id: String
    /// `nil` em prova por equipe (resultado da atlética).
    var athleteName: String? = nil
    let athletic: Athletic
    var situation: ResultSituation = .valid
    var mark: Double? = nil
}

/// Resultado já posicionado. Marcas iguais dividem a posição (RN-49).
struct RankedResult: Identifiable, Hashable {
    var id: String { result.id }
    let result: TrialResult
    let position: Int?
    let isTied: Bool
}

/// Prova de uma classificatória. Só existe "agendada" e "encerrada" no domínio;
/// resultados lançados antes do encerramento são parciais (RN-50).
struct Trial: Hashable {
    let startDate: Date
    let venue: String
    let isClosed: Bool
    /// Atléticas elegíveis da divisão (inscritas na prova).
    let participants: [Athletic]
    var results: [TrialResult] = []

    var hasPartialResults: Bool { !isClosed && !results.isEmpty }

    func ranked(by criterion: RankingCriterion) -> [RankedResult] {
        let valid = results.filter { $0.situation == .valid && $0.mark != nil }
            .sorted { criterion == .lowerWins ? $0.mark! < $1.mark! : $0.mark! > $1.mark! }
        let ranked = valid.map { result in
            let position = (valid.firstIndex { $0.mark == result.mark } ?? 0) + 1
            return RankedResult(result: result, position: position,
                                isTied: valid.filter { $0.mark == result.mark }.count > 1)
        }
        let others = results.filter { $0.situation != .valid || $0.mark == nil }
            .map { RankedResult(result: $0, position: nil, isTied: false) }
        return ranked + others
    }

    /// Atléticas inscritas que ainda não têm resultado lançado.
    var pendingParticipants: [Athletic] {
        participants.filter { athletic in !results.contains { $0.athletic.id == athletic.id } }
    }
}

/// Confronto da chave. Com `matchID`, os dados vêm da partida; sem ela, é um
/// confronto a definir ou um bye (avança direto, sem partida, RN-42).
struct BracketMatchup: Identifiable, Hashable {
    let id: String
    var matchID: Match.ID? = nil
    var teamA: Athletic? = nil
    var teamB: Athletic? = nil
    var isBye = false
}

struct BracketRound: Identifiable, Hashable {
    var id: String { phase }
    let phase: String
    let matchups: [BracketMatchup]
}

struct Competition: Identifiable, Hashable {
    let id: String
    let sport: Sport
    /// Nome da prova quando cada prova é uma modalidade (RN-26), ex.: "50m livre".
    var eventName: String? = nil
    let division: Division
    let format: CompetitionFormat
    /// Atletas inscritos (fictício).
    var registeredAthletes: Int? = nil
    var trial: Trial? = nil

    var title: String {
        eventName.map { "\(sport.title) · \($0)" } ?? sport.title
    }

    var isElimination: Bool { format == .elimination }

    func includes(_ match: Match) -> Bool {
        match.sport.title == sport.title && match.division.id == division.id && eventName == nil
    }
}

/// Fases do mata-mata, da primeira à final (RN-43).
enum Phase {
    static let order = ["128 avos de final", "64 avos de final", "32 avos de final",
                        "Oitavas de final", "Quartas de final", "Semifinal", "Final"]

    static func index(_ phase: String) -> Int { order.firstIndex(of: phase) ?? 0 }

    static func next(after phase: String) -> String? {
        let index = index(phase)
        return index + 1 < order.count ? order[index + 1] : nil
    }

    /// "na semifinal", "nas quartas de final".
    static func withPreposition(_ phase: String) -> String {
        let lower = phase.lowercased()
        if lower.hasPrefix("quartas") || lower.hasPrefix("oitavas") { return "nas \(lower)" }
        if lower.contains("avos") { return "nos \(lower)" }
        return "na \(lower)"
    }
}
