import SwiftUI

/// Tela 09 — Classificação geral por divisão: pódio, lista, busca e acesso às atléticas.
/// Pontos são fictícios (classificação 📝 no domínio, P-08).
struct RankingView: View {
    @Environment(AppState.self) private var appState
    @State private var divisionID: Division.ID = MockData.divisions[0].id
    @State private var query = ""
    @State private var didPickInitialDivision = false

    var body: some View {
        VStack(spacing: 0) {
            header
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        // Abre na divisão da atlética de coração e acompanha quando ela muda.
        .onAppear {
            guard !didPickInitialDivision else { return }
            didPickInitialDivision = true
            if let division = appState.favoriteAthletic?.division { divisionID = division.id }
        }
        .onChange(of: appState.favoriteAthletic?.id) { _, _ in
            if let division = appState.favoriteAthletic?.division { divisionID = division.id }
        }
    }

    private var rankings: [DivisionRanking] {
        guard case .loaded(let rankings) = appState.rankingState else { return [] }
        return rankings
    }

    private var hasAnyRanking: Bool { rankings.contains { !$0.entries.isEmpty } }

    // MARK: - Cabeçalho

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Ranking")
                .font(.title.bold())
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if hasAnyRanking {
                SearchField(prompt: "Buscar atlética", text: $query)
                if query.isEmpty {
                    UnderlineTabs(items: MockData.divisions.map(\.id), selection: $divisionID) { id in
                        MockData.divisions.first { $0.id == id }?.name ?? ""
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.xs)
        .padding(.bottom, hasAnyRanking && query.isEmpty ? 0 : Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    // MARK: - Conteúdo

    @ViewBuilder
    private var content: some View {
        switch appState.rankingState {
        case .loading:
            VStack(spacing: Spacing.m) {
                Podium(entries: Array(MockData.rankings[0].entries.prefix(3)), favoriteID: nil)
                ForEach(MockData.rankings[0].entries.dropFirst(3).prefix(3)) { entry in
                    RankingRow(position: entry.position, athletic: entry.athletic, detail: Formatters.points(entry.points))
                }
                Spacer(minLength: 0)
            }
            .padding(.top, Spacing.l)
            .redacted(reason: .placeholder)
            .disabled(true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Carregando ranking")
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar o ranking", systemImage: "wifi.exclamationmark")
            } description: {
                Text("Verifique sua conexão e tente novamente.")
            } actions: {
                Button("Tentar novamente") { Task { await appState.retry() } }
                    .buttonStyle(.secondary)
            }
        case .unavailable:
            ContentUnavailableView {
                Label("Nenhuma edição em andamento", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Quando a próxima edição começar, o ranking aparece aqui.")
            }
        case .loaded:
            if !hasAnyRanking {
                ContentUnavailableView {
                    Label("Ranking ainda não disponível", systemImage: "trophy")
                } description: {
                    Text("A classificação geral aparece aqui quando houver resultados.")
                }
            } else if !query.isEmpty {
                searchResults
            } else {
                divisionContent
            }
        }
    }

    @ViewBuilder
    private var divisionContent: some View {
        let ranking = rankings.first { $0.division.id == divisionID }
        let entries = ranking?.entries ?? []
        if entries.isEmpty {
            let fallback = rankings.first { !$0.entries.isEmpty }
            ContentUnavailableView {
                Label("Classificação ainda não disponível", systemImage: "trophy")
            } description: {
                Text("A classificação da \(ranking?.division.name ?? "divisão") aparece quando houver resultados.")
            } actions: {
                if let fallback {
                    Button("Ver \(fallback.division.name)") { withAnimation { divisionID = fallback.division.id } }
                        .buttonStyle(.secondary)
                }
            }
        } else {
            ScrollView {
                VStack(spacing: Spacing.l) {
                    Podium(entries: Array(entries.prefix(3)), favoriteID: appState.favoriteAthletic?.id)
                        .padding(.horizontal, Spacing.l)
                    if entries.count > 3 {
                        VStack(spacing: 1) {
                            ForEach(entries.dropFirst(3)) { entry in
                                NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
                                    RankingRow(position: entry.position, athletic: entry.athletic,
                                               detail: Formatters.points(entry.points), isTied: entry.isTied,
                                               isFavorite: entry.athletic.id == appState.favoriteAthletic?.id)
                                }
                                .buttonStyle(.pressableCard)
                            }
                        }
                        .background(Color.canvas)
                    }
                }
                .padding(.vertical, Spacing.l)
            }
            .refreshable { await appState.refresh() }
        }
    }

    /// Busca em todas as divisões; atléticas sem classificação também aparecem.
    @ViewBuilder
    private var searchResults: some View {
        let term = query.trimmingCharacters(in: .whitespaces)
        let results = MockData.athletics.filter { athletic in
            [athletic.name, athletic.acronym].contains {
                $0.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        if results.isEmpty {
            ContentUnavailableView {
                Label("Nenhuma atlética encontrada", systemImage: "magnifyingglass")
            } description: {
                Text("Confira a grafia ou busque pela sigla, como ENG ou MED.")
            } actions: {
                Button("Limpar busca") { query = "" }
                    .buttonStyle(.secondary)
            }
        } else {
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(results) { athletic in
                        let entry = appState.rankingEntry(for: athletic.id)
                        NavigationLink(value: AppRoute.athletic(athletic.id)) {
                            RankingRow(position: entry?.position, athletic: athletic,
                                       detail: [athletic.division.name, entry.map { Formatters.points($0.points) } ?? "sem classificação"]
                                        .joined(separator: " · "),
                                       isTied: entry?.isTied ?? false,
                                       isFavorite: athletic.id == appState.favoriteAthletic?.id)
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Pódio

/// Três primeiros na ordem 2º · 1º · 3º, com degraus de alturas diferentes.
/// Empates mostram a mesma posição em dois degraus.
private struct Podium: View {
    let entries: [RankingEntry]
    let favoriteID: Athletic.ID?

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            ForEach([1, 0, 2], id: \.self) { index in
                if index < entries.count {
                    step(entries[index], rank: index)
                } else {
                    Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
                }
            }
        }
    }

    private func step(_ entry: RankingEntry, rank: Int) -> some View {
        let isFavorite = entry.athletic.id == favoriteID
        // Altura e tom seguem a posição: empatados ficam no mesmo degrau.
        let level = min(entry.position, 3) - 1
        return NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
            VStack(spacing: Spacing.xs) {
                AthleticBadge(size: rank == 0 ? .large : .prominent, fill: .surface)
                HStack(spacing: Spacing.xxs) {
                    Text(entry.athletic.name)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.center)
                        // Nome de uma palavra só encolhe em vez de quebrar com hífen.
                        .lineLimit(entry.athletic.name.contains(" ") ? 2 : 1)
                        .minimumScaleFactor(0.6)
                    if isFavorite {
                        Image(systemName: "heart.fill").font(.caption)
                    }
                }
                .foregroundStyle(.textPrimary)
                VStack(spacing: 2) {
                    Text("\(entry.position)º")
                        .font(level == 0 ? .largeTitle.bold() : .title.bold())
                    Text(Formatters.points(entry.points))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity, minHeight: [112, 88, 72][level])
                .background([Color.surfaceSelected, Color.surface, Color.surface][level],
                            in: UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card))
                .overlay {
                    if isFavorite {
                        UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card)
                            .strokeBorder(.borderStrong, lineWidth: 2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pressableCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([entry.isTied ? "\(entry.position)º lugar, empatada" : "\(entry.position)º lugar",
                             entry.athletic.name, Formatters.points(entry.points),
                             isFavorite ? "sua atlética" : nil].compactMap { $0 }.joined(separator: ", "))
        .accessibilityHint("Abre a atlética")
    }
}

// MARK: - Previews

private func rankingPreview(_ scenario: LabScenario, favorite: Athletic.ID? = "ath-bufalos") -> some View {
    NavigationStack { RankingView() }
        .environment(AppState(favoriteAthletic: favorite.map { MockData.athletic($0) }, scenario: scenario, preloaded: true))
}

#Preview("Série Ouro") { rankingPreview(.filled) }
#Preview("Empate no pódio (Prata)") { rankingPreview(.filled, favorite: "ath-diastolica") }
#Preview("Divisão sem classificação") { rankingPreview(.filled, favorite: "ath-severa") }
#Preview("Não disponível") { rankingPreview(.empty) }
#Preview("Carregando") { rankingPreview(.loading) }
#Preview("Erro") { rankingPreview(.error) }
