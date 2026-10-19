import Foundation

// Partidas e avisos de exemplo. As datas são relativas a "agora" para que
// "Hoje", "Ontem" e "Amanhã" façam sentido sempre que o protótipo abrir.
// A Atlética Poraquê não tem jogos, para testar o estado vazio de "Minha atlética".

extension MockData {
    static func athletic(_ id: Athletic.ID) -> Athletic {
        athletics.first { $0.id == id }!
    }

    // MARK: - Modalidades

    static let basketballMale = Sport(name: "Basquete", gender: .male, symbol: "figure.basketball", periodAbbreviation: "Q")
    static let futsalFemale = Sport(name: "Futsal", gender: .female, symbol: "figure.indoor.soccer", periodAbbreviation: "T")
    static let futsalMale = Sport(name: "Futsal", gender: .male, symbol: "figure.indoor.soccer", periodAbbreviation: "T")
    static let volleyballFemale = Sport(name: "Vôlei", gender: .female, symbol: "figure.volleyball", periodAbbreviation: "Set")
    static let volleyballMale = Sport(name: "Vôlei", gender: .male, symbol: "figure.volleyball", periodAbbreviation: "Set")
    static let handballMale = Sport(name: "Handebol", gender: .male, symbol: "figure.handball", periodAbbreviation: "T")
    static let handballFemale = Sport(name: "Handebol", gender: .female, symbol: "figure.handball", periodAbbreviation: "T")
    static let societyMale = Sport(name: "Futebol Society", gender: .male, symbol: "figure.soccer", periodAbbreviation: "T")
    static let basketballFemale = Sport(name: "Basquete", gender: .female, symbol: "figure.basketball", periodAbbreviation: "Q")
    static let tableTennisMixed = Sport(name: "Tênis de Mesa", gender: .mixed, symbol: "figure.table.tennis", periodAbbreviation: "Set")

    // MARK: - Datas

