import SwiftUI

// Tokens da média fidelidade: somente modo claro, branco, preto e cinzas.
// Os nomes são semânticos para que a alta fidelidade troque os valores
// (ex.: cores da edição) sem mexer nas telas.

extension ShapeStyle where Self == Color {
    /// Cabeçalhos e barras fixas.
    static var appBackground: Color { Color(white: 1.0) }
    /// Fundo do conteúdo rolável.
    static var canvas: Color { Color(white: 0.965) }
    /// Cartões, campos e linhas de lista.
    static var surface: Color { Color(white: 0.89) }
    /// Linha ou cartão selecionado (sempre junto com borda e ícone).
    static var surfaceSelected: Color { Color(white: 0.82) }

    static var textPrimary: Color { Color(white: 0.07) }
    /// Contraste mínimo de 4.5:1 sobre `surface`.
    static var textSecondary: Color { Color(white: 0.36) }
    static var textOnAccent: Color { Color(white: 1.0) }

    /// Borda de seleção e de botões secundários.
    static var borderStrong: Color { Color(white: 0.15) }
    /// Ação principal. (`accent` já é gerado pelo asset AccentColor, também preto.)
    static var actionPrimary: Color { Color(white: 0.10) }
    static var disabledFill: Color { Color(white: 0.80) }
    static var disabledText: Color { Color(white: 0.42) }
}

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum Radius {
    /// Campos e botões.
    static let control: CGFloat = 12
    /// Cartões e linhas de lista.
    static let card: CGFloat = 14
}
