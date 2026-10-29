import SwiftUI

/// Conteúdo de um dia no cronograma: linha do tempo das partidas ou estado vazio do dia.
struct ScheduleDayContent: View {
    @Environment(AppState.self) private var appState
    let dayMatches: [ScheduleItem]
    let selectedDay: Date
    let focus: ScheduleFocus
    let filters: ScheduleFilters
    let nextDay: Date?
    let onSelectNextDay: ((Date) -> Void)?
    let onClearFilters: () -> Void

    var body: some View {
        if dayMatches.isEmpty {
            emptyDayView
        } else {
            ScheduleTimeline(items: dayMatches, focus: focus)
                .id(selectedDay)
                .refreshable { await appState.refresh() }
        }
    }

    private var emptyDayView: some View {
        ContentUnavailableView {
            Label(filters.isEmpty ? "Nenhum jogo ou prova neste dia" : "Nenhum jogo ou prova com esses filtros",
                  systemImage: filters.isEmpty ? "calendar" : "line.3.horizontal.decrease")
        } description: {
            Text(filters.isEmpty
                 ? "Não há jogos nem provas marcados para \(Formatters.fullDay(selectedDay))."
                 : "Tente outro dia ou ajuste os filtros.")
        } actions: {
            if let nextDay {
                Button("Ver \(Formatters.dayTab(nextDay).lowercased() == "hoje" ? "hoje" : Formatters.fullDay(nextDay))") {
                    withAnimation { onSelectNextDay?(nextDay) }
                }
                .buttonStyle(.secondary)
            }
            if !filters.isEmpty {
                Button("Limpar filtros") {
                    withAnimation { onClearFilters() }
                }
                .font(.subheadline.weight(.semibold))
                .underline()
                .foregroundStyle(.textPrimary)
            }
        }
    }
}

#Preview("Com jogos") {
    NavigationStack {
        ScheduleDayContent(
            dayMatches: MockData.matches.prefix(3).map(ScheduleItem.match),
            selectedDay: MockData.scheduleDays[0],
            focus: .upcoming,
            filters: ScheduleFilters(),
            nextDay: nil,
            onSelectNextDay: nil,
            onClearFilters: {}
        )
    }
}
