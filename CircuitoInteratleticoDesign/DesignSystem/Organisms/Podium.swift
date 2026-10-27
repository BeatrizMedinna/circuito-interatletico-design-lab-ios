import SwiftUI

/// Três primeiros na ordem 2º · 1º · 3º, com degraus de alturas diferentes.
/// Empates mostram a mesma posição em dois degraus e o rótulo "Empate".
/// Em tamanhos de acessibilidade, os três degraus viram uma lista na ordem da
/// classificação (HIG: menos colunas em vez de cortar nomes e pontos).
struct Podium: View {
    let entries: [RankingEntry]
    let favoriteID: Athletic.ID?
    @Environment(\.favoriteAthleticID) private var environmentFavoriteID
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: Spacing.xs) {
                ForEach(entries) { entry in
                    listRow(entry)
                }
            }
        } else {
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
    }

    private func isFavorite(_ entry: RankingEntry) -> Bool {
        entry.athletic.id == (favoriteID ?? environmentFavoriteID)
    }

    // MARK: - Degraus (tamanhos padrão)

    private func step(_ entry: RankingEntry, rank: Int) -> some View {
        let isFavorite = isFavorite(entry)
        // Altura e tom seguem a posição: empatados ficam no mesmo degrau.
        let level = min(entry.position, 3) - 1
        return NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
            VStack(spacing: Spacing.xs) {
                AthleticBadge(size: rank == 0 ? .large : .prominent, isFavorite: isFavorite)
                HStack(spacing: Spacing.xxs) {
                    Text(entry.athletic.name)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.center)
                        // Nome de uma palavra só encolhe um pouco em vez de quebrar com hífen.
                        .lineLimit(entry.athletic.name.contains(" ") ? 3 : 1)
                        .minimumScaleFactor(0.75)
                    if isFavorite {
                        Image(systemName: "heart.fill").font(.caption).foregroundStyle(.favoriteAccent)
                    }
                }
                .foregroundStyle(.textPrimary)
                VStack(spacing: 2) {
                    Text("\(entry.position)º")
                        .font(.sportNumber(level == 0 ? .largeTitle : .title))
                        .foregroundStyle(level == 0 ? Color.brandPrimary : Color.textPrimary)
                    Text(Formatters.points(entry.points))
                        .font(.footnote.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.textSecondary)
                        .fixedSize()
                    if entry.isTied {
                        tieLabel
                    }
                }
                .padding(.vertical, Spacing.xs)
                .frame(maxWidth: .infinity, minHeight: [112, 88, 72][level])
                .background([Color.surfaceSelected, Color.surfaceInset, Color.surfaceInset][level],
                            in: UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card))
                // Primeiro lugar com faixa Lime no topo do degrau.
                .overlay(alignment: .top) {
                    if level == 0 {
                        UnevenRoundedRectangle(topLeadingRadius: Radius.card, topTrailingRadius: Radius.card)
                            .fill(.actionPrimary)
                            .frame(height: 3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.pressableCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(entry))
        .accessibilityHint("Abre a atlética")
    }

    // MARK: - Lista (tamanhos de acessibilidade)

    private func listRow(_ entry: RankingEntry) -> some View {
        let isFavorite = isFavorite(entry)
        let isLeader = entry.position == 1
        return NavigationLink(value: AppRoute.athletic(entry.athletic.id)) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.s) {
                    Text("\(entry.position)º")
                        .font(.sportNumber(.title))
                        .foregroundStyle(isLeader ? Color.brandPrimary : Color.textPrimary)
                    AthleticBadge(size: .medium, isFavorite: isFavorite)
                    Spacer(minLength: 0)
                }
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                    Text(entry.athletic.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if isFavorite {
                        Image(systemName: "heart.fill").font(.caption).foregroundStyle(.favoriteAccent)
                    }
                }
                Text(Formatters.points(entry.points))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.textSecondary)
                if entry.isTied {
                    tieLabel
                }
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isLeader ? Color.surfaceSelected : Color.surfaceInset,
                        in: RoundedRectangle(cornerRadius: Radius.card))
            // O líder mantém a faixa Lime, agora à esquerda.
            .overlay(alignment: .leading) {
                if isLeader {
                    UnevenRoundedRectangle(topLeadingRadius: Radius.card, bottomLeadingRadius: Radius.card)
                        .fill(.actionPrimary)
                        .frame(width: 4)
                }
            }
        }
        .buttonStyle(.pressableCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText(entry))
        .accessibilityHint("Abre a atlética")
    }

    // MARK: - Partes comuns

    /// Mesmo texto das linhas da lista ("empate"), em rótulo de caixa alta.
    private var tieLabel: some View {
        Label("Empate", systemImage: "equal")
            .labelStyle(.titleAndIcon)
            .textCase(.uppercase)
            .font(.eyebrow)
            .tracking(0.6)
            .foregroundStyle(.textSecondary)
            .accessibilityHidden(true)
    }

    private func accessibilityText(_ entry: RankingEntry) -> String {
        [entry.isTied ? "\(entry.position)º lugar, empatada" : "\(entry.position)º lugar",
         entry.athletic.name, Formatters.points(entry.points),
         isFavorite(entry) ? "sua atlética" : nil].compactMap { $0 }.joined(separator: ", ")
    }
}

#Preview(traits: .appAppearance) {
    NavigationStack {
        Podium(entries: Array(MockData.rankings[0].entries.prefix(3)), favoriteID: "ath-bufalos")
            .padding()
    }
}

#Preview("Texto de acessibilidade", traits: .appAppearance) {
    NavigationStack {
        Podium(entries: Array(MockData.rankings[0].entries.prefix(3)), favoriteID: "ath-bufalos")
            .padding()
            .dynamicTypeSize(.accessibility3)
    }
}
