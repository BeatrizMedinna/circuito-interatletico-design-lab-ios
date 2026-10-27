import SwiftUI

/// Cabeçalho da tela de Cronograma: título, botão de filtros com contador, abas de dias e barra de filtros ativos.
struct ScheduleHeader: View {
    let hasSchedule: Bool
    @Binding var selectedDay: Date
    @Binding var filters: ScheduleFilters
    let onOpenFilters: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.s) {
                Text("Cronograma")
                    .font(.title.bold())
                    .foregroundStyle(.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                if hasSchedule {
                    Button(action: onOpenFilters) {
                        CircleIconLabel(systemName: "line.3.horizontal.decrease", isActive: !filters.isEmpty)
                            .overlay(alignment: .topTrailing) { CountBadge(count: filters.activeCount, onAccent: true) }
                    }
                    .buttonStyle(.pressableCard)
                    .accessibilityLabel(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos")
                }
            }
            .padding(.horizontal, Spacing.l)

            if hasSchedule {
                DayTabs(days: MockData.scheduleDays, selection: $selectedDay)
                    // Trilho das abas de ponta a ponta, como na Início e em Notificações.
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(.separatorLine).frame(height: 1)
                    }
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
}

#Preview {
    ScheduleHeader(
        hasSchedule: true,
        selectedDay: .constant(MockData.scheduleDays[0]),
        filters: .constant(ScheduleFilters()),
        onOpenFilters: {}
    )
}
