import SwiftUI

/// Cartão grande da partida: carrossel "Ao vivo" da Home e topo do detalhe.
struct MatchHeaderCard: View {
    let match: Match
    var lastRefresh: Date = .now
    var showsLiveBadge = false
    /// No detalhe da partida, cada time abre a atlética (não usar dentro de outro link).
    var linksTeams = false
    /// Em tamanhos de acessibilidade, troca as três colunas (time, placar, time)
    /// por linhas empilhadas para os nomes não truncarem. Opcional: a Início e o
    /// detalhe da partida usam.
    var stacksAtAccessibilitySizes = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isStacked: Bool {
        // Nome longo não muda o layout: colunas sempre, nome em até 2 linhas com "…".
        stacksAtAccessibilitySizes && dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        VStack(spacing: Spacing.s) {
            if match.status == .live {
                let status = isStacked
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xs))
                    : AnyLayout(HStackLayout())
                status {
                    if showsLiveBadge { LiveBadge() }
                    if !isStacked { Spacer(minLength: Spacing.xs) }
                    UpdatedAgoText(date: lastRefresh)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(spacing: 2) {
                Text(match.sport.name)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.textPrimary)
                Text(match.sport.gender.label)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityElement(children: .combine)

            teamsAndScore

            if match.status == .live, let period = match.currentPeriod {
                Text([match.sport.periodLabel(period), match.clock].compactMap { $0 }.joined(separator: " · "))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.textPrimary)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 6)
                    .background(.surfaceInset, in: Capsule())
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        .cardSurface(.emphasized, highlighted: match.status == .live)
    }

    @ViewBuilder
    private var teamsAndScore: some View {
        if isStacked {
            let stack = VStack(spacing: Spacing.s) {
                stackedTeam(.a)
                ScoreBoxes(match: match, size: .large)
                    .overlay {
                        if linksTeams {
                            Color.clear
                                .accessibilityElement()
                                .accessibilityLabel(scoreAccessibilityLabel)
                        }
                    }
                stackedTeam(.b)
            }
            if linksTeams {
                stack.accessibilityElement(children: .contain)
            } else {
                stack.accessibilityElement(children: .ignore)
                    .accessibilityLabel(scoreAccessibilityLabel)
            }
        } else {
            columns
        }
    }

    /// Linha do time no layout empilhado; no detalhe continua abrindo a atlética.
    @ViewBuilder
    private func stackedTeam(_ side: MatchSide) -> some View {
        let row = TeamRow(athletic: match.team(side), isDimmed: match.isLoser(side))
        if linksTeams, let athletic = match.team(side) {
            NavigationLink(value: AppRoute.athletic(athletic.id)) { row }
                .buttonStyle(.pressableCard)
                .accessibilityLabel("\(athletic.name), ver atlética")
        } else {
            row
        }
    }

    @ViewBuilder
    private var columns: some View {
        let row = HStack(alignment: .top, spacing: Spacing.xs) {
            team(.a)
            ScoreBoxes(match: match, size: .large)
                .overlay {
                    if linksTeams {
                        Color.clear
                            .accessibilityElement()
                            .accessibilityLabel(scoreAccessibilityLabel)
                    }
                }
            team(.b)
        }
        if linksTeams {
            row.accessibilityElement(children: .contain)
        } else {
            row.accessibilityElement(children: .ignore)
                .accessibilityLabel(scoreAccessibilityLabel)
        }
    }

    @ViewBuilder
    private func team(_ side: MatchSide) -> some View {
        let column = TeamColumn(athletic: match.team(side), badgeSize: .prominent, isDimmed: match.isLoser(side))
        if linksTeams, let athletic = match.team(side) {
            NavigationLink(value: AppRoute.athletic(athletic.id)) { column }
                .buttonStyle(.pressableCard)
                .accessibilityLabel("\(athletic.name), ver atlética")
        } else {
            column
        }
    }

    private var scoreAccessibilityLabel: String {
        let nameA = match.teamA?.name ?? "A definir"
        let nameB = match.teamB?.name ?? "A definir"
        if let side = match.walkoverWinner, let team = match.team(side) {
            return "Vitória de \(team.name) por W.O."
        }
        if match.status == .scheduled {
            return "\(nameA) contra \(nameB)"
        }
        return "\(nameA) \(match.scoreA ?? 0), \(nameB) \(match.scoreB ?? 0)"
    }
}

#Preview(traits: .appAppearance) {
    ScrollView {
        VStack(spacing: Spacing.m) {
            MatchHeaderCard(match: MockData.matches[0], showsLiveBadge: true)
            MatchHeaderCard(match: MockData.matches[1], showsLiveBadge: true)
            MatchHeaderCard(match: MockData.matches[5])
            MatchHeaderCard(match: MockData.matches[11])
        }
        .padding()
    }
    .background(.canvas)
}
