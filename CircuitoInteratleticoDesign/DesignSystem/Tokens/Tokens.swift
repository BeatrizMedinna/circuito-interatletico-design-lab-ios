import SwiftUI

// Tokens de cor da alta fidelidade. Cada um lê um Color Set em
// Assets.xcassets/Palette com variantes clara, escura e de alto contraste.
// O app roda fixo no escuro (Info.plist); as variantes claras existem para o
// Liquid Glass se adaptar e para um futuro "seguir o sistema" sem retrabalho.
// Os nomes antigos foram mantidos: as telas não precisaram mudar.

extension ShapeStyle where Self == Color {
    // MARK: Superfícies

    /// Cabeçalhos e barras fixas.
    static var appBackground: Color { Color(.paletteBase) }
    /// Fundo do conteúdo rolável.
    static var canvas: Color { Color(.paletteBase) }
    /// Cartões, campos e linhas de lista.
    static var surface: Color { Color(.paletteSurface1) }
    /// Elementos dentro de cartões (chips, caixas internas, botões de ícone).
    static var surfaceInset: Color { Color(.paletteSurface2) }
    /// Linha ou cartão selecionado (sempre junto com borda e ícone).
    static var surfaceSelected: Color { Color(.paletteSurface3) }
    /// Linhas finas entre itens (decorativo).
    static var separatorLine: Color { Color(.paletteSeparator) }
    /// Borda de seleção e de botões secundários (3:1 ou mais sobre o fundo).
    static var borderStrong: Color { Color(.paletteBorderStrong) }

    // MARK: Texto

    static var textPrimary: Color { Color(.paletteTextPrimary) }
    /// 7:1 ou mais sobre fundo e superfícies.
    static var textSecondary: Color { Color(.paletteTextSecondary) }
    /// Perdedor, "a definir", desabilitado. 4,5:1 sobre fundo, superfície e superfície interna.
    static var textTertiary: Color { Color(.paletteTextTertiary) }
    /// Texto e ícones sobre `actionPrimary` (On Lime).
    static var textOnAccent: Color { Color(.paletteOnBrand) }

    // MARK: Marca

    /// Preenchimento da ação principal e da seleção (Lime). Texto por cima: `textOnAccent`.
    static var actionPrimary: Color { Color(.paletteBrandFill) }
    /// Lime como texto ou ícone interativo (Lime Strong na variante clara).
    static var brandPrimary: Color { Color(.paletteBrand) }
    /// Tudo que é da atlética de coração (Teal). Não usar como sucesso.
    static var favoriteAccent: Color { Color(.paletteFavorite) }

    // MARK: Estados (sempre com ícone, rótulo ou borda além da cor)

    static var live: Color { Color(.paletteLive) }
    static var success: Color { Color(.paletteSuccess) }
    static var warning: Color { Color(.paletteWarning) }
    static var critical: Color { Color(.paletteCritical) }

    // MARK: Desabilitado

    static var disabledFill: Color { Color(.paletteSurface2) }
    static var disabledText: Color { Color(.paletteTextTertiary) }
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
    static let card: CGFloat = 16
}
