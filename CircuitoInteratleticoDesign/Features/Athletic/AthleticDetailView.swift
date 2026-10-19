import SwiftUI

/// Telas 10, 11 e 12 — Detalhes da atlética: resumo no topo (com a ação de atlética
/// de coração) e três abas (Agenda, Sobre, Modalidades).
struct AthleticDetailView: View {
    enum Tab: Hashable, CaseIterable {
        case matches, about, sports

        var title: String {
            switch self {
            case .matches: "Agenda"
            case .about: "Sobre"
            case .sports: "Modalidades"
            }
        }

        var symbol: String {
            switch self {
            case .matches: "calendar"
            case .about: "info.circle"
            case .sports: "trophy"
            }
        }
    }

    @Environment(AppState.self) private var appState
    let athleticID: Athletic.ID
    @State private var tab: Tab = .about

    var body: some View {
        Group {
            if let athletic = MockData.athletics.first(where: { $0.id == athleticID }) {
                content(athletic)
            } else {
                ContentUnavailableView {
                    Label("Atlética indisponível", systemImage: "shield")
                } description: {
                    Text("Não foi possível abrir esta atlética. Volte e tente novamente.")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.canvas.ignoresSafeArea())
        .navigationTitle("Atlética")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ athletic: Athletic) -> some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                AthleticSummaryCard(athletic: athletic,
                                    entry: appState.rankingEntry(for: athletic.id),
                                    profile: MockData.profile(for: athletic.id),
                                    isFavorite: athletic.id == appState.favoriteAthletic?.id) {
                    FavoriteChoice(athletic: athletic)
                }
                    .padding(Spacing.l)
                Section {
                    Group {
                        switch tab {
                        case .matches: AthleticMatchesTab(athletic: athletic)
                        case .about: AthleticAboutTab(athletic: athletic, profile: MockData.profile(for: athletic.id))
                        case .sports: AthleticSportsTab(athletic: athletic)
                        }
                    }
                    .padding(Spacing.l)
                } header: {
                    UnderlineTabs(items: Tab.allCases, selection: $tab, systemImage: \.symbol) { $0.title }
                        .padding(.horizontal, Spacing.l)
                        .background(Color.canvas)
                }
            }
        }
        .refreshable { await appState.refresh() }
    }
}

// MARK: - Previews

private func athleticPreview(_ id: Athletic.ID, favorite: Athletic.ID? = "ath-bufalos") -> some View {
    NavigationStack { AthleticDetailView(athleticID: id) }
        .environment(AppState(favoriteAthletic: favorite.map { MockData.athletic($0) }, scenario: .filled, preloaded: true))
}

#Preview("Sua atlética") { athleticPreview("ath-bufalos") }
#Preview("Empatada, sem descrição") { athleticPreview("ath-diastolica") }
#Preview("Sem classificação") { athleticPreview("ath-nce") }
#Preview("Sem jogos nem dados") { athleticPreview("ath-falcoes") }
#Preview("Indisponível") { athleticPreview("inexistente") }
