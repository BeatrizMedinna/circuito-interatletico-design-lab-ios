import SwiftUI

/// Cartão de resumo da modalidade: ícone, título, divisão, formato, etapa/situação e campeã se houver.
struct CompetitionSummaryCard: View {
    let competition: Competition
    let progress: CompetitionProgress
    let isLive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                Image(systemName: competition.sport.symbol)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 80, height: 80)
                    .background(.surfaceInset, in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(competition.eventName ?? competition.sport.name)
                        .font(.title3.bold())
                        .foregroundStyle(.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(competition.eventName == nil ? competition.sport.gender.label
                         : "\(competition.sport.name) \(competition.sport.gender.label)")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                    Text(competition.format.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .overlay { Capsule().strokeBorder(.borderStrong, lineWidth: 1) }
                        .padding(.top, 2)
                }
            }
            HStack(alignment: .top, spacing: Spacing.xs) {
                stat(competition.division.name, "Divisão")
                stat(stageValue, competition.isElimination ? "Etapa" : "Situação")
                stat(competition.registeredAthletes.map(String.init) ?? "—", "Atletas")
            }
            if isLive {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.live)
                        .symbolEffect(.pulse)
                    Text("Jogo ao vivo agora")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .accessibilityElement(children: .combine)
            }
            if case .finished(let champion?) = progress {
                Label {
                    Text("Campeã: \(champion.name)").foregroundStyle(.textPrimary)
                } icon: {
                    Image(systemName: "trophy.fill").foregroundStyle(.brandPrimary)
                }
                .font(.subheadline.weight(.semibold))
                .padding(Spacing.s)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surfaceInset, in: RoundedRectangle(cornerRadius: Radius.control))
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private var stageValue: String {
        switch progress {
        case .notGenerated: "—"
        case .notStarted: competition.isElimination ? "A iniciar" : "Agendada"
        case .inProgress(let phase): competition.isElimination ? phase : "Parcial"
        case .finished: "Encerrada"
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value == "—" ? "sem dados" : value)")
    }
}

#Preview(traits: .appAppearance) {
    let competition = MockData.competitions[0]
    CompetitionSummaryCard(competition: competition, progress: .notStarted(next: nil), isLive: false)
        .padding()
        .background(Color.canvas)
}
