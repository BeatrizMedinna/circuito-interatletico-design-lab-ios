import SwiftUI

/// Jogos agrupados por horário de início. O trilho fica em cinza forte nos horários
/// que já começaram e discreto nos próximos; hoje, a lista abre no jogo ao vivo ou no próximo.
struct ScheduleTimeline: View {
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
            .font(.subheadline.weight(.semibold))
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
                // Nomes longos e texto grande empilham os times em vez de truncar.
                ScheduleItemLink(item: item, adaptsMatchLayout: true)
            }
        }
        .padding(.leading, Spacing.s)
        .padding(.bottom, Spacing.m)
        // Trilho: horários já iniciados em cinza forte (4,1:1), próximos em cinza discreto.
        // Antes era branco, pesado demais no Dark; a diferença continua visível.
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(hasStarted ? Color.borderStrong : Color.separatorLine)
                .frame(width: 2)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleTimeline(
            items: MockData.matches.prefix(3).map(ScheduleItem.match),
            focus: .upcoming
        )
    }
}
