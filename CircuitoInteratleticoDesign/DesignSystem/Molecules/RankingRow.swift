import SwiftUI

/// Linha de classificação: posição, escudo, nome, pontos e seta.
/// A atlética de coração (por parâmetro ou pelo ambiente) ganha faixa, anel,
/// coração e "Sua atlética" em Teal.
struct RankingRow: View {
    let position: Int?
    let athletic: Athletic
    let detail: String
    var isTied = false
    var isFavorite = false
    /// Falso quando nenhuma linha da lista tem posição (ex.: mata-mata em andamento).
    var showsPosition = true
    /// Em tamanhos de acessibilidade, posição e escudo ficam numa linha e o nome
    /// usa a largura toda abaixo (HIG: empilhar em vez de cortar). Opcional:
    /// hoje só o Ranking liga; Modalidades mantém a linha única.
    var stacksAtAccessibilitySizes = false
    @Environment(\.favoriteAthleticID) private var favoriteAthleticID
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var showsFavorite: Bool { isFavorite || athletic.id == favoriteAthleticID }

    private var favoriteSuffix: Text {
        Text(showsFavorite ? " · Sua atlética" : "").foregroundStyle(Color.favoriteAccent)
    }

    var body: some View {
        Group {
            if stacksAtAccessibilitySizes && dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.s) {
                        positionText
                        AthleticBadge(size: .medium, isFavorite: showsFavorite)
                        Spacer(minLength: Spacing.xs)
                        chevron
                    }
                    texts
                }
            } else {
                HStack(spacing: Spacing.s) {
                    positionText
                    AthleticBadge(size: .medium, isFavorite: showsFavorite)
                    texts
                    Spacer(minLength: Spacing.xs)
                    chevron
                }
            }
        }
        .padding(.vertical, Spacing.s)
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface)
        .overlay(alignment: .leading) {
            if showsFavorite {
                Rectangle().fill(.favoriteAccent).frame(width: 3)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Abre a atlética")
    }

    @ViewBuilder
    private var positionText: some View {
        if showsPosition {
            Text(position.map { "\($0)º" } ?? "—")
                .font(.sportNumber())
                .monospacedDigit()
                .foregroundStyle(position == nil ? Color.textTertiary : Color.textPrimary)
                .frame(minWidth: 36, alignment: .leading)
        }
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Spacing.xxs) {
                Text(athletic.name)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if showsFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.favoriteAccent)
                }
            }
            Text("\([detail, isTied ? "empate" : nil].compactMap { $0 }.joined(separator: " · "))\(favoriteSuffix)")
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.textTertiary)
    }

    private var accessibilityText: String {
        let place = position.map { isTied ? "\($0)º lugar, empatada" : "\($0)º lugar" } ?? "sem classificação"
        return [place, athletic.name, detail, showsFavorite ? "sua atlética" : nil].compactMap { $0 }.joined(separator: ", ")
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: 1) {
        RankingRow(position: 4, athletic: MockData.athletic("ath-lobos"), detail: "980 pts", isTied: true)
        RankingRow(position: 2, athletic: MockData.athletic("ath-bufalos"), detail: "1.345 pts", isFavorite: true)
        RankingRow(position: nil, athletic: MockData.athletic("ath-cca"), detail: "Série Bronze")
    }
    .background(.canvas)
}
