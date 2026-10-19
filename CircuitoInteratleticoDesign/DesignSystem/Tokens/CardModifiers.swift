import SwiftUI

extension View {
    /// Barras laterais dos cartões (lado A cinza, lado B preto), herdadas do wireframe.
    /// Na alta fidelidade podem receber as cores das atléticas.
    func teamSideBars() -> some View {
        overlay(alignment: .leading) {
            UnevenRoundedRectangle(bottomTrailingRadius: 2, topTrailingRadius: 2)
                .fill(Color(white: 0.55))
                .frame(width: 4, height: 48)
        }
        .overlay(alignment: .trailing) {
            UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 2)
                .fill(Color.textPrimary)
                .frame(width: 4, height: 48)
        }
    }
}
