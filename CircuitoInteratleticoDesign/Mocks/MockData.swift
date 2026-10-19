/// Dados locais da edição de exemplo usados pelo protótipo e pelos previews.
enum MockData {
    static let edition = Edition(name: "Copa Universitária")

    static let serieOuro = Division(id: "div-ouro", name: "Série Ouro", order: 1)
    static let seriePrata = Division(id: "div-prata", name: "Série Prata", order: 2)
    static let serieBronze = Division(id: "div-bronze", name: "Série Bronze", order: 3)

    /// Em ordem alfabética, como o onboarding exibe.
    static let athletics: [Athletic] = [
        Athletic(id: "ath-nce", name: "Atlética Acadêmica Nicolau Carvalho Esteves", acronym: "NCE",
                 institution: "Associação Atlética Acadêmica Nicolau Carvalho Esteves", division: serieBronze),
        Athletic(id: "ath-poraque", name: "Atlética Poraquê", acronym: "CMP",
                 institution: "Faculdade de Computação", division: seriePrata),
        Athletic(id: "ath-bufalos", name: "Búfalos", acronym: "ENG",
                 institution: "Escola de Engenharia", division: serieOuro),
        Athletic(id: "ath-diastolica", name: "Diastólica", acronym: "ENF",
                 institution: "Escola de Enfermagem", division: seriePrata),
        Athletic(id: "ath-fanatica", name: "Fanática", acronym: "ADM",
                 institution: "Faculdade de Administração", division: seriePrata),
        Athletic(id: "ath-guerreira", name: "Guerreira", acronym: "EDF",
                 institution: "Faculdade de Educação Física", division: serieBronze),
        Athletic(id: "ath-imortal", name: "Imortal", acronym: "MED",
                 institution: "Faculdade de Medicina", division: serieOuro),
        Athletic(id: "ath-sanguinaria", name: "Sanguinária", acronym: "BIO",
                 institution: "Instituto de Biomedicina", division: serieOuro),
        Athletic(id: "ath-severa", name: "Severa", acronym: "DIR",
                 institution: "Faculdade de Direito", division: serieBronze),
    ]
}
