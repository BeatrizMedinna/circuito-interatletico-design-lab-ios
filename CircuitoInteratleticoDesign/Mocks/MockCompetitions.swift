import Foundation

// Modalidades da edição de exemplo. As eliminatórias saem das partidas mockadas
// (uma por modalidade + divisão); duas têm chave completa escrita à mão (com bye
// e confrontos a definir). As classificatórias têm uma prova cada.
// Marcas, inscritos e nomes de atletas são FICTÍCIOS.

extension MockData {
    static let swimmingMale = Sport(name: "Natação", gender: .male, symbol: "figure.pool.swim", periodAbbreviation: "")
    static let swimmingFemale = Sport(name: "Natação", gender: .female, symbol: "figure.pool.swim", periodAbbreviation: "")
    static let athleticsFemale = Sport(name: "Atletismo", gender: .female, symbol: "figure.run", periodAbbreviation: "")
    static let chessMixed = Sport(name: "Xadrez", gender: .mixed, symbol: "checkerboard.rectangle", periodAbbreviation: "")

    static func competitionID(_ sport: Sport, _ division: Division, event: String? = nil) -> Competition.ID {
        ["c", sport.title, division.id, event].compactMap { $0 }.joined(separator: "|")
    }

    static func competition(for match: Match) -> Competition? {
        competitions.first { $0.includes(match) }
    }

    // MARK: - Chaves completas (com bye e "a definir")

    static let explicitBrackets: [Competition.ID: [BracketRound]] = [
        competitionID(basketballMale, serieOuro): [
            BracketRound(phase: "Quartas de final", matchups: [
                BracketMatchup(id: "bm-q1", matchID: "m-fin-basquete"),
                BracketMatchup(id: "bm-q2", teamA: athletic("ath-imortal"), isBye: true),
                BracketMatchup(id: "bm-q3", matchID: "m-fin-basquete-q3"),
                BracketMatchup(id: "bm-q4", matchID: "m-fin-basquete-q4"),
            ]),
            BracketRound(phase: "Semifinal", matchups: [
                BracketMatchup(id: "bm-s1", matchID: "m-live-basquete"),
                BracketMatchup(id: "bm-s2", matchID: "m-fin-basquete-s2"),
            ]),
            BracketRound(phase: "Final", matchups: [
                BracketMatchup(id: "bm-f", matchID: "m-up-final"),
            ]),
        ],
        competitionID(futsalFemale, serieOuro): [
            BracketRound(phase: "Quartas de final", matchups: [
                BracketMatchup(id: "ff-q1", matchID: "m-fin-futsal"),
                BracketMatchup(id: "ff-q2", teamA: athletic("ath-sanguinaria"), isBye: true),
                BracketMatchup(id: "ff-q3", matchID: "m-fin-futsal-wo"),
                BracketMatchup(id: "ff-q4", matchID: "m-up-futsal-q4"),
            ]),
            BracketRound(phase: "Semifinal", matchups: [
                BracketMatchup(id: "ff-s1", matchID: "m-up-futsal"),
                BracketMatchup(id: "ff-s2", teamA: athletic("ath-lobos")),
            ]),
            BracketRound(phase: "Final", matchups: [
                BracketMatchup(id: "ff-f"),
            ]),
        ],
    ]

    // MARK: - Provas (classificatórias)

    private static let pool = "Piscina Olímpica do Campus"
    private static let track = "Pista de Atletismo — Centro Esportivo"

    private static var trialCompetitions: [Competition] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        func at(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
            calendar.date(byAdding: .minute, value: dayOffset * 24 * 60 + hour * 60 + minute, to: today)!
        }
        let ouro = athletics.filter { $0.division.id == serieOuro.id }
        let prata = athletics.filter { $0.division.id == seriePrata.id }
        let bronze = athletics.filter { $0.division.id == serieBronze.id }

