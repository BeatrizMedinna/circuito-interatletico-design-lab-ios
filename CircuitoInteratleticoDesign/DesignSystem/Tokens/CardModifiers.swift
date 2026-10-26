import SwiftUI

/// Aparência dos cartões. `standard` para listas e carrosséis; `emphasized`
/// para o cartão de destaque (topo do detalhe e carrossel ao vivo), com um
/// gradiente sutil. Conteúdo nunca usa Liquid Glass (reservado à navegação).
enum CardStyle {
    case standard, emphasized
}

extension View {
    /// Fundo, contorno e raio iguais em todos os cartões.
    /// `highlighted` reforça o contorno (ex.: partida ao vivo), sempre junto de
    /// um rótulo de estado, para não depender só da borda.
    func cardSurface(_ style: CardStyle = .standard,
                     cornerRadius: CGFloat = Radius.card,
                     highlighted: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        return background {
            switch style {
            case .standard:
                shape.fill(.surface)
            case .emphasized:
                shape.fill(LinearGradient(colors: [Color.surfaceInset, Color.surface],
                                          startPoint: .top, endPoint: .bottom))
            }
        }
        .overlay {
            shape.strokeBorder(highlighted ? Color.borderStrong : Color.separatorLine,
                               lineWidth: highlighted ? 1.5 : 1)
        }
        .clipShape(shape)
    }
}
