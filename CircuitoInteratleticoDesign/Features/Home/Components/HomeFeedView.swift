import SwiftUI

/// Feed principal da tela de Início (jogos ao vivo, próximos e últimos jogos, ou estados vazios).
struct HomeFeedView: View {
    @Environment(AppState.self) private var appState
    let allMatches: [Match]
    let effectiveScope: HomeScope
    @Binding var scope: HomeScope

    var body: some View {
        let favorite = appState.favoriteAthletic
        let matches = effectiveScope == .favorite ? allMatches.filter { $0.involves(favorite?.id ?? "") } : allMatches

        if allMatches.isEmpty {
            ContentUnavailableView {
                Label("Cronograma ainda não publicado", systemImage: "calendar")
            } description: {
                Text("Os jogos aparecem aqui assim que a organização publicar o cronograma.")
            }
        } else if matches.isEmpty {
            ContentUnavailableView {
                Label("Sua atlética ainda não tem jogos", systemImage: "sportscourt")
            } description: {
                Text("Quando houver jogos de \(favorite?.name ?? "sua atlética") no cronograma, eles aparecem aqui.")
            } actions: {
                Button("Ver todos os jogos") { withAnimation { scope = .general } }
                    .buttonStyle(.secondary)
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    HomeLiveSection(
                        liveMatches: matches.filter { $0.status == .live }.sorted { $0.startDate < $1.startDate },
                        lastRefresh: appState.lastRefresh,
                        isFavoriteScope: effectiveScope == .favorite
                    )

                    HomeMatchSection(
                        kind: .upcoming,
                        matches: MatchListKind.upcoming.select(from: matches),
                        isFavoriteScope: effectiveScope == .favorite
                    )

                    HomeMatchSection(
                        kind: .recent,
                        matches: MatchListKind.recent.select(from: matches),
                        isFavoriteScope: effectiveScope == .favorite
                    )
                }
                .padding(.vertical, Spacing.l)
            }
            .refreshable { await appState.refresh() }
        }
    }
}

#Preview {
    NavigationStack {
        HomeFeedView(
            allMatches: MockData.matches,
            effectiveScope: .favorite,
            scope: .constant(.favorite)
        )
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
