import SwiftUI

/// Telas 10, 11 e 12 — Detalhes da atlética: resumo fixo no topo e três abas
/// (Jogos, Sobre, Modalidades). O coração na barra torna a atlética "de coração".
struct AthleticDetailView: View {
    enum Tab: Hashable, CaseIterable {
        case matches, about, sports

        var title: String {
            switch self {
            case .matches: "Jogos"
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
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) { favoriteButton(athletic) }
                    }
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
                                    isFavorite: athletic.id == appState.favoriteAthletic?.id)
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

    /// Torcer por esta atlética (ou deixar de torcer), o mesmo efeito da troca na Início.
    private func favoriteButton(_ athletic: Athletic) -> some View {
        let isFavorite = athletic.id == appState.favoriteAthletic?.id
        return Button {
            appState.setFavorite(isFavorite ? nil : athletic)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
        }
        .accessibilityLabel(isFavorite ? "Deixar de torcer por \(athletic.name)" : "Torcer por \(athletic.name)")
        .sensoryFeedback(.selection, trigger: isFavorite)
    }
}

// MARK: - Resumo

/// Escudo, nome, instituição e números da atlética. Dados ausentes aparecem como "—".
private struct AthleticSummaryCard: View {
    let athletic: Athletic
    let entry: RankingEntry?
    let profile: AthleticProfile
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                AthleticBadge(size: .large, fill: .surface)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(athletic.name)
                        .font(.title3.bold())
                        .foregroundStyle(.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(athletic.institution)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                    if isFavorite {
                        Label("Sua atlética", systemImage: "heart.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.textPrimary)
                            .padding(.top, 2)
                    }
                }
            }
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: Spacing.xs) { stats }
                Grid(alignment: .leading, horizontalSpacing: Spacing.m, verticalSpacing: Spacing.s) {
                    GridRow { stat(athletic.division.name, "Divisão"); stat(place, "Lugar") }
                    GridRow { stat(pointsText, "Pontos"); stat(fansText, "Torcedores") }
                }
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground, in: RoundedRectangle(cornerRadius: Radius.card))
    }

    @ViewBuilder
    private var stats: some View {
        stat(athletic.division.name, "Divisão")
        stat(place, "Lugar")
        stat(pointsText, "Pontos")
        stat(fansText, "Torcedores")
    }

    private var place: String {
        guard let entry else { return "—" }
        return entry.isTied ? "\(entry.position)º =" : "\(entry.position)º"
    }

    private var pointsText: String {
        entry.map { $0.points.formatted(.number.locale(Locale(identifier: "pt_BR"))) } ?? "—"
    }

    private var fansText: String {
        profile.fanCount.map { $0.formatted(.number.locale(Locale(identifier: "pt_BR"))) } ?? "—"
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value == "—" ? "sem dados" : value.replacingOccurrences(of: " =", with: ", empatada"))")
    }
}

// MARK: - Jogos (tela 11)

/// Ao vivo, próximos e últimos jogos da atlética, com "Ver mais" para a lista completa.
private struct AthleticMatchesTab: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        switch appState.matchesState {
        case .loading:
            ProgressView("Carregando jogos")
                .frame(maxWidth: .infinity, minHeight: 120)
        case .failed:
            VStack(spacing: Spacing.s) {
                InlineNote(systemImage: "wifi.exclamationmark", text: "Não foi possível carregar os jogos.")
                Button("Tentar novamente") { Task { await appState.retry() } }
                    .buttonStyle(.secondary)
            }
        case .unavailable:
            InlineNote(systemImage: "calendar.badge.exclamationmark", text: "Nenhuma edição em andamento.")
        case .loaded(let all):
            let matches = all.filter { $0.involves(athletic.id) }
            if matches.isEmpty {
                InlineNote(systemImage: "calendar",
                           text: "\(athletic.name) ainda não tem jogos no cronograma publicado.")
            } else {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    let live = matches.filter { $0.status == .live }
                    if !live.isEmpty {
                        section("Ao vivo", matches: live, kind: nil)
                    }
                    section(MatchListKind.upcoming.title, matches: MatchListKind.upcoming.select(from: matches), kind: .upcoming)
                    section(MatchListKind.recent.title, matches: MatchListKind.recent.select(from: matches), kind: .recent)
                }
            }
        }
    }

    private func section(_ title: String, matches: [Match], kind: MatchListKind?) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: title) {
                if let kind, matches.count > 3 {
                    NavigationLink("Ver mais", value: AppRoute.matchList(kind, athletic.id))
                        .frame(minHeight: 44)
                        .accessibilityLabel("Ver mais \(title.lowercased()) de \(athletic.name)")
                }
            }
            if matches.isEmpty, let kind {
                InlineNote(systemImage: kind.emptySymbol, text: kind.emptyMessage)
            }
            ForEach(matches.prefix(3)) { match in
                NavigationLink(value: AppRoute.match(match.id)) {
                    MatchCard(match: match, showsStatus: kind == nil)
                }
                .buttonStyle(.pressableCard)
            }
        }
    }
}

// MARK: - Sobre (tela 10)

private struct AthleticAboutTab: View {
    let athletic: Athletic
    let profile: AthleticProfile

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Informações")
                VStack(alignment: .leading, spacing: Spacing.m) {
                    item("Sigla", athletic.acronym)
                    item("Instituição", athletic.institution)
                }
                .padding(Spacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
            }
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Descrição")
                if let description = profile.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    InlineNote(systemImage: "text.alignleft", text: "Esta atlética ainda não tem descrição.")
                }
            }
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

// MARK: - Modalidades (tela 12)

/// Colocação da atlética em cada modalidade que disputa (dados fictícios).
/// Sem seta: a tela de Modalidade chega no Bloco 4.
private struct AthleticSportsTab: View {
    let athletic: Athletic

    var body: some View {
        let standings = MockData.standings(for: athletic.id)
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Modalidades")
            if standings.isEmpty {
                InlineNote(systemImage: "trophy", text: "\(athletic.name) ainda não disputa modalidades nesta edição.")
            } else {
                VStack(spacing: 1) {
                    ForEach(standings) { standing in
                        row(standing)
                    }
                }
                .background(Color.canvas)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            }
        }
    }

    private func row(_ standing: SportStanding) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: standing.sport.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 44, height: 44)
                .background(.surface, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(standing.sport.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                Text(standing.position.map { "\($0)º lugar" } ?? "Ainda sem resultado")
                    .font(.subheadline)
                    .foregroundStyle(standing.position == nil ? Color.textSecondary : Color.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .accessibilityElement(children: .combine)
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
