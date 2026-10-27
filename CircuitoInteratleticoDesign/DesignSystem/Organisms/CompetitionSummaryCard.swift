import SwiftUI

/// Cartão de resumo da modalidade: ícone, título, divisão, formato, etapa/situação e campeã se houver.
struct CompetitionSummaryCard: View {
    let competition: Competition
    let progress: CompetitionProgress
    let isLive: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Em tamanhos de acessibilidade o ícone vai para cima do nome (como no perfil da atlética).
        let identity = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.s))
            : AnyLayout(HStackLayout(spacing: Spacing.m))
        VStack(alignment: .leading, spacing: Spacing.m) {
            identity {
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
                        .fixedSize(horizontal: false, vertical: true)
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
            // Três colunas só quando cabem sem quebrar palavras ("Semi-final");
            // senão, uma linha por número, rótulo acima do valor.
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    stat(competition.division.name, "Divisão")
                    stat(stageValue, stageLabel)
                    stat(athletesText, "Atletas")
                }
                VStack(alignment: .leading, spacing: Spacing.s) {
                    statRow(competition.division.name, "Divisão")
                    statRow(stageValue, stageLabel)
                    statRow(athletesText, "Atletas")
                }
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

    private var stageLabel: String { competition.isElimination ? "Etapa" : "Situação" }
    private var athletesText: String { competition.registeredAthletes.map(String.init) ?? "—" }

    private var stageValue: String {
        switch progress {
        case .notGenerated: "—"
        case .notStarted: competition.isElimination ? "A iniciar" : "Agendada"
        case .inProgress(let phase): competition.isElimination ? phase : "Parcial"
        case .finished: "Encerrada"
        }
    }

    private func statRow(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value == "—" ? "sem dados" : value)")
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            // Uma linha, sem reduzir: se não couber, o ViewThatFits usa a coluna única.
            Text(value)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .fixedSize()
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
