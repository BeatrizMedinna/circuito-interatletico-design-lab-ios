import SwiftUI

/// Cartão compacto de partida (carrosséis e listas).
/// Ao vivo ganha borda forte, além do selo, para não depender só de texto.
struct MatchCard: View {
    let match: Match
    var showsStatus = false
    /// Listas agrupadas por dia usam `.time`; a linha do tempo, `.none`.
    var date: Formatters.CardDate = .dayAndTime
    /// Substitui o cabeçalho (ex.: "SEMIFINAL · 15:30" dentro da modalidade).
    var caption: String? = nil
    /// Local da partida no rodapé (cronograma, onde jogos simultâneos se distinguem pelo local).
    var showsVenue = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(caption ?? Formatters.cardHeader(match, date: date))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                if showsStatus || match.status == .live {
                    MatchStatusTag(status: match.status)
                        .fixedSize()
                }
            }
            HStack(alignment: .top, spacing: Spacing.xs) {
                TeamColumn(athletic: match.teamA, isDimmed: match.isLoser(.a))
                ScoreBoxes(match: match)
                TeamColumn(athletic: match.teamB, isDimmed: match.isLoser(.b))
            }
            if showsVenue {
                Label(match.venue, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, Spacing.s)
        .padding(.horizontal, Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.card)
                .strokeBorder(.borderStrong, lineWidth: match.status == .live ? 1.5 : 0)
        }
        .teamSideBars()
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showsVenue ? "\(match.accessibilitySummary), \(match.venue)" : match.accessibilitySummary)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.s) {
            ForEach(MockData.matches) { match in
                MatchCard(match: match, showsStatus: true)
            }
        }
        .padding()
    }
    .background(.canvas)
}
