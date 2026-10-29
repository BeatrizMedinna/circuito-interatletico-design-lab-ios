import Foundation

/// Dados locais da edição de exemplo usados pelo protótipo e pelos previews.
enum MockData {
    static let edition = Edition(name: "Copa Universitária")

    static let serieOuro = Division(id: "div-ouro", name: "Série Ouro", order: 1)
    static let seriePrata = Division(id: "div-prata", name: "Série Prata", order: 2)
    static let serieBronze = Division(id: "div-bronze", name: "Série Bronze", order: 3)

    /// Em ordem alfabética, como o onboarding exibe.
    static let athletics: [Athletic] = [
        Athletic(id: "ath-cca", name: "Atlética Acadêmica de Ciências Contábeis e Atuariais", acronym: "CCA",
                 institution: "Faculdade de Ciências Contábeis e Atuariais", division: serieBronze, colorHex: "2F80ED"),
        Athletic(id: "ath-corsarios", name: "Corsários", acronym: "ECO",
                 institution: "Faculdade de Economia", division: serieOuro, colorHex: "1B9AAA"),
        Athletic(id: "ath-falcoes", name: "Falcões", acronym: "FAR",
                 institution: "Faculdade de Farmácia", division: serieOuro, colorHex: "F2994A"),
        Athletic(id: "ath-lobos", name: "Lobos", acronym: "VET",
                 institution: "Faculdade de Medicina Veterinária", division: serieOuro, colorHex: "6FCF97"),
        Athletic(id: "ath-tubaroes", name: "Tubarões", acronym: "ODO",
                 institution: "Faculdade de Odontologia", division: serieOuro, colorHex: "2D9CDB"),
        Athletic(id: "ath-pantera", name: "Pantera", acronym: "ARQ",
                 institution: "Faculdade de Arquitetura e Urbanismo", division: seriePrata, colorHex: "BB6BD9"),
        Athletic(id: "ath-raposas", name: "Raposas", acronym: "LET",
                 institution: "Faculdade de Letras", division: seriePrata, colorHex: "E26D2C"),
        Athletic(id: "ath-titas", name: "Titãs", acronym: "FIS",
                 institution: "Instituto de Física", division: seriePrata, colorHex: "9B51E0"),
        Athletic(id: "ath-nce", name: "Atlética Acadêmica Nicolau Carvalho Esteves", acronym: "NCE",
                 institution: "Associação Atlética Acadêmica Nicolau Carvalho Esteves", division: serieBronze, colorHex: "27AE60"),
        Athletic(id: "ath-poraque", name: "Atlética Poraquê", acronym: "CMP",
                 institution: "Faculdade de Computação", division: seriePrata, colorHex: "56CCF2"),
        Athletic(id: "ath-bufalos", name: "Búfalos", acronym: "ENG",
                 institution: "Escola de Engenharia", division: serieOuro, colorHex: "D93A3A"),
        Athletic(id: "ath-diastolica", name: "Diastólica", acronym: "ENF",
                 institution: "Escola de Enfermagem", division: seriePrata, colorHex: "EB5757"),
        Athletic(id: "ath-fanatica", name: "Fanática", acronym: "ADM",
                 institution: "Faculdade de Administração", division: seriePrata, colorHex: "F2C94C"),
        Athletic(id: "ath-guerreira", name: "Guerreira", acronym: "EDF",
                 institution: "Faculdade de Educação Física", division: serieBronze, colorHex: "219653"),
        Athletic(id: "ath-imortal", name: "Imortal", acronym: "MED",
                 institution: "Faculdade de Medicina", division: serieOuro, colorHex: "7B3FE4"),
        Athletic(id: "ath-sanguinaria", name: "Sanguinária", acronym: "BIO",
                 institution: "Instituto de Biomedicina", division: serieOuro, colorHex: "F5C518"),
        Athletic(id: "ath-severa", name: "Severa", acronym: "DIR",
                 institution: "Faculdade de Direito", division: serieBronze, colorHex: "C0392B"),
    ].sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

    static let divisions = [serieOuro, seriePrata, serieBronze]
}
