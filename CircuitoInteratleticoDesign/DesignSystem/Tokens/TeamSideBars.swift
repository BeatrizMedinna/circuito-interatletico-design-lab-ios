import SwiftUI

extension View {
    /// Faixas na cor de cada atlética, coladas às bordas do cartão, alinhadas ao
    /// topo dos times (altura do escudo), sempre do mesmo tamanho no mesmo tipo de cartão.
    /// `inset` é o recuo horizontal do cartão: a faixa sai do conteúdo e encosta na borda.
    /// Time "a definir" fica sem faixa.
    func teamSideBars(_ a: Athletic?, _ b: Athletic?, inset: CGFloat,
                      size: AthleticColorBar.Size = .compact) -> some View {
        overlay(alignment: .topLeading) {
            if let a { AthleticColorBar(color: a.brandColor, edge: .leading, size: size).offset(x: -inset, y: size.topOffset) }
        }
        .overlay(alignment: .topTrailing) {
            if let b { AthleticColorBar(color: b.brandColor, edge: .trailing, size: size).offset(x: inset, y: size.topOffset) }
        }
    }
}
