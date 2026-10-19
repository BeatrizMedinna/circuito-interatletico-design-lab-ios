import SwiftUI

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

#Preview {
    let competition = MockData.competitions[0]
    CompetitionRow(competition: competition, progress: .notStarted(next: nil), isLive: false)
        .padding()
}
