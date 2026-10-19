import SwiftUI

/// Linha de classificação: posição, escudo, nome, pontos e seta.
/// A atlética de coração ganha barra preta, coração e o texto "Sua atlética".
struct RankingRow: View {
    let position: Int?
    let athletic: Athletic
    let detail: String
    var isTied = false
    var isFavorite = false
    /// Falso quando nenhuma linha da lista tem posição (ex.: mata-mata em andamento).
    var showsPosition = true

    var body: some View {
        HStack(spacing: Spacing.s) {
            if showsPosition {
                Text(position.map { "\($0)º" } ?? "—")
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(.textPrimary)
                    .frame(minWidth: 36, alignment: .leading)
            }
            AthleticBadge(size: .medium, fill: .surface)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xxs) {
                    Text(athletic.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.leading)
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.textPrimary)
                    }
                }
                Text([detail, isTied ? "empate" : nil, isFavorite ? "Sua atlética" : nil]
                        .compactMap { $0 }.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
        }
        .padding(.vertical, Spacing.s)
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isFavorite ? Color.textPrimary : Color.surface)
                .frame(width: 4)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Abre a atlética")
    }

    private var accessibilityText: String {
        let place = position.map { isTied ? "\($0)º lugar, empatada" : "\($0)º lugar" } ?? "sem classificação"
        return [place, athletic.name, detail, isFavorite ? "sua atlética" : nil].compactMap { $0 }.joined(separator: ", ")
    }
}

#Preview {
    VStack(spacing: 1) {
        RankingRow(position: 4, athletic: MockData.athletic("ath-lobos"), detail: "980 pts", isTied: true)
        RankingRow(position: 2, athletic: MockData.athletic("ath-bufalos"), detail: "1.345 pts", isFavorite: true)
        RankingRow(position: nil, athletic: MockData.athletic("ath-cca"), detail: "Série Bronze")
    }
    .background(.canvas)
}
