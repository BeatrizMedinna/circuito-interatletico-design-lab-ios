import SwiftUI

/// Selo "● Ao vivo". O ponto pulsa (o sistema desliga com "Reduzir movimento").
struct LiveBadge: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .symbolEffect(.pulse)
            Text("Ao vivo")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.textPrimary)
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, 6)
        .background(.appBackground, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

/// "Atualizado há 8 s", contando sozinho a cada segundo.
struct UpdatedAgoText: View {
    let date: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(Formatters.updatedAgo(since: date, now: context.date))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.textSecondary)
        }
    }
}

/// Cartão grande da partida: carrossel "Ao vivo" da Home e topo do detalhe.
struct MatchHeaderCard: View {
    let match: Match
    var lastRefresh: Date = .now
    var showsLiveBadge = false

    var body: some View {
        VStack(spacing: Spacing.s) {
            if match.status == .live {
                HStack {
                    if showsLiveBadge { LiveBadge() }
                    Spacer(minLength: Spacing.xs)
                    UpdatedAgoText(date: lastRefresh)
                }
            }

            VStack(spacing: 2) {
                Text(match.sport.name)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                Text(match.sport.gender.label)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityElement(children: .combine)

            HStack(alignment: .top, spacing: Spacing.xs) {
                TeamColumn(athletic: match.teamA, badgeSize: .prominent, isDimmed: match.isLoser(.a))
                ScoreBoxes(match: match, size: .large)
                TeamColumn(athletic: match.teamB, badgeSize: .prominent, isDimmed: match.isLoser(.b))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(scoreAccessibilityLabel)

            if match.status == .live, let period = match.currentPeriod {
                Text([match.sport.periodLabel(period), match.clock].compactMap { $0 }.joined(separator: " · "))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.textPrimary)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 6)
                    .background(.surfaceSelected, in: Capsule())
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.card)
                .strokeBorder(.borderStrong, lineWidth: match.status == .live ? 1.5 : 0)
        }
        .teamSideBars()
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
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

#Preview {
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