        return [
            // Encerrada, com empate, ausente e desclassificado.
            Competition(id: competitionID(swimmingMale, serieOuro, event: "50m livre"), sport: swimmingMale,
                        eventName: "50m livre", division: serieOuro,
                        format: .ranking(criterion: .lowerWins, unit: .time, isTeamEvent: false),
                        registeredAthletes: 7,
                        trial: Trial(startDate: at(-1, 9), venue: pool, isClosed: true, participants: ouro, results: [
                            TrialResult(id: "r1", athleteName: "Rafael Lima", athletic: athletic("ath-bufalos"), mark: 28.41),
                            TrialResult(id: "r2", athleteName: "Caio Mendes", athletic: athletic("ath-imortal"), mark: 27.95),
                            TrialResult(id: "r3", athleteName: "Pedro Rocha", athletic: athletic("ath-bufalos"), mark: 29.10),
                            TrialResult(id: "r4", athleteName: "Igor Nunes", athletic: athletic("ath-sanguinaria"), mark: 28.41),
                            TrialResult(id: "r5", athleteName: "Léo Souza", athletic: athletic("ath-lobos"), situation: .absent),
                            TrialResult(id: "r6", athleteName: "Davi Prado", athletic: athletic("ath-tubaroes"), situation: .disqualified),
                            TrialResult(id: "r7", athleteName: "Hugo Reis", athletic: athletic("ath-corsarios"), mark: 30.02),
                        ])),
            // Em andamento: resultados parciais, uma desistência e inscritas sem marca.
            Competition(id: competitionID(athleticsFemale, seriePrata, event: "Salto em distância"), sport: athleticsFemale,
                        eventName: "Salto em distância", division: seriePrata,
                        format: .ranking(criterion: .higherWins, unit: .distance, isTeamEvent: false),
                        registeredAthletes: 6,
                        trial: Trial(startDate: MockData.slotStart(minutesAgo: 30), venue: track, isClosed: false,
                                     participants: prata, results: [
                            TrialResult(id: "a1", athleteName: "Ana Ribeiro", athletic: athletic("ath-fanatica"), mark: 5.12),
                            TrialResult(id: "a2", athleteName: "Beatriz Alves", athletic: athletic("ath-diastolica"), mark: 4.98),
                            TrialResult(id: "a3", athleteName: "Carla Dias", athletic: athletic("ath-pantera"), situation: .retired),
                        ])),
            // Agendada, por equipe, sem resultados.
            Competition(id: competitionID(swimmingFemale, serieBronze, event: "Revezamento 4x50m livre"), sport: swimmingFemale,
                        eventName: "Revezamento 4x50m livre", division: serieBronze,
                        format: .ranking(criterion: .lowerWins, unit: .time, isTeamEvent: true),
                        registeredAthletes: 16,
                        trial: Trial(startDate: at(1, 16), venue: pool, isClosed: false, participants: bronze)),
        ]
    }

    /// Início de slot (:00 ou :30) que já passou, perto de `minutesAgo` minutos atrás.
    static func slotStart(minutesAgo: Int) -> Date {
        let date = Date().addingTimeInterval(TimeInterval(-minutesAgo * 60))
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)
        let base = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: 0, second: 0, of: date)!
        return base.addingTimeInterval(TimeInterval((minute < 30 ? 0 : 30) * 60))
    }

    // MARK: - Lista

    static let competitions: [Competition] = {
        var seen = Set<Competition.ID>()
        let elimination = matches.compactMap { match -> Competition? in
            let id = competitionID(match.sport, match.division)
            guard seen.insert(id).inserted else { return nil }
            let teams = Set(matches.filter { $0.sport.title == match.sport.title && $0.division.id == match.division.id }
                .flatMap { [$0.teamA?.id, $0.teamB?.id].compactMap { $0 } })
            return Competition(id: id, sport: match.sport, division: match.division, format: .elimination,
                               registeredAthletes: max(teams.count, 2) * 9)
        }
        // Eliminatória ainda sem chave gerada.
        let chess = Competition(id: competitionID(chessMixed, serieOuro), sport: chessMixed, division: serieOuro,
                                format: .elimination, registeredAthletes: 12)
        return (elimination + trialCompetitions + [chess]).sorted {
            $0.title != $1.title ? $0.title.localizedStandardCompare($1.title) == .orderedAscending
                : $0.division.order < $1.division.order
        }
    }()
}
