import SwiftUI

/// Linha de lance da partida: período/minuto, placar e descrição com atleta.
struct PlayRow: View {
    let play: Play
    let match: Match
    @ScaledMetric(relativeTo: .caption) private var timeColumnWidth: CGFloat = 64

    var body: some View {
        let team = match.team(play.side)
        HStack(spacing: 0) {
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

            Rectangle().fill(Color.canvas).frame(width: 1)

            HStack(spacing: Spacing.s) {
                AthleticBadge(size: .small)
                VStack(alignment: .leading, spacing: 2) {
                    Text(play.description)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text([team?.name, play.athleteName].compactMap { $0 }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding(Spacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.surface)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(team: team))
    }

    private func accessibilityText(team: Athletic?) -> String {
        [match.sport.periodLabel(play.period), play.minute, team?.name, play.description,
         play.athleteName, "placar \(play.scoreA) a \(play.scoreB)"]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

#Preview {
    let match = MockData.matches[0]
    if let play = match.plays.first {
        PlayRow(play: play, match: match)
            .padding()
            .background(Color.canvas)
    }
}
