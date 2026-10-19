import SwiftUI

/// Esqueleto de carregamento da tela de Início.
struct HomeLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            MatchHeaderCard(match: MockData.matches[0])
                .padding(.horizontal, Spacing.l)

            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Próximos jogos")
                MatchCard(match: MockData.matches[3])
            }
            .padding(.horizontal, Spacing.l)

            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.l)
        .redacted(reason: .placeholder)
        .disabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carregando jogos")
    }
}

#Preview {
    HomeLoadingSkeleton()
        .background(Color.canvas)
}
