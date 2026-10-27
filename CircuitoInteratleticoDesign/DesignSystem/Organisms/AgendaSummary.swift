import SwiftUI

/// Recorte resumido de uma agenda: tudo que está ao vivo, o próximo evento e
/// o último encerrado. Compartilhado entre os perfis de Atlética e Modalidade.
struct AgendaSelection {
    let live: [ScheduleItem]
    let next: ScheduleItem?
    let lastFinished: ScheduleItem?
    /// Há mais eventos ao vivo/futuros ou encerrados do que os mostrados.
    let hasMoreUpcoming: Bool
    let hasMoreFinished: Bool

    init(_ items: [ScheduleItem]) {
        let open = items.filter(\.isOpen).sorted { $0.startDate < $1.startDate }
        let finished = items.filter { !$0.isOpen }.sorted { $0.startDate > $1.startDate }
        live = open.filter(\.isLive)
        next = open.first { !$0.isLive }
        lastFinished = finished.first
        hasMoreUpcoming = open.count > live.count + (next == nil ? 0 : 1)
        hasMoreFinished = finished.count > 1
    }

    var upcoming: [ScheduleItem] { live + [next].compactMap { $0 } }
    var isEmpty: Bool { upcoming.isEmpty && lastFinished == nil }
}

/// Resumo de agenda com "Ao vivo e próximos" e "Último encerrado". Cada
/// "Ver todos" abre o Cronograma com os filtros de origem e o foco da seção;
/// só aparece quando há mais eventos do que os mostrados. Seções vazias somem.
struct AgendaSummary: View {
    @Environment(AppState.self) private var appState
    let items: [ScheduleItem]
    /// Filtros que reproduzem a origem no Cronograma (atlética ou modalidade).
    let filters: ScheduleFilters
    /// Nome da origem, para o VoiceOver ("de Búfalos").
    let originName: String
    /// Cabeçalho alternativo para partidas (ex.: fase dentro da modalidade).
    var matchCaption: ((Match) -> String)? = nil
    /// Só apresentação: cartões de partida empilham em texto muito grande
    /// (ver `ScheduleItemLink.adaptsMatchLayout`). A seleção dos eventos,
    /// a ordem e o "Ver todos" não mudam. Opcional: hoje só o perfil da Atlética liga.
    var adaptsMatchLayout = false

    var body: some View {
        let selection = AgendaSelection(items)
        VStack(alignment: .leading, spacing: Spacing.xl) {
            if !selection.upcoming.isEmpty {
                section("Ao vivo e próximo", selection.upcoming,
                        showsAll: selection.hasMoreUpcoming, focus: .upcoming)
            }
            if let last = selection.lastFinished {
                section("Último encerrado", [last], showsAll: selection.hasMoreFinished, focus: .recent)
            }
        }
    }

    private func section(_ title: String, _ items: [ScheduleItem], showsAll: Bool, focus: ScheduleFocus) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: title) {
                if showsAll {
                    Button("Ver todos") { appState.openSchedule(filters: filters, focus: focus) }
                        .frame(minHeight: 44)
                        .accessibilityLabel("Ver todos: \(title.lowercased()) de \(originName)")
                        .accessibilityHint("Abre o cronograma filtrado")
                }
            }
            ForEach(items) { item in
                ScheduleItemLink(item: item, date: .dayAndTime, showsVenue: false,
                                 matchCaption: matchCaption, adaptsMatchLayout: adaptsMatchLayout)
            }
        }
    }
}