    private static func minutesFromNow(_ minutes: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(minutes * 60))
    }

    /// Início de slot (:00 ou :30) perto de `minutes` a partir de agora:
    /// o próximo, para jogos futuros; o anterior, para jogos que já começaram.
    private static func slotFromNow(_ minutes: Int) -> Date {
        let date = minutesFromNow(minutes)
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)
        let base = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: 0, second: 0, of: date)!
        let offset: Int
        if minutes >= 0 {
            offset = minute == 0 ? 0 : (minute <= 30 ? 30 : 60)
        } else {
            offset = minute < 30 ? 0 : 30
        }
        return base.addingTimeInterval(TimeInterval(offset * 60))
    }

    private static func day(_ offset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .day, value: offset, to: Date())!
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base)!
    }

    private static let mainGym = "Ginásio Principal"
    private static let school = "EMEF Cecília de Nazaré da Fonseca"
    private static let annexCourt = "Quadra Anexa — Centro Esportivo Universitário"

    // MARK: - Partidas

    static let matches: [Match] = [
        // Ao vivo
        Match(id: "m-live-basquete", sport: basketballMale, division: serieOuro, phase: "Semifinal",
              venue: school, startDate: slotFromNow(-40), status: .live,
              teamA: athletic("ath-bufalos"), teamB: athletic("ath-imortal"),
              scoreA: 72, scoreB: 70,
              periods: [PeriodScore(number: 1, a: 20, b: 22), PeriodScore(number: 2, a: 21, b: 15),
                        PeriodScore(number: 3, a: 19, b: 23), PeriodScore(number: 4, a: 12, b: 10)],
              currentPeriod: 4, clock: "04:55",
              plays: [
                Play(id: "p1", period: 1, minute: "2'", side: .b, description: "+2 pontos", athleteName: "Caio Mendes", scoreA: 0, scoreB: 2),
                Play(id: "p2", period: 1, minute: "4'", side: .a, description: "+3 pontos", athleteName: "Rafael Lima", scoreA: 3, scoreB: 2),
                Play(id: "p3", period: 1, minute: "9'", side: .b, description: "Falta pessoal", athleteName: "Diego Souza", scoreA: 18, scoreB: 22),
                Play(id: "p4", period: 2, minute: "3'", side: .a, description: "+2 pontos", athleteName: "Rafael Lima", scoreA: 24, scoreB: 24),
                Play(id: "p5", period: 2, minute: "6'", side: .a, description: "+3 pontos", athleteName: "Bruno Alves", scoreA: 33, scoreB: 30),
                Play(id: "p6", period: 2, minute: "9'", side: .b, description: "Pedido de tempo", scoreA: 39, scoreB: 35),
                Play(id: "p7", period: 3, minute: "5'", side: .b, description: "+3 pontos", athleteName: "Caio Mendes", scoreA: 50, scoreB: 49),
                Play(id: "p8", period: 3, minute: "8'", side: .a, description: "Falta técnica", athleteName: "Pedro Rocha", scoreA: 56, scoreB: 55),
                Play(id: "p9", period: 4, minute: "2'", side: .a, description: "+2 pontos", athleteName: "Bruno Alves", scoreA: 64, scoreB: 62),
                Play(id: "p10", period: 4, minute: "4'", side: .b, description: "+1 ponto", athleteName: "Diego Souza", scoreA: 70, scoreB: 70),
                Play(id: "p11", period: 4, minute: "5'", side: .a, description: "+2 pontos", athleteName: "Rafael Lima", scoreA: 72, scoreB: 70),
              ]),
        Match(id: "m-live-volei", sport: volleyballFemale, division: seriePrata, phase: "Quartas de final",
              venue: mainGym, startDate: slotFromNow(-55), status: .live,
              teamA: athletic("ath-diastolica"), teamB: athletic("ath-fanatica"),
              scoreA: 1, scoreB: 1,
              periods: [PeriodScore(number: 1, a: 25, b: 21), PeriodScore(number: 2, a: 19, b: 25),
                        PeriodScore(number: 3, a: 14, b: 12)],
              currentPeriod: 3, clock: nil,
              plays: [
                Play(id: "v1", period: 3, side: .a, description: "Ponto no set", athleteName: "Luana Prado", scoreA: 1, scoreB: 1),
                Play(id: "v2", period: 3, side: .b, description: "Pedido de tempo", scoreA: 1, scoreB: 1),
              ]),
        Match(id: "m-live-futsal", sport: futsalFemale, division: serieBronze, phase: "Quartas de final",
              venue: annexCourt, startDate: slotFromNow(-15), status: .live,
              teamA: athletic("ath-guerreira"), teamB: athletic("ath-severa"),
              scoreA: 0, scoreB: 0, periods: [PeriodScore(number: 1, a: 0, b: 0)],
              currentPeriod: 1, clock: "12:30", plays: []),

        // A iniciar
        Match(id: "m-up-futsal", sport: futsalFemale, division: serieOuro, phase: "Quartas de final",
              venue: mainGym, startDate: slotFromNow(90), status: .scheduled,
              teamA: athletic("ath-bufalos"), teamB: athletic("ath-sanguinaria")),
        Match(id: "m-up-handebol", sport: handballMale, division: seriePrata, phase: "Quartas de final",
              venue: annexCourt, startDate: slotFromNow(180), status: .scheduled,
              teamA: athletic("ath-diastolica"), teamB: athletic("ath-fanatica")),
        Match(id: "m-up-final", sport: basketballMale, division: serieOuro, phase: "Final",
              venue: mainGym, startDate: day(1, 10), status: .scheduled,
              teamA: nil, teamB: athletic("ath-sanguinaria")),
        Match(id: "m-up-volei", sport: volleyballMale, division: serieBronze, phase: "Semifinal",
              venue: school, startDate: day(1, 14), status: .scheduled,
              teamA: athletic("ath-nce"), teamB: athletic("ath-guerreira")),
        Match(id: "m-up-society", sport: societyMale, division: serieOuro, phase: "Oitavas de final",
              venue: annexCourt, startDate: day(2, 9), status: .scheduled,
              teamA: athletic("ath-imortal"), teamB: athletic("ath-bufalos")),

        Match(id: "m-up-volei-ouro", sport: volleyballFemale, division: serieOuro, phase: "Quartas de final",
              venue: mainGym, startDate: slotFromNow(180), status: .scheduled,
              teamA: athletic("ath-imortal"), teamB: athletic("ath-sanguinaria")),
        Match(id: "m-up-futsal-bronze", sport: futsalMale, division: serieBronze, phase: "Semifinal",
              venue: annexCourt, startDate: day(1, 10), status: .scheduled,
              teamA: athletic("ath-severa"), teamB: athletic("ath-nce")),
        Match(id: "m-up-basquete-fem", sport: basketballFemale, division: serieOuro, phase: "Semifinal",
              venue: school, startDate: day(2, 14), status: .scheduled,
              teamA: athletic("ath-bufalos"), teamB: nil),
        Match(id: "m-up-handebol-fem", sport: handballFemale, division: seriePrata, phase: "Semifinal",
              venue: mainGym, startDate: day(2, 16, 30), status: .scheduled,
              teamA: athletic("ath-fanatica"), teamB: athletic("ath-diastolica")),

        // Encerradas
        Match(id: "m-fin-tenis", sport: tableTennisMixed, division: serieBronze, phase: "Final",
              venue: mainGym, startDate: slotFromNow(-200), status: .finished,
              teamA: athletic("ath-severa"), teamB: athletic("ath-nce"),
              scoreA: 3, scoreB: 2,
              periods: [PeriodScore(number: 1, a: 11, b: 8), PeriodScore(number: 2, a: 9, b: 11),
                        PeriodScore(number: 3, a: 11, b: 6), PeriodScore(number: 4, a: 7, b: 11),
                        PeriodScore(number: 5, a: 11, b: 9)],
              plays: [
                Play(id: "t1", period: 5, side: .a, description: "Set vencido", scoreA: 3, scoreB: 2),
                Play(id: "t2", period: 4, side: .b, description: "Set vencido", scoreA: 2, scoreB: 2),
              ]),
        Match(id: "m-fin-futsal", sport: futsalFemale, division: serieOuro, phase: "Oitavas de final",
              venue: mainGym, startDate: day(-1, 15), status: .finished,
              teamA: athletic("ath-bufalos"), teamB: athletic("ath-imortal"),
              scoreA: 3, scoreB: 1,
              periods: [PeriodScore(number: 1, a: 1, b: 1), PeriodScore(number: 2, a: 2, b: 0)],
              plays: [
                Play(id: "f1", period: 1, minute: "6'", side: .a, description: "Gol", athleteName: "Ana Ribeiro", scoreA: 1, scoreB: 0),
                Play(id: "f2", period: 1, minute: "14'", side: .b, description: "Gol", athleteName: "Júlia Martins", scoreA: 1, scoreB: 1),
                Play(id: "f3", period: 1, minute: "17'", side: .b, description: "Cartão amarelo", athleteName: "Carla Dias", scoreA: 1, scoreB: 1),
                Play(id: "f4", period: 2, minute: "3'", side: .a, description: "Gol", athleteName: "Ana Ribeiro", scoreA: 2, scoreB: 1),
                Play(id: "f5", period: 2, minute: "18'", side: .a, description: "Gol", athleteName: "Marina Costa", scoreA: 3, scoreB: 1),
              ]),
        Match(id: "m-fin-basquete", sport: basketballMale, division: serieOuro, phase: "Quartas de final",
              venue: school, startDate: day(-1, 10), status: .finished,
              teamA: athletic("ath-bufalos"), teamB: athletic("ath-sanguinaria"),
              scoreA: 64, scoreB: 58,
              periods: [PeriodScore(number: 1, a: 14, b: 16), PeriodScore(number: 2, a: 18, b: 12),
                        PeriodScore(number: 3, a: 15, b: 17), PeriodScore(number: 4, a: 17, b: 13)],
              plays: [
                Play(id: "b1", period: 4, minute: "9'", side: .a, description: "+3 pontos", athleteName: "Rafael Lima", scoreA: 64, scoreB: 58),
                Play(id: "b2", period: 4, minute: "7'", side: .b, description: "+2 pontos", athleteName: "Igor Nunes", scoreA: 61, scoreB: 58),
              ]),
        Match(id: "m-fin-handebol-wo", sport: handballFemale, division: seriePrata, phase: "Oitavas de final",
              venue: annexCourt, startDate: day(-2, 16), status: .finished,
              teamA: athletic("ath-fanatica"), teamB: athletic("ath-diastolica"),
              walkoverWinner: .a),
        Match(id: "m-fin-futsal-sem-lances", sport: futsalMale, division: serieBronze, phase: "Oitavas de final",
              venue: school, startDate: day(-2, 11), status: .finished,
              teamA: athletic("ath-guerreira"), teamB: athletic("ath-nce"),
              scoreA: 2, scoreB: 0),
    ]

    /// Dias do cronograma publicado (data inicial a final). O último não tem jogos,
    /// para testar o dia vazio.
    static let scheduleDays: [Date] = (-2...3).map { offset in
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: offset, to: Date())!)
    }

    // MARK: - Avisos

    static let notifications: [AppNotification] = [
        AppNotification(id: "n-comeca", kind: .startingSoon, title: "Vai começar!",
                        message: "Búfalos entra em quadra agora pelo Basquete Masculino. Acompanhe o placar ao vivo no app.",
                        date: slotFromNow(-40), matchID: "m-live-basquete",
                        athleticIDs: ["ath-bufalos", "ath-imortal"]),
        AppNotification(id: "n-local", kind: .venueChange, title: "Mudança de local",
                        message: "O jogo de Futsal Feminino (Búfalos x Sanguinária) foi transferido para o Ginásio Principal. Começa às \(Formatters.time(slotFromNow(90))).",
                        date: minutesFromNow(-75), matchID: "m-up-futsal",
                        athleticIDs: ["ath-bufalos", "ath-sanguinaria"]),
        AppNotification(id: "n-horario", kind: .timeChange, title: "Mudança de horário",
                        message: "Handebol Masculino (Diastólica x Fanática) agora começa às \(Formatters.time(slotFromNow(180))).",
                        date: minutesFromNow(-130), matchID: "m-up-handebol",
                        athleticIDs: ["ath-diastolica", "ath-fanatica"]),
        AppNotification(id: "n-campeao", kind: .champion, title: "É campeão!",
                        message: "Severa venceu a Final e garantiu o troféu do Tênis de Mesa Misto (Série Bronze)!",
                        date: minutesFromNow(-150), matchID: "m-fin-tenis",
                        athleticIDs: ["ath-severa", "ath-nce"]),
        AppNotification(id: "n-torcida", kind: .fanMeter, title: "Ultrapassagem no ranking",
                        message: "Búfalos assumiu a liderança do Torcidômetro.",
                        date: day(-1, 20, 15), athleticIDs: ["ath-bufalos"]),
        AppNotification(id: "n-comeca-ontem", kind: .startingSoon, title: "Vai começar!",
                        message: "Búfalos entra em quadra agora pelo Futsal Feminino. Acompanhe o placar ao vivo no app.",
                        date: day(-1, 15), matchID: "m-fin-futsal",
                        athleticIDs: ["ath-bufalos", "ath-imortal"]),
    ]
}
