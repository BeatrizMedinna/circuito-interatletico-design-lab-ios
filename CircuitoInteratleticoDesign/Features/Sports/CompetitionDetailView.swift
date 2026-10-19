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
        .navigationTitle("Modalidade")
        .navigationBarTitleDisplayMode(.inline)
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
                }
            }
        }
        .refreshable { await appState.refresh() }
    }
}

// MARK: - Resumo

private struct CompetitionSummaryCard: View {
    let competition: Competition
    let progress: CompetitionProgress
    let isLive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                Image(systemName: competition.sport.symbol)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 80, height: 80)
                    .background(.surface, in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(competition.eventName ?? competition.sport.name)
                        .font(.title3.bold())
                        .foregroundStyle(.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(competition.eventName == nil ? competition.sport.gender.label
                         : "\(competition.sport.name) \(competition.sport.gender.label)")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                    Text(competition.format.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .overlay { Capsule().strokeBorder(.borderStrong, lineWidth: 1) }
                        .padding(.top, 2)
                }
            }
            HStack(alignment: .top, spacing: Spacing.xs) {
                stat(competition.division.name, "Divisão")
                stat(stageValue, competition.isElimination ? "Etapa" : "Situação")
                stat(competition.registeredAthletes.map(String.init) ?? "—", "Atletas")
            }
            if isLive {
                Label("Jogo ao vivo agora", systemImage: "circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .symbolEffect(.pulse)
            }
            if case .finished(let champion?) = progress {
                Label("Campeã: \(champion.name)", systemImage: "trophy.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.textPrimary)
                    .padding(Spacing.s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.surface, in: RoundedRectangle(cornerRadius: Radius.control))
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground, in: RoundedRectangle(cornerRadius: Radius.card))
    }

    private var stageValue: String {
        switch progress {
        case .notGenerated: "—"
        case .notStarted: competition.isElimination ? "A iniciar" : "Agendada"
        case .inProgress(let phase): competition.isElimination ? phase : "Parcial"
        case .finished: "Encerrada"
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value == "—" ? "sem dados" : value)")
    }
}

// MARK: - Jogos (tela 14)

/// Partidas da modalidade: ao vivo e próximas primeiro, depois as encerradas
/// (mais recentes no topo). A fase aparece no cabeçalho do cartão.
private struct CompetitionMatchesTab: View {
    @Environment(AppState.self) private var appState
    let competition: Competition

    var body: some View {
        let matches = appState.matches.filter(competition.includes)
        if matches.isEmpty {
            InlineNote(systemImage: "calendar",
                       text: "A chave desta modalidade ainda não foi definida. Os jogos aparecem aqui depois do sorteio.")
        } else {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                section("Ao vivo e próximos",
                        matches.filter { $0.status != .finished }.sorted { $0.startDate < $1.startDate },
                        empty: "Nenhum jogo por vir nesta modalidade.")
                section("Encerrados",
                        matches.filter { $0.status == .finished }.sorted { $0.startDate > $1.startDate },
                        empty: "Nenhum jogo encerrado ainda.")
            }
        }
    }

    private func section(_ title: String, _ matches: [Match], empty: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: title)
            if matches.isEmpty {
                InlineNote(systemImage: "calendar", text: empty)
            }
            ForEach(matches) { match in
                NavigationLink(value: AppRoute.match(match.id)) {
                    MatchCard(match: match, showsStatus: true,
                              caption: "\(match.phase) · \(Formatters.dayLabel(match.startDate)), \(Formatters.time(match.startDate))".uppercased())
                }
                .buttonStyle(.pressableCard)
            }
        }
    }
}

// MARK: - Classificação do mata-mata (tela 16, eliminatória)

/// No mata-mata não há pontos: mostra até onde cada atlética chegou.
private struct CampaignTab: View {
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

// MARK: - Prova (classificatória)

private struct TrialInfoTab: View {
    let competition: Competition

