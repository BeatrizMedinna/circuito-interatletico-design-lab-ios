import SwiftUI

/// Tela 07 — Cronograma publicado: abas de dias, linha do tempo por horário
/// e filtros (tela 08). Mostra só o cronograma publicado (RN-60).
struct ScheduleView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedDay: Date = ScheduleView.defaultDay
    @State private var filters = ScheduleFilters()
    @State private var isShowingFilters = false
    @State private var focus: ScheduleFocus = .upcoming

    var body: some View {
        VStack(spacing: 0) {
            header
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingFilters) {
            ScheduleFilterSheet(items: allItems, applied: $filters)
        }
        .sensoryFeedback(.success, trigger: filters)
        .onAppear(perform: applyPendingRequest)
        .onChange(of: appState.scheduleRequest?.id) { _, _ in applyPendingRequest() }
    }

    /// Aplica o contexto vindo de outra tela: filtros e o dia mais útil para a intenção.
    private func applyPendingRequest() {
        guard let request = appState.scheduleRequest else { return }
        appState.scheduleRequest = nil
        filters = request.filters
        focus = request.focus
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let days = MockData.scheduleDays
        func matching(_ day: Date) -> [ScheduleItem] {
            allItems.filter { calendar.isDate($0.startDate, inSameDayAs: day) && request.filters.includes($0) }
        }
        let day: Date? = switch request.focus {
        case .upcoming:
            days.first { $0 >= today && matching($0).contains(where: \.isOpen) }
                ?? days.first { $0 >= today && !matching($0).isEmpty }
        case .recent:
            days.last { $0 <= today && matching($0).contains { !$0.isOpen } }
        }
        if let day { selectedDay = day }
    }

    /// Hoje, se estiver no cronograma; senão, o primeiro dia.
    private static var defaultDay: Date {
        MockData.scheduleDays.first { Calendar.current.isDateInToday($0) } ?? MockData.scheduleDays.first ?? .now
    }

    /// Partidas e provas do cronograma publicado.
    private var allItems: [ScheduleItem] {
        appState.matches.map(ScheduleItem.match)
            + appState.competitions.filter { $0.trial != nil }.map(ScheduleItem.trial)
    }

    private var hasSchedule: Bool { !allItems.isEmpty }

    // MARK: - Cabeçalho

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.s) {
                Text("Cronograma")
                    .font(.title.bold())
                    .foregroundStyle(.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                if hasSchedule {
                    Button { isShowingFilters = true } label: {
                        CircleIconLabel(systemName: "line.3.horizontal.decrease", isActive: !filters.isEmpty)
                            .overlay(alignment: .topTrailing) { CountBadge(count: filters.activeCount) }
                    }
                    .buttonStyle(.pressableCard)
                    .accessibilityLabel(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos")
                }
            }
            .padding(.horizontal, Spacing.l)

            if hasSchedule {
                DayTabs(days: MockData.scheduleDays, selection: $selectedDay)
                if !filters.isEmpty {
                    activeFilters
                }
            }
        }
        .padding(.top, Spacing.xs)
        .padding(.bottom, hasSchedule ? 0 : Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    /// Filtros aplicados como pílulas removíveis, mais "Limpar".
    private var activeFilters: some View {
        ActiveFiltersBar(onClearAll: { withAnimation { filters = ScheduleFilters() } }) {
            if let sport = filters.sportName {
                RemovableChip(title: sport) { withAnimation { filters.sportName = nil } }
            }
            if let gender = filters.gender {
                RemovableChip(title: gender.label) { withAnimation { filters.gender = nil } }
            }
            if let athletic = MockData.athletics.first(where: { $0.id == filters.athleticID }) {
                RemovableChip(title: athletic.name) { withAnimation { filters.athleticID = nil } }
            }
            if let division = MockData.divisions.first(where: { $0.id == filters.divisionID }) {
                RemovableChip(title: division.name) { withAnimation { filters.divisionID = nil } }
            }
        }
    }

    // MARK: - Conteúdo

    @ViewBuilder
    private var content: some View {
        switch appState.matchesState {
        case .loading:
            ScheduleTimeline(items: MockData.matches.prefix(3).map(ScheduleItem.match), focus: .upcoming)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Carregando cronograma")
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar o cronograma", systemImage: "wifi.exclamationmark")
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
                Text("Quando a próxima edição começar, o cronograma aparece aqui.")
            }
        case .loaded(let all):
            if all.isEmpty {
                ContentUnavailableView {
                    Label("Cronograma ainda não publicado", systemImage: "calendar")
                } description: {
                    Text("Os jogos aparecem aqui assim que a organização publicar o cronograma.")
                }
            } else {
                dayContent
            }
        }
    }

    @ViewBuilder
    private var dayContent: some View {
        let dayMatches = items(on: selectedDay)
        if dayMatches.isEmpty {
            let nextDay = nextDayWithMatches(after: selectedDay)
            ContentUnavailableView {
                Label(filters.isEmpty ? "Nenhum jogo ou prova neste dia" : "Nada com esses filtros",
                      systemImage: filters.isEmpty ? "calendar" : "line.3.horizontal.decrease")
            } description: {
                Text(filters.isEmpty
                     ? "Não há jogos nem provas marcados para \(Formatters.fullDay(selectedDay))."
                     : "Nenhum jogo ou prova de \(Formatters.fullDay(selectedDay)) atende aos filtros.")
            } actions: {
                if let nextDay {
                    Button("Ver \(Formatters.dayTab(nextDay).lowercased() == "hoje" ? "hoje" : Formatters.fullDay(nextDay))") {
                        withAnimation { selectedDay = nextDay }
                    }
                    .buttonStyle(.secondary)
                }
                if !filters.isEmpty {
                    Button("Limpar filtros") { withAnimation { filters = ScheduleFilters() } }
                        .font(.subheadline.weight(.semibold))
                        .underline()
                        .foregroundStyle(.textPrimary)
                }
            }
        } else {
            ScheduleTimeline(items: dayMatches, focus: focus)
                .id(selectedDay)
                .refreshable { await appState.refresh() }
        }
    }

    private func items(on day: Date) -> [ScheduleItem] {
        allItems
            .filter { Calendar.current.isDate($0.startDate, inSameDayAs: day) && filters.includes($0) }
            .sorted { $0.startDate < $1.startDate }
    }

    /// Próximo dia (depois deste; senão, antes) com jogos que atendem aos filtros.
    private func nextDayWithMatches(after day: Date) -> Date? {
        let days = MockData.scheduleDays
        return days.first { $0 > day && !items(on: $0).isEmpty }
            ?? days.last { $0 < day && !items(on: $0).isEmpty }
    }
}

