import SwiftUI

/// Resumo da agenda da atlética (jogos e provas): ao vivo, próximo e último
/// encerrado. "Ver todos" abre o Cronograma filtrado por esta atlética.
struct AthleticMatchesTab: View {
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

#Preview {
    AthleticMatchesTab(athletic: MockData.athletic("ath-bufalos"))
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
        .padding()
}
