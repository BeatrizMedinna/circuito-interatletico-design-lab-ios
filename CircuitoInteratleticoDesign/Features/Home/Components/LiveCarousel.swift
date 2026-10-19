import SwiftUI

/// Carrossel paginado dos jogos ao vivo, com indicador de página.
struct LiveCarousel: View {
    let matches: [Match]
    let lastRefresh: Date
    @State private var currentID: Match.ID?

    var body: some View {
        VStack(spacing: Spacing.s) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: Spacing.s) {
                    ForEach(matches) { match in
                        NavigationLink(value: AppRoute.match(match.id)) {
                            MatchHeaderCard(match: match, lastRefresh: lastRefresh, showsLiveBadge: true)
                        }
                        .buttonStyle(.pressableCard)
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, Spacing.l, for: .scrollContent)
            .scrollPosition(id: $currentID)

            if matches.count > 1 {
                let index = matches.firstIndex { $0.id == currentID } ?? 0
                HStack(spacing: 6) {
                    ForEach(matches.indices, id: \.self) { item in
                        Capsule()
                            .fill(item == index ? Color.textPrimary : Color.surfaceSelected)
                            .frame(width: item == index ? 24 : 12, height: 4)
                    }
                }
                .animation(.snappy, value: index)
                .frame(maxWidth: .infinity)
                .accessibilityElement()
                .accessibilityLabel("Jogo ao vivo \(index + 1) de \(matches.count)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        LiveCarousel(matches: Array(MockData.matches.prefix(2)), lastRefresh: .now)
    }
}