    var body: some View {
        if let trial = competition.trial, case .ranking(let criterion, let unit, let isTeam) = competition.format {
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Informações")
                VStack(alignment: .leading, spacing: Spacing.m) {
                    HStack(alignment: .top, spacing: Spacing.m) {
                        item("Data", Formatters.fullDay(trial.startDate))
                        item("Horário", Formatters.time(trial.startDate))
                    }
                    HStack(alignment: .top, spacing: Spacing.m) {
                        item("Situação", trial.isClosed ? "Encerrada" : trial.hasPartialResults ? "Resultados parciais" : "Agendada")
                        item("Disputa", isTeam ? "Por equipe" : "Individual")
                    }
                    HStack(alignment: .top, spacing: Spacing.m) {
                        item("Critério", criterion.label)
                        item("Unidade", unit.label)
                    }
                    item("Local", trial.venue)
                }
                .padding(Spacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
            }
        } else {
            InlineNote(systemImage: "calendar", text: "A prova desta modalidade ainda não foi agendada.")
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

/// Tela 16 na classificatória: marcas em ordem, empates dividindo a posição,
/// situações sem posição no fim e inscritas que ainda aguardam resultado.
private struct TrialResultsTab: View {
    @Environment(AppState.self) private var appState
    let competition: Competition

    var body: some View {
        if let trial = competition.trial, case .ranking(let criterion, let unit, let isTeam) = competition.format {
            VStack(alignment: .leading, spacing: Spacing.l) {
                if trial.results.isEmpty {
                    InlineNote(systemImage: "clock",
                               text: "Os resultados aparecem aqui quando a prova começar, \(Formatters.dayLabel(trial.startDate).lowercased()) às \(Formatters.time(trial.startDate)).")
                } else {
                    InlineNote(systemImage: trial.isClosed ? "checkmark.seal" : "exclamationmark.circle",
                               text: trial.isClosed
                                ? "Prova encerrada. \(criterion.label); marcas iguais dividem a posição."
                                : "Resultados parciais: podem mudar até o encerramento da prova.")
                    VStack(spacing: 1) {
                        ForEach(trial.ranked(by: criterion)) { ranked in
                            NavigationLink(value: AppRoute.athletic(ranked.result.athletic.id)) {
                                ResultRow(ranked: ranked, unit: unit, isTeam: isTeam,
                                          isFavorite: ranked.result.athletic.id == appState.favoriteAthletic?.id)
                            }
                            .buttonStyle(.pressableCard)
                        }
                    }
                    .background(Color.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                }

                let pending = trial.isClosed ? [] : trial.pendingParticipants
                if !pending.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        SectionHeader(title: trial.results.isEmpty ? "Atléticas inscritas" : "Aguardando resultado")
                        VStack(spacing: 1) {
                            ForEach(pending) { athletic in
                                NavigationLink(value: AppRoute.athletic(athletic.id)) {
                                    RankingRow(position: nil, athletic: athletic, detail: athletic.institution,
                                               isFavorite: athletic.id == appState.favoriteAthletic?.id,
                                               showsPosition: false)
                                }
                                .buttonStyle(.pressableCard)
                            }
                        }
                        .background(Color.canvas)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                    }
                }
            }
        } else {
            InlineNote(systemImage: "list.number", text: "Ainda não há prova para esta modalidade.")
        }
    }
}

/// Linha de resultado: posição (ou "—"), atleta e atlética, marca ou situação.
private struct ResultRow: View {
    let ranked: RankedResult
    let unit: MarkUnit
    let isTeam: Bool
    let isFavorite: Bool

    var body: some View {
        let result = ranked.result
        HStack(spacing: Spacing.s) {
            Text(ranked.position.map { ranked.isTied ? "\($0)º=" : "\($0)º" } ?? "—")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
                .frame(minWidth: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xxs) {
                    Text(isTeam ? result.athletic.name : (result.athleteName ?? result.athletic.name))
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    if isFavorite {
                        Image(systemName: "heart.fill").font(.caption).foregroundStyle(.textPrimary)
                    }
                }
                if !isTeam {
                    Text(result.athletic.name)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer(minLength: Spacing.xs)
            Text(result.situation == .valid ? result.mark.map(unit.format) ?? "—" : result.situation.label)
                .font(result.situation == .valid ? .headline.monospacedDigit() : .subheadline.italic())
                .foregroundStyle(result.situation == .valid ? Color.textPrimary : Color.textSecondary)
        }
        .padding(.vertical, Spacing.s)
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .overlay(alignment: .leading) {
            Rectangle().fill(isFavorite ? Color.textPrimary : .clear).frame(width: 4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Abre a atlética")
    }

    private var accessibilityText: String {
        let result = ranked.result
        let place = ranked.position.map { ranked.isTied ? "\($0)º lugar, empatado" : "\($0)º lugar" } ?? result.situation.label
        let mark = result.situation == .valid ? result.mark.map(unit.format) : nil
        return [place, result.athleteName, result.athletic.name, mark, isFavorite ? "sua atlética" : nil]
            .compactMap { $0 }.joined(separator: ", ")
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
