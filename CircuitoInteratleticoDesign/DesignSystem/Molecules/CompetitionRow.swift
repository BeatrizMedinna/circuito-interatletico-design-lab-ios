import SwiftUI

/// Linha da lista: ícone do esporte, nome com categoria, e divisão · momento.
/// Sem datas: o horário do próximo jogo fica na modalidade e no Cronograma.
struct CompetitionRow: View {
    let competition: Competition
    let progress: CompetitionProgress
    let isLive: Bool

    private var detail: some View {
        Text("\(competition.division.name) · \(progress.shortLabel(isElimination: competition.isElimination))")
            .font(.subheadline)
            .foregroundStyle(.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var liveTag: some View {
        if isLive { MatchStatusTag(status: .live).fixedSize() }
    }

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: competition.sport.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 44, height: 44)
                .background(.surfaceInset, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(competition.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                // O selo "Ao vivo" desce para a linha de baixo quando não cabe ao lado
                // (texto grande), em vez de apertar a divisão e a etapa.
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: Spacing.xs) { detail; liveTag }
                    VStack(alignment: .leading, spacing: Spacing.xxs) { detail; liveTag }
                }
            }
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, Spacing.s)
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .appAppearance) {
    let competition = MockData.competitions[0]
    CompetitionRow(competition: competition, progress: .notStarted(next: nil), isLive: false)
        .padding()
}
