import SwiftUI

/// Linha de lance da partida: período/minuto, placar e descrição com atleta.
struct PlayRow: View {
    let play: Play
    let match: Match
    @ScaledMetric(relativeTo: .caption) private var timeColumnWidth: CGFloat = 64
    @Environment(\.favoriteAthleticID) private var favoriteAthleticID
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            stackedRow
        } else {
            columnsRow
        }
    }

    /// Texto de acessibilidade: período, minuto e placar viram uma linha acima
    /// do lance, liberando a largura para a descrição e os nomes (HIG: empilhar).
    private var stackedRow: some View {
        let team = match.team(play.side)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text([match.sport.periodLabel(play.period), play.minute, "\(play.scoreA)-\(play.scoreB)"]
                .compactMap { $0 }.joined(separator: " · "))
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.textSecondary)
            HStack(alignment: .top, spacing: Spacing.s) {
                badge(team)
                description(team)
            }
        }
        .padding(Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(team: team))
    }

    private var columnsRow: some View {
        let team = match.team(play.side)
        return HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(match.sport.periodLabel(play.period))
                    .font(.caption.weight(.semibold))
                if let minute = play.minute {
                    Text(minute).font(.caption)
                }
                Text("\(play.scoreA)-\(play.scoreB)")
                    .font(.caption)
                    .monospacedDigit()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(.textSecondary)
            .frame(width: timeColumnWidth)
            .padding(.vertical, Spacing.s)

            Rectangle().fill(Color.separatorLine).frame(width: 1)

            HStack(spacing: Spacing.s) {
                badge(team)
                description(team)
            }
            .padding(Spacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.surface)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(team: team))
    }

    private func badge(_ team: Athletic?) -> some View {
        AthleticBadge(size: .small, isFavorite: team != nil && team?.id == favoriteAthleticID)
    }

    private func description(_ team: Athletic?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(play.description)
                .font(.headline)
                .foregroundStyle(.textPrimary)
            Text([team?.name, play.athleteName].compactMap { $0 }.joined(separator: " · "))
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func accessibilityText(team: Athletic?) -> String {
        [match.sport.periodLabel(play.period), play.minute, team?.name, play.description,
         play.athleteName, "placar \(play.scoreA) a \(play.scoreB)"]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

#Preview(traits: .appAppearance) {
    let match = MockData.matches[0]
    if let play = match.plays.first {
        PlayRow(play: play, match: match)
            .padding()
            .background(Color.canvas)
    }
}
