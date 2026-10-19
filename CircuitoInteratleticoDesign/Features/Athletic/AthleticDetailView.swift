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

// MARK: - Resumo

/// Escudo, nome, instituição e números da atlética. Dados ausentes aparecem como "—".
private struct AthleticSummaryCard<Action: View>: View {
    let athletic: Athletic
    let entry: RankingEntry?
    let profile: AthleticProfile
    let isFavorite: Bool
    @ViewBuilder var action: Action

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
            Divider()
            action
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

// MARK: - Atlética de coração

/// Ação única e reversível, escrita conforme o estado: escolher, trocar ou remover.
/// Substitui o coração solto na barra, que sugeria favoritar várias atléticas.
private struct FavoriteChoice: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        let current = appState.favoriteAthletic
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if current?.id == athletic.id {
                Text("Esta é a sua atlética de coração. Você vê os jogos e avisos dela em destaque.")
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                Button("Remover atlética de coração") { appState.setFavorite(nil) }
                    .font(.subheadline.weight(.semibold))
                    .underline()
                    .foregroundStyle(.textPrimary)
                    .frame(minHeight: 44)
            } else {
                Button {
                    appState.setFavorite(athletic)
                } label: {
                    Text(current == nil ? "Escolher como atlética de coração" : "Torcer para \(athletic.name)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.secondary)
                Text(current.map { "Hoje você torce por \($0.name). Clique se deseja trocar sua torcida." }
                     ?? "Você acompanha uma atlética por vez e pode trocar quando quiser.")
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .sensoryFeedback(.selection, trigger: current?.id)
    }
}

// MARK: - Agenda (tela 11)

/// Resumo da agenda da atlética (jogos e provas): ao vivo, próximo e último
/// encerrado. "Ver todos" abre o Cronograma filtrado por esta atlética.
private struct AthleticMatchesTab: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        switch appState.matchesState {
        case .loading:
            ProgressView("Carregando agenda")
                .frame(maxWidth: .infinity, minHeight: 120)
        case .failed:
            VStack(spacing: Spacing.s) {
                InlineNote(systemImage: "wifi.exclamationmark", text: "Não foi possível carregar a agenda.")
                Button("Tentar novamente") { Task { await appState.retry() } }
                    .buttonStyle(.secondary)
            }
        case .unavailable:
            InlineNote(systemImage: "calendar.badge.exclamationmark", text: "Nenhuma edição em andamento.")
        case .loaded:
            let items = appState.matches.filter { $0.involves(athletic.id) }.map(ScheduleItem.match)
                + appState.competitions.filter { competition in
                    competition.trial?.participants.contains { $0.id == athletic.id } ?? false
                }.map(ScheduleItem.trial)
            if items.isEmpty {
                InlineNote(systemImage: "calendar",
                           text: "\(athletic.name) ainda não tem jogos nem provas no cronograma publicado.")
            } else {
                AgendaSummary(items: items, filters: ScheduleFilters(athleticID: athletic.id), originName: athletic.name)
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

/// Situação da atlética em cada modalidade que disputa: até onde chegou no
/// mata-mata ou posição e marca na prova. Cada linha abre a modalidade.
private struct AthleticSportsTab: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        let standings = MockData.standings(for: athletic.id, matches: appState.matches)
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Modalidades")
            if standings.isEmpty {
                InlineNote(systemImage: "trophy", text: "\(athletic.name) ainda não disputa modalidades nesta edição.")
            } else {
                VStack(spacing: 1) {
                    ForEach(standings) { standing in
                        NavigationLink(value: AppRoute.competition(standing.competition.id)) {
                            row(standing)
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .background(Color.canvas)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            }
        }
    }

    private func row(_ standing: SportStanding) -> some View {
        let competition = standing.competition
        let isHighlight = standing.status == "Campeã" || standing.status.hasPrefix("1º")
        return HStack(spacing: Spacing.s) {
            Image(systemName: isHighlight ? "trophy.fill" : competition.sport.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 44, height: 44)
                .background(.surface, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(competition.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(standing.status)
                    .font(.subheadline.weight(isHighlight ? .semibold : .regular))
                    .foregroundStyle(isHighlight ? Color.textPrimary : Color.textSecondary)
                Text("\(competition.division.name) · \(competition.format.label)")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Abre a modalidade")
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
