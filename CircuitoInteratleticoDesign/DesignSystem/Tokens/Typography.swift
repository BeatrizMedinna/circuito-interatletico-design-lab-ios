import SwiftUI

// Estilos de texto do app. Todos partem dos estilos do sistema (SF Pro), então
// acompanham o Dynamic Type. Números esportivos usam SF Pro Rounded pesado e
// dígitos de largura fixa, para placares e posições não "pularem".

extension Font {
    /// Placar do cabeçalho da partida.
    static let scoreLarge = Font.system(.largeTitle, design: .rounded, weight: .heavy)
    /// Placar dos cartões compactos.
    static let scoreCompact = Font.system(.title2, design: .rounded, weight: .bold)
    /// Posições, pontos e números de destaque (ranking, pódio, resumos).
    static func sportNumber(_ style: Font.TextStyle = .headline) -> Font {
        .system(style, design: .rounded, weight: .bold)
    }
    /// Título de seção ("Próximos jogos", "Informações").
    static let sectionTitle = Font.title3.bold()
    /// Rótulos em caixa alta (status e cabeçalho de cartão). Usar com `.tracking(0.6)`.
    static let eyebrow = Font.caption2.weight(.bold)
}
