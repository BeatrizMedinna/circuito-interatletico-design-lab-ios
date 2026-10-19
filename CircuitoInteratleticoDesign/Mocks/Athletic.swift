import Foundation

// Tipos simples para a interface; não espelham as tabelas da API.

struct Edition: Hashable {
    let name: String
}

/// Divisão da edição. O nome é livre (ex.: "Série Ouro") e a ordem define a exibição.
struct Division: Identifiable, Hashable {
    let id: String
    let name: String
    let order: Int
}

struct Athletic: Identifiable, Hashable {
    let id: String
    let name: String
    let acronym: String
    let institution: String
    let division: Division
}
