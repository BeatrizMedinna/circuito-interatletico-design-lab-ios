import SwiftUI

/// Critérios da lista de Modalidades (tela 17): uma opção por campo, combináveis.
struct SportsFilters: Equatable {
    var gender: Gender?
    var divisionID: Division.ID?

    var activeCount: Int { [gender != nil, divisionID != nil].filter { $0 }.count }
    var isEmpty: Bool { activeCount == 0 }

    func includes(_ competition: Competition) -> Bool {
        (gender == nil || competition.sport.gender == gender)
            && (divisionID == nil || competition.division.id == divisionID)
    }
}

/// Tela 13 — Modalidades da edição (cada uma por divisão), com busca e filtros.
/// "Minha atlética | Geral" funciona como na Início; Categoria e Divisão continuam nos filtros.
struct SportsView: View {
    @Environment(AppState.self) private var appState
    @State private var query = ""
    @State private var filters = SportsFilters()
    @State private var isShowingFilters = false
    @State private var scope: HomeScope = .favorite

    var body: some View {
        VStack(spacing: 0) {
            header
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingFilters) {
            SportsFilterSheet(competitions: scoped(appState.competitions), applied: $filters)
        }
        .sensoryFeedback(.success, trigger: filters)
        .onChange(of: appState.favoriteAthletic?.id) { _, newValue in
            withAnimation { scope = newValue == nil ? .general : .favorite }
        }
    }

    private var hasCompetitions: Bool { !appState.competitions.isEmpty }

    /// Sem atlética de coração, mostra sempre todas.
    private var effectiveScope: HomeScope {
        appState.favoriteAthletic == nil ? .general : scope
    }

    private func scoped(_ competitions: [Competition]) -> [Competition] {
        guard effectiveScope == .favorite, let favoriteID = appState.favoriteAthletic?.id else { return competitions }
        let matches = appState.matches
        return competitions.filter { $0.involves(favoriteID, matches: matches) }
    }

    // MARK: - Cabeçalho

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Text("Modalidades")
                    .font(.title.bold())
                    .foregroundStyle(.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                if hasCompetitions {
                    Button { isShowingFilters = true } label: {
                        CircleIconLabel(systemName: "line.3.horizontal.decrease", isActive: !filters.isEmpty)
                            .overlay(alignment: .topTrailing) { CountBadge(count: filters.activeCount) }
                    }
                    .buttonStyle(.pressableCard)
                    .accessibilityLabel(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos")
                }
            }
            if hasCompetitions {
                SearchField(prompt: "Buscar modalidade", text: $query)
                if appState.favoriteAthletic != nil {
                    UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
                }
                if !filters.isEmpty { activeFilters }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.xs)
        .padding(.bottom, Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    private var activeFilters: some View {
        ActiveFiltersBar(onClearAll: { withAnimation { filters = SportsFilters() } }) {
            if let gender = filters.gender {
                RemovableChip(title: gender.label) { withAnimation { filters.gender = nil } }
            }
            if let division = MockData.divisions.first(where: { $0.id == filters.divisionID }) {
                RemovableChip(title: division.name) { withAnimation { filters.divisionID = nil } }
            }
        }
        .padding(.horizontal, -Spacing.l)
    }

    // MARK: - Conteúdo

    @ViewBuilder
    private var content: some View {
        switch appState.competitionsState {
        case .loading:
            VStack(spacing: 1) {
                ForEach(MockData.competitions.prefix(5)) { competition in
                    CompetitionRow(competition: competition, progress: .notStarted(next: nil),
                                   isLive: false)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, Spacing.s)
            .redacted(reason: .placeholder)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Carregando modalidades")
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar as modalidades", systemImage: "wifi.exclamationmark")
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
                Text("Quando a próxima edição começar, as modalidades aparecem aqui.")
            }
        case .loaded(let all):
            if all.isEmpty {
                ContentUnavailableView {
                    Label("Modalidades ainda não divulgadas", systemImage: "star")
                } description: {
                    Text("As modalidades aparecem aqui quando a organização configurar a edição.")
                }
            } else {
                list(all)
            }
        }
    }

    @ViewBuilder
    private func list(_ all: [Competition]) -> some View {
        let base = scoped(all)
        let items = base.filter { filters.includes($0) && matchesQuery($0) }
        if base.isEmpty {
            ContentUnavailableView {
                Label("Sua atlética ainda não disputa modalidades", systemImage: "star")
            } description: {
                Text("Quando \(appState.favoriteAthletic?.name ?? "sua atlética") entrar em uma chave ou prova, a modalidade aparece aqui.")
            } actions: {
                Button("Ver todas as modalidades") { withAnimation { scope = .general } }
                    .buttonStyle(.secondary)
            }
        } else if items.isEmpty {
            ContentUnavailableView {
                Label(query.isEmpty ? "Nenhuma modalidade com esses filtros" : "Nenhuma modalidade encontrada",
                      systemImage: query.isEmpty ? "line.3.horizontal.decrease" : "magnifyingglass")
            } description: {
                Text(query.isEmpty ? "Tente outra categoria ou divisão."
                     : filters.isEmpty ? "Confira a grafia ou tente outro nome, como Futsal ou Natação."
                     : "Nada combina com a busca e os filtros juntos. Tente limpar um deles.")
            } actions: {
                if !query.isEmpty {
                    Button("Limpar busca") { query = "" }
                        .buttonStyle(.secondary)
                }
                if !filters.isEmpty {
                    Button("Limpar filtros") { withAnimation { filters = SportsFilters() } }
                        .font(.subheadline.weight(.semibold))
                        .underline()
                        .foregroundStyle(.textPrimary)
                }
            }
        } else {
            let matches = appState.matches
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(items) { competition in
                        NavigationLink(value: AppRoute.competition(competition.id)) {
                            CompetitionRow(competition: competition,
                                           progress: competition.progress(matches: matches),
                                           isLive: competition.hasLiveMatch(in: matches))
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .padding(.vertical, Spacing.s)
            }
            .scrollDismissesKeyboard(.interactively)
            .refreshable { await appState.refresh() }
        }
    }

    /// Busca por modalidade, prova ou esporte, ignorando maiúsculas e acentos.
    private func matchesQuery(_ competition: Competition) -> Bool {
        let term = query.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return true }
        return competition.title.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}

/// Linha da lista: ícone do esporte, nome com categoria, e divisão · momento.
/// Sem datas: o horário do próximo jogo fica na modalidade e no Cronograma.
struct CompetitionRow: View {
    let competition: Competition
    let progress: CompetitionProgress
    let isLive: Bool

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: competition.sport.symbol)
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
                HStack(spacing: Spacing.xs) {
                    Text("\(competition.division.name) · \(progress.shortLabel(isElimination: competition.isElimination))")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                    if isLive { MatchStatusTag(status: .live).fixedSize() }
                }
            }
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, Spacing.s)
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// Tela 17 — Filtros de Modalidades: Categoria e Divisão, com rascunho
/// (✕ descarta, ✓ aplica, "Limpar" zera) e contagem do resultado.
private struct SportsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let competitions: [Competition]
    @Binding var applied: SportsFilters
    @State private var draft: SportsFilters

