import SwiftUI

/// Seção de jogos ao vivo na Início (carrossel ou nota explicativa quando vazio).
struct HomeLiveSection: View {
    let liveMatches: [Match]
    let lastRefresh: Date
    let isFavoriteScope: Bool

    var body: some View {
        if liveMatches.isEmpty {
            InlineNote(
                systemImage: "dot.radiowaves.left.and.right",
                text: isFavoriteScope ? "Sua atlética não tem jogo ao vivo agora." : "Nenhum jogo ao vivo agora."
            )
            .padding(.horizontal, Spacing.l)
        } else {
            LiveCarousel(matches: liveMatches, lastRefresh: lastRefresh)
        }
    }
}

#Preview("Com jogos") {
    NavigationStack {
        HomeLiveSection(
            liveMatches: Array(MockData.matches.filter { $0.status == .live }),
            lastRefresh: .now,
            isFavoriteScope: true
        )
    }
}

#Preview("Vazio") {
    HomeLiveSection(
        liveMatches: [],
        lastRefresh: .now,
        isFavoriteScope: true
    )
}