// MARK: - Abas de dias

/// Dias do cronograma ("Hoje" identifica o dia atual). Rola na horizontal e
/// centraliza o dia escolhido.
private struct DayTabs: View {
    let days: [Date]
    @Binding var selection: Date

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        tab(day).id(day)
                    }
                }
                .padding(.horizontal, Spacing.xs)
            }
            .scrollIndicators(.hidden)
            .onAppear { proxy.scrollTo(selection, anchor: .center) }
            .onChange(of: selection) { _, day in
                withAnimation { proxy.scrollTo(day, anchor: .center) }
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func tab(_ day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: selection)
        return Button {
            withAnimation(.snappy) { selection = day }
        } label: {
            VStack(spacing: 2) {
                Text(Formatters.dayTab(day))
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                Capsule()
                    .fill(isSelected ? Color.textPrimary : .clear)
                    .frame(height: 3)
                    .padding(.top, 4)
            }
            .fixedSize()
            .padding(.horizontal, Spacing.s)
            .padding(.top, Spacing.xs)
            .frame(minWidth: 84, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Calendar.current.isDateInToday(day) ? "Hoje, \(Formatters.fullDay(day))" : Formatters.fullDay(day))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Linha do tempo

/// Jogos agrupados por horário de início. A linha fica preta nos horários que já
/// começaram e cinza nos próximos; hoje, a lista abre no jogo ao vivo ou no próximo.
private struct ScheduleTimeline: View {
    let items: [ScheduleItem]
    /// "Últimos jogos" abre no encerrado mais recente; nos demais casos, no que está por vir.
    let focus: ScheduleFocus
    @ScaledMetric(relativeTo: .footnote) private var timeColumnWidth: CGFloat = 40
    /// Em tamanhos de acessibilidade o horário vai para cima dos jogos, liberando a largura.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(slots, id: \.start) { slot in
                        slotRow(slot).id(slot.start)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
            .onAppear {
                if let anchor = anchorSlot { proxy.scrollTo(anchor, anchor: .top) }
            }
        }
    }

    private var slots: [(start: Date, items: [ScheduleItem])] {
        var result: [(start: Date, items: [ScheduleItem])] = []
        for item in items {
            if let last = result.indices.last, result[last].start == item.startDate {
                result[last].items.append(item)
            } else {
                result.append((item.startDate, [item]))
            }
        }
        return result
    }

    /// Hoje: primeiro horário com jogo ao vivo ou ainda por começar.
    private var anchorSlot: Date? {
        if focus == .recent {
            return slots.last { slot in slot.items.contains { !$0.isOpen } }?.start
        }
        guard let first = slots.first, Calendar.current.isDateInToday(first.start) else { return nil }
        return slots.first { slot in slot.items.contains(where: \.isOpen) }?.start
    }

    @ViewBuilder
    private func slotRow(_ slot: (start: Date, items: [ScheduleItem])) -> some View {
        let time = Text(Formatters.time(slot.start))
            .font(.footnote.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.textPrimary)
            .accessibilityAddTraits(.isHeader)
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                time
                cards(slot)
            }
        } else {
            HStack(alignment: .top, spacing: Spacing.xs) {
                // Largura mínima estreita, mas o horário nunca é cortado (cresce com a fonte).
                time
                    .fixedSize()
                    .frame(minWidth: timeColumnWidth, alignment: .leading)
                    .padding(.top, Spacing.s)
                cards(slot)
            }
        }
    }

    private func cards(_ slot: (start: Date, items: [ScheduleItem])) -> some View {
        let hasStarted = slot.start <= .now
        return VStack(spacing: Spacing.s) {
            ForEach(slot.items) { item in
                ScheduleItemLink(item: item)
            }
        }
        .padding(.leading, Spacing.s)
        .padding(.bottom, Spacing.m)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(hasStarted ? Color.textPrimary : Color.surfaceSelected)
                .frame(width: 2)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Cartão de item

/// Partida ou prova do cronograma como link (partida → detalhe; prova → modalidade).
/// Usado na linha do tempo e nas agendas de Atlética e Modalidade.
struct ScheduleItemLink: View {
    let item: ScheduleItem
    var date: Formatters.CardDate = .none
    var showsVenue = true
    /// Substitui o cabeçalho do cartão de partida (ex.: "SEMIFINAL · HOJE, 10:30").
    var matchCaption: ((Match) -> String)? = nil

    var body: some View {
        switch item {
        case .match(let match):
            NavigationLink(value: AppRoute.match(match.id)) {
                MatchCard(match: match, showsStatus: true, date: date, caption: matchCaption?(match),
                          showsVenue: showsVenue)
            }
            .buttonStyle(.pressableCard)
        case .trial(let competition):
            NavigationLink(value: AppRoute.competition(competition.id)) {
                TrialCard(competition: competition, date: date, showsVenue: showsVenue)
            }
            .buttonStyle(.pressableCard)
        }
    }
}

// MARK: - Previews

private func schedulePreview(_ scenario: LabScenario) -> some View {
    NavigationStack { ScheduleView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: scenario, preloaded: true))
}

#Preview("Hoje") { schedulePreview(.filled) }
#Preview("Não publicado") { schedulePreview(.empty) }
#Preview("Carregando") { schedulePreview(.loading) }
#Preview("Erro") { schedulePreview(.error) }
#Preview("Sem edição ativa") { schedulePreview(.unavailable) }
