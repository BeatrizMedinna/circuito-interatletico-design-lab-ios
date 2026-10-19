import SwiftUI

/// Tela 15 — Chave do mata-mata. Uma fase por vez (abre na fase atual); cada
/// confronto mostra situação, placar, vencedor e para onde ele segue.
/// Bye avança direto sem jogo (RN-42); confrontos sem atléticas ficam "a definir".
struct BracketTab: View {
    @Environment(AppState.self) private var appState
    let competition: Competition
    @State private var selectedPhase: String?

    var body: some View {
        let matches = appState.matches
        let rounds = competition.rounds(matches: matches)
        if rounds.isEmpty {
            InlineNote(systemImage: "point.3.connected.trianglepath.dotted",
                       text: "A chave ainda não foi definida. Ela aparece aqui depois do sorteio feito pela organização.")
        } else {
            let current = currentPhase(rounds, matches: matches)
            let phase = Binding { selectedPhase ?? current } set: { selectedPhase = $0 }
            VStack(alignment: .leading, spacing: Spacing.m) {
                UnderlineTabs(items: rounds.map(\.phase), selection: phase) { $0 }
                if let round = rounds.first(where: { $0.phase == phase.wrappedValue }) {
                    let next = Phase.next(after: round.phase)
                    ForEach(Array(round.matchups.enumerated()), id: \.element.id) { index, matchup in
                        matchupView(matchup, number: index + 1, next: next, matches: matches)
                    }
                }
            }
        }
    }

    private func currentPhase(_ rounds: [BracketRound], matches: [Match]) -> String {
        rounds.first { round in round.matchups.contains { competition.winner(of: $0, in: matches) == nil } }?.phase
            ?? rounds.last?.phase ?? ""
    }

    @ViewBuilder
    private func matchupView(_ matchup: BracketMatchup, number: Int, next: String?, matches: [Match]) -> some View {
        let card = MatchupCard(competition: competition, matchup: matchup, number: number,
                               nextPhase: next, matches: matches)
        if let matchID = matchup.matchID {
            NavigationLink(value: AppRoute.match(matchID)) { card }
                .buttonStyle(.pressableCard)
                .accessibilityHint("Abre a partida")
        } else {
            card
        }
    }
}

private struct MatchupCard: View {
    let competition: Competition
    let matchup: BracketMatchup
    let number: Int
    let nextPhase: String?
    let matches: [Match]

    var body: some View {
        let match = competition.match(of: matchup, in: matches)
        let teams = competition.teams(of: matchup, in: matches)
        let winner = competition.winner(of: matchup, in: matches)
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Jogo \(number)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.textSecondary)
                Spacer(minLength: Spacing.xs)
                statusLabel(match)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.xs)

            teamRow(teams.a, score: match?.scoreA, side: .a, match: match, winner: winner)
            if matchup.isBye {
                Text("Sem adversário: avança direto, sem jogo (bye).")
                    .font(.subheadline.italic())
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
            } else {
                Divider().padding(.leading, Spacing.m)
                teamRow(teams.b, score: match?.scoreB, side: .b, match: match, winner: winner)
            }

            if let nextPhase {
                Label(winner.map { "\($0.name) segue para a \(nextPhase.lowercased())" }
                      ?? "Quem vencer segue para a \(nextPhase.lowercased())",
                      systemImage: "arrow.turn.down.right")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surfaceSelected.opacity(0.5))
            }
        }
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.card)
                .strokeBorder(.borderStrong, lineWidth: match?.status == .live ? 1.5 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(teams: teams, match: match, winner: winner))
    }

    @ViewBuilder
    private func statusLabel(_ match: Match?) -> some View {
        if matchup.isBye {
            Text("BYE").font(.caption2.weight(.semibold)).foregroundStyle(.textSecondary)
        } else if let match {
            if match.status == .scheduled {
                Text("\(Formatters.dayLabel(match.startDate)), \(Formatters.time(match.startDate))".uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.textSecondary)
            } else {
                MatchStatusTag(status: match.status)
            }
        } else {
            Text("A DEFINIR").font(.caption2.weight(.semibold)).foregroundStyle(.textSecondary)
        }
    }

    private func teamRow(_ athletic: Athletic?, score: Int?, side: MatchSide, match: Match?, winner: Athletic?) -> some View {
        let isWinner = athletic != nil && athletic?.id == winner?.id
        let isLoser = winner != nil && athletic != nil && !isWinner
        return HStack(spacing: Spacing.s) {
            AthleticBadge(size: .small, isUndefined: athletic == nil)
            Text(athletic?.name ?? "A definir")
                .font(isWinner ? .headline : .body)
                .foregroundStyle(athletic == nil || isLoser ? Color.textSecondary : Color.textPrimary)
                .lineLimit(2)
            if isWinner {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.textPrimary)
            }
            Spacer(minLength: Spacing.xs)
            Text(scoreText(score, side: side, match: match))
                .font(isWinner ? .headline.monospacedDigit() : .body.monospacedDigit())
                .foregroundStyle(isLoser ? Color.textSecondary : Color.textPrimary)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
    }

    private func scoreText(_ score: Int?, side: MatchSide, match: Match?) -> String {
        guard let match, match.status != .scheduled else { return matchup.isBye ? "" : "–" }
        if let walkover = match.walkoverWinner { return walkover == side ? "W.O." : "—" }
        return score.map(String.init) ?? "–"
    }

    private func accessibilityText(teams: (a: Athletic?, b: Athletic?), match: Match?, winner: Athletic?) -> String {
        let nameA = teams.a?.name ?? "A definir"
        if matchup.isBye { return "Jogo \(number), bye: \(nameA) avança direto" }
        let nameB = teams.b?.name ?? "A definir"
        var parts = ["Jogo \(number)", "\(nameA) contra \(nameB)"]
        if let match {
            switch match.status {
            case .scheduled: parts.append("\(Formatters.dayLabel(match.startDate)), \(Formatters.time(match.startDate))")
            case .live: parts.append("ao vivo, \(match.scoreA ?? 0) a \(match.scoreB ?? 0)")
            case .finished:
                if match.walkoverWinner != nil { parts.append("W.O.") } else { parts.append("\(match.scoreA ?? 0) a \(match.scoreB ?? 0)") }
            }
        } else {
            parts.append("a definir")
        }
        if let winner { parts.append("vencedora: \(winner.name)") }
        return parts.joined(separator: ", ")
    }
}
