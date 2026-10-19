import SwiftUI

/// Três primeiros na ordem 2º · 1º · 3º, com degraus de alturas diferentes.
/// Empates mostram a mesma posição em dois degraus.
struct Podium: View {
    let entries: [RankingEntry]
    let favoriteID: Athletic.ID?

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            ForEach([1, 0, 2], id: \.self) { index in
                if index < entries.count {
                    step(entries[index], rank: index)
                } else {
                    Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
                }
            }
        }
    }

    private func step(_ entry: RankingEntry, rank: Int) -> some View {
        let isFavorite = entry.athletic.id == favoriteID
        // Altura e tom seguem a posição: empatados ficam no mesmo degrau.
        let level = min(entry.position, 3) - 1
        return NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
            VStack(spacing: Spacing.xs) {
                AthleticBadge(size: rank == 0 ? .large : .prominent, fill: .surface)
                HStack(spacing: Spacing.xxs) {
                    Text(entry.athletic.name)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.center)
                        // Nome de uma palavra só encolhe em vez de quebrar com hífen.
                        .lineLimit(entry.athletic.name.contains(" ") ? 2 : 1)
                        .minimumScaleFactor(0.6)
                    if isFavorite {
                        Image(systemName: "heart.fill").font(.caption)
                    }
                }
                .foregroundStyle(.textPrimary)
                VStack(spacing: 2) {
                    Text("\(entry.position)º")
                        .font(level == 0 ? .largeTitle.bold() : .title.bold())
                    Text(Formatters.points(entry.points))
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity, minHeight: [112, 88, 72][level])
                .background([Color.surfaceSelected, Color.surface, Color.surface][level],
                            in: UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card))
                .overlay {
                    if isFavorite {
                        UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card)
                            .strokeBorder(.borderStrong, lineWidth: 2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pressableCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([entry.isTied ? "\(entry.position)º lugar, empatada" : "\(entry.position)º lugar",
                             entry.athletic.name, Formatters.points(entry.points),
                             isFavorite ? "sua atlética" : nil].compactMap { $0 }.joined(separator: ", "))
        .accessibilityHint("Abre a atlética")
    }
}

#Preview {
    NavigationStack {
        Podium(entries: Array(MockData.rankings[0].entries.prefix(3)), favoriteID: "ath-bufalos")
            .padding()
    }
}
