import SwiftUI

/// Telas 03, 04 e 05 — Detalhe da partida. Uma única tela que varia pela
/// situação: ao vivo, encerrada (inclusive W.O.) ou a iniciar.
struct MatchDetailView: View {
    @Environment(AppState.self) private var appState
    let matchID: Match.ID

    var body: some View {
        Group {
            if let match = appState.match(id: matchID) {
                content(match)
                    .toolbar {
                        ToolbarItem(placement: .principal) { title(for: match) }
                    }
            } else {
                ContentUnavailableView {
                    Label("Partida indisponível", systemImage: "sportscourt")
                } description: {
                    Text("Não foi possível abrir esta partida. Volte e tente novamente.")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.canvas.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func title(for match: Match) -> some View {
        HStack(spacing: Spacing.xs) {
            if match.status == .live {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.live)
                    .symbolEffect(.pulse)
            }
            Text(match.status.title)
                .font(.headline)
        }
        .foregroundStyle(.textPrimary)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func content(_ match: Match) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(spacing: Spacing.s) {
                    MatchHeaderCard(match: match, lastRefresh: appState.lastRefresh, linksTeams: true,
                                    stacksAtAccessibilitySizes: true)
                    if let note = statusNote(for: match) {
                        InlineNote(systemImage: note.symbol, text: note.text)
                    }
                }

                MatchInfoSection(match: match)

                if let competition = MockData.competition(for: match) {
                    NavigationLink(value: AppRoute.competition(competition.id)) {
                        CompetitionLinkRow(competition: competition)
                    }
                    .buttonStyle(.pressableCard)
                }

                if !match.periods.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        SectionHeader(title: "Parciais")
                        PartialsTable(match: match)
                    }
                }

                if match.status != .scheduled && match.walkoverWinner == nil {
                    PlayHistorySection(match: match)
                }
            }
            .padding(Spacing.l)
        }
        .refreshable { await appState.refresh() }
    }

    /// Explica estados que o cabeçalho sozinho não deixa claros.
    private func statusNote(for match: Match) -> (symbol: String, text: String)? {
        if let side = match.walkoverWinner, let winner = match.team(side) {
            return ("flag.checkered", "Partida encerrada por W.O. Vitória de \(winner.name).")
        }
        guard match.status == .scheduled else { return nil }
        // O placar "– : –" e o status "A iniciar" já dizem que o jogo não começou;
        // o aviso só aparece quando falta informação que a tela não mostra.
        if match.teamA == nil || match.teamB == nil {
            return ("questionmark.circle", "Os adversários serão definidos pelos resultados da fase anterior.")
        }
        return nil
    }
}

// MARK: - Previews

private func detailPreview(_ id: Match.ID) -> some View {
    NavigationStack { MatchDetailView(matchID: id) }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}

#Preview("Ao vivo · Basquete") { detailPreview("m-live-basquete") }
#Preview("Ao vivo · sem lances") { detailPreview("m-live-futsal") }
#Preview("Ao vivo · Vôlei (sets)") { detailPreview("m-live-volei") }
#Preview("Encerrado") { detailPreview("m-fin-futsal") }
#Preview("Encerrado · 5 sets") { detailPreview("m-fin-tenis") }
#Preview("Encerrado · W.O.") { detailPreview("m-fin-handebol-wo") }
#Preview("Encerrado · sem lances") { detailPreview("m-fin-futsal-sem-lances") }
#Preview("A iniciar") { detailPreview("m-up-futsal") }
#Preview("A iniciar · a definir") { detailPreview("m-up-final") }
#Preview("Indisponível") { detailPreview("inexistente") }
