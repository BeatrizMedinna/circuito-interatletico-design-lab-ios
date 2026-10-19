import Foundation

/// Momento da modalidade, usado na lista, no cabeçalho e na atlética.
enum CompetitionProgress: Hashable {
    /// Chave ou prova ainda não gerada pela organização.
    case notGenerated
    case notStarted(next: Date?)
    /// Eliminatória: fase atual. Classificatória: resultados parciais.
    case inProgress(phase: String)
    /// Campeã só no mata-mata (vencedora da final). Na prova, `nil`.
    case finished(champion: Athletic?)

    var label: String {
        switch self {
        case .notGenerated: "Chave ainda não definida"
        case .notStarted(let next):
            next.map { "Começa \(Formatters.dayLabel($0).lowercased()), \(Formatters.time($0))" } ?? "Ainda não começou"
        case .inProgress(let phase): phase
        case .finished(let champion): champion.map { "Encerrada · Campeã: \($0.name)" } ?? "Encerrada"
        }
    }

    /// Versão curta para a lista de Modalidades (sem datas). Na prova, diz "Prova…"
    /// para o formato ficar implícito sem mais uma linha.
    func shortLabel(isElimination: Bool) -> String {
        switch self {
        case .notGenerated: isElimination ? "Chave a definir" : "Prova a definir"
        case .notStarted: isElimination ? "A iniciar" : "Prova a iniciar"
        case .inProgress(let phase): isElimination ? phase : "Prova com resultados parciais"
        case .finished(let champion):
            isElimination ? (champion.map { "Campeã: \($0.name)" } ?? "Encerrada") : "Prova encerrada"
        }
    }
}

/// Situação da atlética na modalidade (aba Classificação do mata-mata e aba
/// Modalidades da atlética). No mata-mata não há pontos: mostra até onde chegou.
struct CampaignEntry: Identifiable, Hashable {
    var id: Athletic.ID { athletic.id }
    let athletic: Athletic
    /// Só campeã (1º) e vice (2º) têm posição.
    let position: Int?
    let status: String
    let isAlive: Bool
    fileprivate let sortKey: [Int]
}

extension Competition {
    // MARK: - Chave

    func rounds(matches: [Match]) -> [BracketRound] {
        if let explicit = MockData.explicitBrackets[id] { return explicit }
        let own = matches.filter(includes)
        guard !own.isEmpty else { return [] }
        var rounds = Dictionary(grouping: own, by: \.phase)
            .sorted { Phase.index($0.key) < Phase.index($1.key) }
            .map { BracketRound(phase: $0.key, matchups: $0.value.map { BracketMatchup(id: $0.id, matchID: $0.id) }) }
        // Completa as fases seguintes, até a final, com confrontos a definir.
        while let last = rounds.last, let next = Phase.next(after: last.phase) {
            let count = max(1, (last.matchups.count + 1) / 2)
            rounds.append(BracketRound(phase: next, matchups: (0..<count).map {
                BracketMatchup(id: "\(id)-\(next)-\($0)")
            }))
        }
        return rounds
    }

    func match(of matchup: BracketMatchup, in matches: [Match]) -> Match? {
        matchup.matchID.flatMap { id in matches.first { $0.id == id } }
    }

    func teams(of matchup: BracketMatchup, in matches: [Match]) -> (a: Athletic?, b: Athletic?) {
        if let match = match(of: matchup, in: matches) { return (match.teamA, match.teamB) }
        return (matchup.teamA, matchup.teamB)
    }

    func winner(of matchup: BracketMatchup, in matches: [Match]) -> Athletic? {
        if matchup.isBye { return matchup.teamA }
        guard let match = match(of: matchup, in: matches), let side = match.winner else { return nil }
        return match.team(side)
    }

    func hasLiveMatch(in matches: [Match]) -> Bool {
        matches.contains { includes($0) && $0.status == .live }
    }

    // MARK: - Momento

