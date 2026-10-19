import Foundation

// Classificação, Torcidômetro e perfil das atléticas ainda são 📝 no domínio
// (tabela de pontuação e desempate não definidos, P-08). Todos os números
// abaixo são FICTÍCIOS e servem só para o protótipo.

/// Posição de uma atlética na classificação geral da divisão.
struct RankingEntry: Identifiable, Hashable {
    var id: Athletic.ID { athletic.id }
    let athletic: Athletic
    /// Pontos iguais dividem a posição (hipótese do protótipo, como RN-49 nas provas).
    let position: Int
    let points: Int
    /// Outra atlética tem a mesma posição.
    let isTied: Bool
}

struct DivisionRanking: Identifiable, Hashable {
    var id: Division.ID { division.id }
    let division: Division
    /// Vazio = classificação da divisão ainda não disponível.
    let entries: [RankingEntry]
}

/// Situação da atlética numa modalidade (tela 12): até onde chegou no mata-mata
/// ou posição e marca na prova.
struct SportStanding: Identifiable, Hashable {
    var id: Competition.ID { competition.id }
    let competition: Competition
    let status: String
}

/// Dados da atlética que o domínio ainda não tem (descrição) ou que são 📝 (torcedores).
struct AthleticProfile {
    var description: String?
    var fanCount: Int?
}

extension MockData {
    // MARK: - Classificação geral (fictícia)

    private static let points: [Division.ID: [(Athletic.ID, Int)]] = [
        serieOuro.id: [("ath-imortal", 1420), ("ath-bufalos", 1345), ("ath-sanguinaria", 1210),
                       ("ath-lobos", 980), ("ath-tubaroes", 980), ("ath-corsarios", 860), ("ath-falcoes", 0)],
        seriePrata.id: [("ath-fanatica", 1120), ("ath-diastolica", 1040), ("ath-pantera", 1040),
                        ("ath-titas", 700), ("ath-poraque", 520), ("ath-raposas", 310)],
        // Série Bronze sem classificação, para testar a divisão sem dados.
    ]

    static let rankings: [DivisionRanking] = divisions.map { division in
        let rows = (points[division.id] ?? [])
            .map { (athletic: athletic($0.0), points: $0.1) }
            .sorted { $0.points != $1.points ? $0.points > $1.points
                : $0.athletic.name.localizedStandardCompare($1.athletic.name) == .orderedAscending }
        let entries = rows.map { row in
            let position = (rows.firstIndex { $0.points == row.points } ?? 0) + 1
            let isTied = rows.filter { $0.points == row.points }.count > 1
            return RankingEntry(athletic: row.athletic, position: position, points: row.points, isTied: isTied)
        }
        return DivisionRanking(division: division, entries: entries)
    }

    // MARK: - Por modalidade

    /// Modalidades que a atlética disputa, com a situação derivada da chave ou da prova.
    static func standings(for athleticID: Athletic.ID, matches: [Match]) -> [SportStanding] {
        competitions.compactMap { competition in
            guard competition.involves(athleticID, matches: matches) else { return nil }
            return SportStanding(competition: competition,
                                 status: competition.standing(of: athleticID, matches: matches) ?? "Inscrita")
        }
    }

    // MARK: - Perfil (fictício)

    private static let profiles: [Athletic.ID: AthleticProfile] = [
        "ath-bufalos": AthleticProfile(
            description: "Fundada pelos estudantes da Escola de Engenharia, a Búfalos reúne equipes de basquete, futsal e futebol society. A torcida é conhecida pela bateria que acompanha todos os jogos da atlética.",
            fanCount: 412),
        "ath-imortal": AthleticProfile(
            description: "Atlética da Faculdade de Medicina, com tradição no basquete e no vôlei. Organiza treinos abertos para calouros durante todo o semestre.",
            fanCount: 388),
        "ath-sanguinaria": AthleticProfile(description: nil, fanCount: 215),
        "ath-fanatica": AthleticProfile(
            description: "A Fanática representa a Faculdade de Administração e disputa o circuito desde a primeira edição.",
            fanCount: 240),
        "ath-diastolica": AthleticProfile(description: nil, fanCount: 120),
        "ath-severa": AthleticProfile(description: nil, fanCount: 97),
        "ath-nce": AthleticProfile(
            description: "Associação Atlética Acadêmica Nicolau Carvalho Esteves. Reúne estudantes de todos os cursos do campus e incentiva a participação feminina nas modalidades coletivas.",
            fanCount: 64),
    ]

    /// Atléticas sem perfil cadastrado ficam com descrição e torcedores vazios.
    static func profile(for athleticID: Athletic.ID) -> AthleticProfile {
        profiles[athleticID] ?? AthleticProfile()
    }
}
