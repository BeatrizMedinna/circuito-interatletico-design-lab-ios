import SwiftUI

/// Faixa curta na cor da atlética, presa a uma borda (cartões de jogo e linhas do ranking).
/// Altura fixa para todas as faixas do mesmo tipo de cartão, independente do nome.
/// Decorativa: o nome da atlética sempre acompanha, e o VoiceOver ignora.
struct AthleticColorBar: View {
    enum Size {
        /// Cartões compactos (Início, Cronograma, agendas) e linhas do ranking.
        case compact
        /// Cartão grande do jogo (carrossel ao vivo e topo do detalhe).
        case prominent

        var height: CGFloat {
            switch self {
            case .compact: 40
            case .prominent: 84
            }
        }

        /// Deslocamento a partir do topo dos times: a compacta fica centrada no escudo
        /// (44 pt); a grande começa no topo do escudo e desce até o nome.
        var topOffset: CGFloat {
            switch self {
            case .compact: 2
            case .prominent: 0
            }
        }
    }

    let color: Color
    var edge: HorizontalEdge = .leading
    var size: Size = .compact

    var body: some View {
        UnevenRoundedRectangle(cornerRadii: edge == .leading
                               ? .init(bottomTrailing: 3, topTrailing: 3)
                               : .init(topLeading: 3, bottomLeading: 3))
            .fill(color)
            .frame(width: 5, height: size.height)
            .accessibilityHidden(true)
    }
}
