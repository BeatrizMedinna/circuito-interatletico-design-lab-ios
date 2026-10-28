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
                    // Mesma solução de Modalidades: botão fixo de 44 pt que para de crescer
                    // no maior tamanho padrão; tocar e segurar mostra o rótulo ampliado.
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    .accessibilityLabel(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos")
                    .accessibilityShowsLargeContentViewer {
                        Label(filters.isEmpty ? "Filtros" : "Filtros, \(filters.activeCount) ativos",
                              systemImage: "line.3.horizontal.decrease")
                    }
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
            // Uma pílula por escolha, em ordem estável; cada uma sai sozinha.
            ForEach(filters.sportNames.sorted(), id: \.self) { sport in
                RemovableChip(title: sport) { withAnimation { _ = filters.sportNames.remove(sport) } }
            }
            ForEach([Gender.male, .female, .mixed].filter(filters.genders.contains), id: \.self) { gender in
                RemovableChip(title: gender.label) { withAnimation { _ = filters.genders.remove(gender) } }
            }
            ForEach(MockData.athletics.filter { filters.athleticIDs.contains($0.id) }) { athletic in
                RemovableChip(title: athletic.name) { withAnimation { _ = filters.athleticIDs.remove(athletic.id) } }
            }
            ForEach(MockData.divisions.filter { filters.divisionIDs.contains($0.id) }) { division in
                RemovableChip(title: division.name) { withAnimation { _ = filters.divisionIDs.remove(division.id) } }
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
