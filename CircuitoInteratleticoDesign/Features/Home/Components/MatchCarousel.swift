import SwiftUI

/// Carrossel horizontal de cartões compactos de partidas, mostrando a borda do próximo.
struct MatchCarousel: View {
    let matches: [Match]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: Spacing.s) {
                ForEach(matches) { match in
                    NavigationLink(value: AppRoute.match(match.id)) {
                        MatchCard(match: match)
                    }
                    .buttonStyle(.pressableCard)
                    .containerRelativeFrame(.horizontal, count: 7, span: 6, spacing: Spacing.s)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, Spacing.l, for: .scrollContent)
    }
}

#Preview {
    NavigationStack {
        MatchCarousel(matches: Array(MockData.matches.prefix(3)))
    }
}
