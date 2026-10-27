import SwiftUI

/// Telas 14, 15 e 16 — Detalhe da modalidade. O formato muda as abas:
/// eliminatória → Jogos, Chave, Classificação; classificatória → Prova, Resultados.
struct CompetitionDetailView: View {
    enum Tab: Hashable {
        case matches, bracket, standings, trial, results

        var title: String {
            switch self {
            case .matches: "Jogos"
            case .bracket: "Chave"
            case .standings: "Classificação"
            case .trial: "Prova"
            case .results: "Resultados"
            }
        }

        var symbol: String {
            switch self {
            case .matches, .trial: "calendar"
            case .bracket: "point.3.connected.trianglepath.dotted"
            case .standings: "trophy"
            case .results: "list.number"
            }
        }
    }

    @Environment(AppState.self) private var appState
    let competitionID: Competition.ID
    @State private var tab: Tab?
    /// Nome na barra só depois que o cartão do topo sai da tela (como no perfil da atlética).
    @State private var showsBarTitle = false
    /// Posição da rolagem: ao mudar o tamanho do texto, o conteúdo encolhe ou cresce e
    /// a posição antiga podia ficar além do fim (tela vazia até rolar). Volta ao topo.
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if let competition = appState.competition(id: competitionID) {
                content(competition)
            } else {
                ContentUnavailableView {
                    Label("Modalidade indisponível", systemImage: "star")
                } description: {
                    Text("Não foi possível abrir esta modalidade. Volte e tente novamente.")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.canvas.ignoresSafeArea())
        // O título usa o nome da modalidade (também no menu do Voltar e no VoiceOver).
        .navigationTitle(barTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(barTitle)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .opacity(showsBarTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: showsBarTitle)
                    .accessibilityHidden(!showsBarTitle)
            }
        }
    }

    private var barTitle: String {
        appState.competition(id: competitionID)?.title ?? "Modalidade"
    }

    private func tabs(for competition: Competition) -> [Tab] {
        competition.isElimination ? [.matches, .bracket, .standings] : [.trial, .results]
    }

    /// Eliminatória abre nos jogos; prova abre nos resultados quando já há algum.
    private func defaultTab(for competition: Competition) -> Tab {
        if competition.isElimination { return .matches }
        return competition.trial?.results.isEmpty == false ? .results : .trial
    }

    private func content(_ competition: Competition) -> some View {
        let matches = appState.matches
        let selected = Binding { tab ?? defaultTab(for: competition) } set: { tab = $0 }
        return ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                CompetitionSummaryCard(competition: competition,
                                       progress: competition.progress(matches: matches),
                                       isLive: competition.hasLiveMatch(in: matches))
                    .padding(Spacing.l)
                Section {
                    Group {
                        switch selected.wrappedValue {
                        case .matches: CompetitionMatchesTab(competition: competition)
                        case .bracket: BracketTab(competition: competition)
                        case .standings: CampaignTab(competition: competition)
                        case .trial: TrialInfoTab(competition: competition)
                        case .results: TrialResultsTab(competition: competition)
                        }
                    }
                    .padding(Spacing.l)
                } header: {
                    UnderlineTabs(items: tabs(for: competition), selection: selected, systemImage: \.symbol) { $0.title }
                        .padding(.horizontal, Spacing.l)
                        .background(Color.canvas)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(.separatorLine).frame(height: 1)
                        }
                }
            }
        }
        .scrollPosition($scrollPosition)
        .onChange(of: dynamicTypeSize) { _, _ in
            scrollPosition.scrollTo(edge: .top)
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top > 56
        } action: { _, isPastHeader in
            showsBarTitle = isPastHeader
        }
        .refreshable { await appState.refresh() }
    }
}

// MARK: - Previews

private func competitionPreview(_ id: Competition.ID) -> some View {
    NavigationStack { CompetitionDetailView(competitionID: id) }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}

#Preview("Eliminatória · chave completa") { competitionPreview(MockData.competitionID(MockData.basketballMale, MockData.serieOuro)) }
#Preview("Eliminatória · encerrada") { competitionPreview(MockData.competitionID(MockData.tableTennisMixed, MockData.serieBronze)) }
#Preview("Eliminatória · sem chave") { competitionPreview(MockData.competitionID(MockData.chessMixed, MockData.serieOuro)) }
#Preview("Prova encerrada") { competitionPreview(MockData.competitionID(MockData.swimmingMale, MockData.serieOuro, event: "50m livre")) }
#Preview("Prova parcial") { competitionPreview(MockData.competitionID(MockData.athleticsFemale, MockData.seriePrata, event: "Salto em distância")) }
#Preview("Prova agendada") { competitionPreview(MockData.competitionID(MockData.swimmingFemale, MockData.serieBronze, event: "Revezamento 4x50m livre")) }
