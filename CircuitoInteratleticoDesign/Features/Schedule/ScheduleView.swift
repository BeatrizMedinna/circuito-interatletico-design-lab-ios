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
            ScheduleHeader(
                hasSchedule: hasSchedule,
                selectedDay: $selectedDay,
                filters: $filters,
                onOpenFilters: { isShowingFilters = true }
            )

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

    // MARK: - Conteúdo por Estado

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
                ScheduleDayContent(
                    dayMatches: items(on: selectedDay),
                    selectedDay: selectedDay,
                    focus: focus,
                    filters: filters,
                    nextDay: nextDayWithMatches(after: selectedDay),
                    onSelectNextDay: { selectedDay = $0 },
                    onClearFilters: { filters = ScheduleFilters() }
                )
            }
        }
    }

    // MARK: - Lógica de Agendamento e Seleção de Dia

    private func items(on day: Date) -> [ScheduleItem] {
        allItems
            .filter { Calendar.current.isDate($0.startDate, inSameDayAs: day) && filters.includes($0) }
            .sorted { $0.startDate < $1.startDate }
    }

    private func nextDayWithMatches(after day: Date) -> Date? {
        let days = MockData.scheduleDays
        return days.first { $0 > day && !items(on: $0).isEmpty }
            ?? days.last { $0 < day && !items(on: $0).isEmpty }
    }

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
