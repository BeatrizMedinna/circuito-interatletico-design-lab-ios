import SwiftUI

/// Estado de carregamento do Ranking (esqueleto com pódio e linhas fictícias).
struct RankingLoadingSkeleton: View {
    var body: some View {
        VStack(spacing: Spacing.m) {
            Podium(entries: Array(MockData.rankings[0].entries.prefix(3)), favoriteID: nil)
            ForEach(MockData.rankings[0].entries.dropFirst(3).prefix(3)) { entry in
                RankingRow(position: entry.position, athletic: entry.athletic, detail: Formatters.points(entry.points))
            }
            Spacer(minLength: 0)
        }
        .padding(.top, Spacing.l)
        .redacted(reason: .placeholder)
        .disabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carregando ranking")
    }
}

#Preview {
    RankingLoadingSkeleton()
        .background(Color.canvas)
}
