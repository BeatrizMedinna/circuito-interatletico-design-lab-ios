import SwiftUI

/// Esqueleto de carregamento da lista de modalidades.
struct SportsLoadingSkeleton: View {
    var body: some View {
        VStack(spacing: 1) {
            ForEach(MockData.competitions.prefix(5)) { competition in
                CompetitionRow(
                    competition: competition,
                    progress: .notStarted(next: nil),
                    isLive: false
                )
            }
            Spacer(minLength: 0)
        }
        .padding(.top, Spacing.s)
        .redacted(reason: .placeholder)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carregando modalidades")
    }
}

#Preview {
    SportsLoadingSkeleton()
        .background(Color.canvas)
}
