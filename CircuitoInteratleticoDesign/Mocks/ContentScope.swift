import Foundation

/// Recorte de conteúdo no app (Início, Notificações, Modalidades):
/// focado na atlética de coração ou visão geral de todas as atléticas.
enum ContentScope: Hashable, CaseIterable {
    case favorite, general

    var title: String {
        switch self {
        case .favorite: "Minha atlética"
        case .general: "Geral"
        }
    }
}

/// Compatibilidade retroativa para código legado da Home
typealias HomeScope = ContentScope
