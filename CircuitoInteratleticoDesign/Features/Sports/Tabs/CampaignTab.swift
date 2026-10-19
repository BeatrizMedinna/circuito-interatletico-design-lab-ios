import SwiftUI

/// No mata-mata não há pontos: mostra até onde cada atlética chegou.
struct CampaignTab: View {
    @Environment(AppState.self) private var appState
    let competition: Competition

    var body: some View {
        let entries = competition.campaign(matches: appState.matches)
        VStack(alignment: .leading, spacing: Spacing.s) {
            if entries.isEmpty {
                InlineNote(systemImage: "trophy",
                           text: "A classificação aparece quando a chave for definida.")
            } else {
                InlineNote(systemImage: "info.circle",
                           text: "No mata-mata, a classificação mostra até onde cada atlética chegou na chave.")
                VStack(spacing: 1) {
                    ForEach(entries) { entry in
                        NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
                            RankingRow(position: entry.position, athletic: entry.athletic, detail: entry.status,
                                       isFavorite: entry.athletic.id == appState.favoriteAthletic?.id,
                                       showsPosition: entries.contains { $0.position != nil })
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .background(Color.canvas)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            }
        }
    }
}

#Preview {
    let competition = MockData.competitions[0]
    NavigationStack {
        CampaignTab(competition: competition)
            .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
            .padding()
            .background(Color.canvas)
    }
}
