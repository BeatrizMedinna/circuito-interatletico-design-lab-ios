import Foundation

// Tipos simples para as telas de partidas; não espelham as tabelas da API.

enum Gender: Hashable {
    case male, female, mixed

    var label: String {
        switch self {
        case .male: "Masculino"
        case .female: "Feminino"
        case .mixed: "Misto"
        }
    }
}

/// Modalidade como o torcedor a vê: esporte + gênero.
struct Sport: Hashable {
    let name: String
    let gender: Gender
    /// SF Symbol do esporte.
    let symbol: String
    /// Abreviação do período: "Q" (quarto), "T" (tempo) ou "Set".
    let periodAbbreviation: String

    var title: String { "\(name) \(gender.label)" }

    func periodLabel(_ number: Int) -> String { "\(number)º \(periodAbbreviation)" }
}

enum MatchStatus: Hashable {
    case scheduled, live, finished

    var title: String {
        switch self {
        case .scheduled: "A iniciar"
        case .live: "Ao vivo"
        case .finished: "Encerrado"
        }
    }
}

enum MatchSide: Hashable {
    case a, b
}

/// Placar de um período (quarto, tempo ou set).
struct PeriodScore: Hashable {
    let number: Int
    let a: Int
    let b: Int
}

/// Lance do histórico da partida.
struct Play: Identifiable, Hashable {
    let id: String
    let period: Int
    /// Momento do lance no período, ex.: "8'". Esportes de set não têm.
    var minute: String? = nil
    let side: MatchSide
    let description: String
    var athleteName: String? = nil
    /// Placar da partida logo após o lance.
    let scoreA: Int
    let scoreB: Int
}

struct Match: Identifiable, Hashable {
    let id: String
    let sport: Sport
    let division: Division
    let phase: String
    let venue: String
    let startDate: Date
    let status: MatchStatus
    /// `nil` = atlética a definir (depende de partida anterior).
    let teamA: Athletic?
    let teamB: Athletic?
    var scoreA: Int? = nil
    var scoreB: Int? = nil
    var periods: [PeriodScore] = []
    /// Período em andamento (só ao vivo).
    var currentPeriod: Int? = nil
    /// Cronômetro exibido ao vivo (simulado; o domínio ainda não tem relógio de jogo).
    var clock: String? = nil
    var plays: [Play] = []
    /// Vencedor por W.O., sem placar.
    var walkoverWinner: MatchSide? = nil

    func team(_ side: MatchSide) -> Athletic? {
        side == .a ? teamA : teamB
    }

    func involves(_ athleticID: Athletic.ID) -> Bool {
        teamA?.id == athleticID || teamB?.id == athleticID
    }

    var winner: MatchSide? {
        guard status == .finished else { return nil }
        if let walkoverWinner { return walkoverWinner }
        guard let scoreA, let scoreB, scoreA != scoreB else { return nil }
        return scoreA > scoreB ? .a : .b
    }

    func isLoser(_ side: MatchSide) -> Bool {
        guard let winner else { return false }
        return winner != side
    }

    /// Resumo lido pelo VoiceOver nos cartões.
    var accessibilitySummary: String {
        let nameA = teamA?.name ?? "A definir"
        let nameB = teamB?.name ?? "A definir"
        let when = "\(Formatters.dayLabel(startDate)), \(Formatters.time(startDate))"
        switch status {
        case .scheduled:
            return "\(sport.title), \(nameA) contra \(nameB), \(when)"
        case .live:
            return "Ao vivo, \(sport.title), \(nameA) \(scoreA ?? 0), \(nameB) \(scoreB ?? 0)"
        case .finished:
            if let walkoverWinner, let team = team(walkoverWinner) {
                return "Encerrado, \(sport.title), vitória de \(team.name) por W.O."
            }
            return "Encerrado, \(sport.title), \(nameA) \(scoreA ?? 0), \(nameB) \(scoreB ?? 0)"
        }
    }
}
