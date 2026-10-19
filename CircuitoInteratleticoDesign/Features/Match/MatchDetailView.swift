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
                    MatchHeaderCard(match: match, lastRefresh: appState.lastRefresh, linksTeams: true)
                    if let note = statusNote(for: match) {
                        InlineNote(systemImage: note.symbol, text: note.text)
                    }
                }

                MatchInfoSection(match: match)

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
        if match.teamA == nil || match.teamB == nil {
            return ("questionmark.circle", "Os adversários serão definidos pelos resultados da fase anterior.")
        }
        return ("clock", "O placar e os lances aparecem aqui quando a partida começar.")
    }
}

// MARK: - Informações

private struct MatchInfoSection: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Informações")
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack(alignment: .top, spacing: Spacing.m) {
                    item("Data", Formatters.fullDay(match.startDate))
                    item("Horário", Formatters.time(match.startDate))
                }
                HStack(alignment: .top, spacing: Spacing.m) {
                    item("Etapa", match.phase)
                    item("Divisão", match.division.name)
                }
                item("Local", match.venue)
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        }
    }

    private func item(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Parciais

/// Tabela de pontos por período. Ao vivo, a coluna do período atual fica destacada.
/// Com fonte muito grande, a tabela passa a rolar na horizontal.
private struct PartialsTable: View {
    let match: Match
    @ScaledMetric(relativeTo: .body) private var cellWidth: CGFloat = 40

    var body: some View {
        ViewThatFits(in: .horizontal) {
            table
            ScrollView(.horizontal) { table }
        }
    }

    private var table: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(maxWidth: .infinity, minHeight: 36)
                ForEach(match.periods, id: \.number) { period in
                    cell("\(period.number)º", period: period.number, isHeader: true)
                }
            }
            .accessibilityHidden(true)
            Divider()
            row(.a)
            Divider()
            row(.b)
        }
        .background(.appBackground, in: RoundedRectangle(cornerRadius: Radius.control))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.control)
                .strokeBorder(Color(white: 0.75), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.control))
    }

    private func row(_ side: MatchSide) -> some View {
        let team = match.team(side)
        return HStack(spacing: 0) {
            HStack(spacing: Spacing.xs) {
                AthleticBadge(size: .small, fill: .surface, isUndefined: team == nil)
                Text(team?.name ?? "A definir")
                    .font(.subheadline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, Spacing.xs)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            ForEach(match.periods, id: \.number) { period in
                cell(String(side == .a ? period.a : period.b), period: period.number, isHeader: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel(side, team: team))
    }

    private func cell(_ text: String, period: Int, isHeader: Bool) -> some View {
        let isCurrent = match.status == .live && period == match.currentPeriod
        return Text(text)
            .font(isHeader || isCurrent ? .subheadline.weight(.semibold) : .subheadline)
            .monospacedDigit()
            .foregroundStyle(.textPrimary)
            .frame(width: cellWidth)
            .frame(maxHeight: .infinity)
            .background(isCurrent ? Color.surfaceSelected : Color.clear)
            .overlay(alignment: .leading) {
                Rectangle().fill(Color(white: 0.75)).frame(width: 1)
            }
    }

    private func rowAccessibilityLabel(_ side: MatchSide, team: Athletic?) -> String {
        let scores = match.periods.map { period in
            "\(match.sport.periodLabel(period.number)): \(side == .a ? period.a : period.b)"
        }
        return ([team?.name ?? "A definir"] + scores).joined(separator: ", ")
    }
}

// MARK: - Histórico de lances

/// Lances por período, do mais recente para o mais antigo.
private struct PlayHistorySection: View {
    let match: Match
    @State private var selectedPeriod: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Histórico")
            if match.plays.isEmpty {
                InlineNote(systemImage: "list.bullet",
                           text: match.status == .live
                               ? "Nenhum lance registrado ainda."
                               : "Os lances desta partida não foram registrados.")
            } else {
                if periods.count > 1 {
                    UnderlineTabs(items: periods, selection: periodBinding) { match.sport.periodLabel($0) }
                }
                let plays = match.plays.filter { $0.period == periodBinding.wrappedValue }.reversed()
                if plays.isEmpty {
                    InlineNote(systemImage: "list.bullet", text: "Nenhum lance registrado neste período.")
                } else {
                    VStack(spacing: 1) {
                        ForEach(Array(plays)) { play in
                            PlayRow(play: play, match: match)
                        }
                    }
                    .background(Color.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                }
            }
        }
    }

    private var periods: [Int] {
        let numbers = match.periods.map(\.number)
        return numbers.isEmpty ? Array(Set(match.plays.map(\.period))).sorted() : numbers
    }

    /// Começa no período atual (ao vivo) ou no último (encerrado).
    private var periodBinding: Binding<Int> {
        Binding {
            selectedPeriod ?? match.currentPeriod ?? periods.last ?? 1
        } set: {
            selectedPeriod = $0
        }
    }
}

private struct PlayRow: View {
    let play: Play
    let match: Match
    @ScaledMetric(relativeTo: .caption) private var timeColumnWidth: CGFloat = 64

    var body: some View {
        let team = match.team(play.side)
        HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(match.sport.periodLabel(play.period))
                    .font(.caption.weight(.semibold))
                if let minute = play.minute {
                    Text(minute).font(.caption)
                }
                Text("\(play.scoreA)-\(play.scoreB)")
                    .font(.caption)
                    .monospacedDigit()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(.textSecondary)
            .frame(width: timeColumnWidth)
            .padding(.vertical, Spacing.s)

            Rectangle().fill(Color.canvas).frame(width: 1)

            HStack(spacing: Spacing.s) {
                AthleticBadge(size: .small)
                VStack(alignment: .leading, spacing: 2) {
                    Text(play.description)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text([team?.name, play.athleteName].compactMap { $0 }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding(Spacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.surface)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(team: team))
    }

    private func accessibilityText(team: Athletic?) -> String {
        [match.sport.periodLabel(play.period), play.minute, team?.name, play.description,
         play.athleteName, "placar \(play.scoreA) a \(play.scoreB)"]
            .compactMap { $0 }
            .joined(separator: ", ")
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
