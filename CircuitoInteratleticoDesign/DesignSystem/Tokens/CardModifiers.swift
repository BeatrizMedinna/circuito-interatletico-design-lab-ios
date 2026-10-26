import SwiftUI

extension View {
    /// Barras laterais dos cartões (lado A mais escuro, lado B mais claro), herdadas do wireframe.
    /// Na alta fidelidade podem receber as cores das atléticas.
    func teamSideBars() -> some View {
        overlay(alignment: .leading) {
            UnevenRoundedRectangle(bottomTrailingRadius: 2, topTrailingRadius: 2)
                .fill(Color.borderStrong)
                .frame(width: 4, height: 48)
        }
        .overlay(alignment: .trailing) {
            UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 2)
                .fill(Color.textSecondary)
                .frame(width: 4, height: 48)
        }
    }
}