    init(competitions: [Competition], applied: Binding<SportsFilters>) {
        self.competitions = competitions
        _applied = applied
        _draft = State(initialValue: applied.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    field("Categoria") {
                        FlowChips(options: [Gender.male, .female, .mixed].filter { gender in
                            competitions.contains { $0.sport.gender == gender }
                        }, selection: $draft.gender) { $0.label }
                    }
                    field("Divisão") {
                        FlowChips(options: MockData.divisions,
                                  selection: Binding(get: { MockData.divisions.first { $0.id == draft.divisionID } },
                                                     set: { draft.divisionID = $0?.id })) { $0.name }
                    }
                }
                .padding(Spacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { footer }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Cancelar")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        applied = draft
                        dismiss()
                    } label: { Image(systemName: "checkmark") }
                        .accessibilityLabel("Aplicar filtros")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .sensoryFeedback(.selection, trigger: draft)
    }

    private var footer: some View {
        let count = competitions.filter(draft.includes).count
        return VStack(spacing: Spacing.xs) {
            Text(count == 0 ? "Nenhuma modalidade com esses filtros"
                 : count == 1 ? "1 modalidade" : "\(count) modalidades")
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .contentTransition(.numericText())
                .animation(.snappy, value: count)
            Button {
                withAnimation { draft = SportsFilters() }
            } label: {
                Text("Limpar").frame(maxWidth: .infinity)
            }
            .buttonStyle(.secondary)
            .disabled(draft.isEmpty)
            .opacity(draft.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.xs)
        .background(Color.appBackground.ignoresSafeArea(edges: .bottom))
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

// MARK: - Previews

private func sportsPreview(_ scenario: LabScenario) -> some View {
    NavigationStack { SportsView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: scenario, preloaded: true))
}

#Preview("Lista") { sportsPreview(.filled) }
#Preview("Não divulgadas") { sportsPreview(.empty) }
#Preview("Carregando") { sportsPreview(.loading) }
#Preview("Erro") { sportsPreview(.error) }
