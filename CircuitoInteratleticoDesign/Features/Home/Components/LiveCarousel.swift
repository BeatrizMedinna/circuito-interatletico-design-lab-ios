import SwiftUI

/// Carrossel paginado dos jogos ao vivo, com indicador de página.
struct LiveCarousel: View {
    let matches: [Match]
    let lastRefresh: Date
    @State private var currentID: Match.ID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: Spacing.s) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: Spacing.s) {
                    ForEach(matches) { match in
                        NavigationLink(value: AppRoute.match(match.id)) {
                            MatchHeaderCard(match: match, lastRefresh: lastRefresh, showsLiveBadge: true,
                                            stacksAtAccessibilitySizes: true)
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

            // Indicador de página: a atual é mais longa e branca; as outras em cinza
            // terciário (≥ 3:1 sobre o fundo). Forma e cor juntas, sem depender só de cor.
            if matches.count > 1 {
                let index = matches.firstIndex { $0.id == currentID } ?? 0
                HStack(spacing: 6) {
                    ForEach(matches.indices, id: \.self) { item in
                        Capsule()
                            .fill(item == index ? Color.textPrimary : Color.textTertiary)
                            .frame(width: item == index ? 24 : 8, height: 6)
                    }
                }
                .animation(reduceMotion ? nil : .snappy, value: index)
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