    func progress(matches: [Match]) -> CompetitionProgress {
        switch format {
        case .elimination:
            let rounds = rounds(matches: matches)
            guard !rounds.isEmpty else { return .notGenerated }
            let own = matches.filter(includes)
            if !own.contains(where: { $0.status != .scheduled }) {
                return .notStarted(next: own.map(\.startDate).min())
            }
            if let final = rounds.last, final.phase == "Final", let decider = final.matchups.first,
               let champion = winner(of: decider, in: matches) {
                return .finished(champion: champion)
            }
            let current = rounds.first { round in
                round.matchups.contains { winner(of: $0, in: matches) == nil }
            }
            return .inProgress(phase: current?.phase ?? rounds.last?.phase ?? "")
        case .ranking:
            guard let trial else { return .notGenerated }
            if trial.isClosed { return .finished(champion: nil) }
            if trial.hasPartialResults { return .inProgress(phase: "Resultados parciais") }
            return .notStarted(next: trial.startDate)
        }
    }

    // MARK: - Campanha no mata-mata

    func campaign(matches: [Match]) -> [CampaignEntry] {
        let rounds = rounds(matches: matches)
        var deepest: [Athletic.ID: (athletic: Athletic, round: Int, won: Bool?, lostFinal: Bool)] = [:]
        for (index, round) in rounds.enumerated() {
            for matchup in round.matchups {
                let teams = teams(of: matchup, in: matches)
                let winner = winner(of: matchup, in: matches)
                for team in [teams.a, teams.b].compactMap({ $0 }) {
                    let won: Bool? = winner.map { $0.id == team.id }
                    deepest[team.id] = (team, index, won, round.phase == "Final" && won == false)
                }
            }
        }
        return deepest.values.map { item in
            let phase = rounds[item.round].phase
            let isFinal = phase == "Final"
            switch (item.won, isFinal) {
            case (true, true):
                return CampaignEntry(athletic: item.athletic, position: 1, status: "Campeã", isAlive: false, sortKey: [0, 0])
            case (false, true):
                return CampaignEntry(athletic: item.athletic, position: 2, status: "Vice-campeã", isAlive: false, sortKey: [1, 0])
            case (false, _):
                return CampaignEntry(athletic: item.athletic, position: nil,
                                     status: "Eliminada \(Phase.withPreposition(phase))", isAlive: false,
                                     sortKey: [3, -item.round])
            default:
                // Venceu e aguarda a próxima fase, ou ainda disputa esta.
                let alivePhase = item.won == true ? (Phase.next(after: phase) ?? phase) : phase
                let status = Phase.withPreposition(alivePhase)
                return CampaignEntry(athletic: item.athletic, position: nil,
                                     status: status.prefix(1).uppercased() + status.dropFirst(), isAlive: true,
                                     sortKey: [2, -Phase.index(alivePhase)])
            }
        }
        .sorted { $0.sortKey != $1.sortKey ? $0.sortKey.lexicographicallyPrecedes($1.sortKey)
            : $0.athletic.name.localizedStandardCompare($1.athletic.name) == .orderedAscending }
    }

    // MARK: - Situação de uma atlética

    /// Texto curto da atlética nesta modalidade (aba Modalidades da atlética).
    func standing(of athleticID: Athletic.ID, matches: [Match]) -> String? {
        switch format {
        case .elimination:
            return campaign(matches: matches).first { $0.athletic.id == athleticID }?.status
        case .ranking(let criterion, let unit, _):
            guard let trial, trial.participants.contains(where: { $0.id == athleticID }) else { return nil }
            let ranked = trial.ranked(by: criterion).filter { $0.result.athletic.id == athleticID }
            if let best = ranked.first(where: { $0.position != nil }), let position = best.position,
               let mark = best.result.mark {
                return "\(position)º lugar · \(unit.format(mark))" + (trial.isClosed ? "" : " (parcial)")
            }
            if let other = ranked.first { return other.result.situation.label }
            return trial.isClosed ? "Sem resultado" : "Aguardando resultado"
        }
    }

    func involves(_ athleticID: Athletic.ID, matches: [Match]) -> Bool {
        switch format {
        case .elimination: standing(of: athleticID, matches: matches) != nil
        case .ranking: trial?.participants.contains { $0.id == athleticID } ?? false
        }
    }
}
