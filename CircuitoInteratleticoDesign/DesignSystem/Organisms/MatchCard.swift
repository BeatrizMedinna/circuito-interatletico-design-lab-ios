import SwiftUI

/// Cartão compacto de partida (carrosséis e listas).
/// Ao vivo ganha contorno cinza mais forte (não vermelho), além do selo.
struct MatchCard: View {
    let match: Match
    var showsStatus = false
    /// Listas agrupadas por dia usam `.time`; a linha do tempo, `.none`.
    var date: Formatters.CardDate = .dayAndTime
    /// Substitui o cabeçalho (ex.: "SEMIFINAL · 15:30" dentro da modalidade).
    var caption: String? = nil
    /// Local da partida no rodapé (cronograma, onde jogos simultâneos se distinguem pelo local).
    var showsVenue = false
    /// Em textos muito grandes (a partir de xxxLarge), empilha time A, placar e time B em linhas
    /// (nomes inteiros, sem truncar). Opcional: hoje só os carrosséis da Início usam.
    var stacksAtAccessibilitySizes = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(caption ?? Formatters.cardHeader(match, date: date))
                    .font(.caption.weight(.semibold))
                    .tracking(0.3)
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                if showsStatus || match.status == .live {
                    MatchStatusTag(status: match.status)
                        .fixedSize()
                }
            }
            // O cartão do carrossel é estreito: já no maior tamanho padrão (xxxLarge) os nomes truncavam.
            if stacksAtAccessibilitySizes && dynamicTypeSize >= .xxxLarge {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    TeamRow(athletic: match.teamA, isDimmed: match.isLoser(.a))
                    ScoreBoxes(match: match)
                    TeamRow(athletic: match.teamB, isDimmed: match.isLoser(.b))
                }
            } else {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    TeamColumn(athletic: match.teamA, isDimmed: match.isLoser(.a))
                    ScoreBoxes(match: match)
                    TeamColumn(athletic: match.teamB, isDimmed: match.isLoser(.b))
                }
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
        .cardSurface(highlighted: match.status == .live)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showsVenue ? "\(match.accessibilitySummary), \(match.venue)" : match.accessibilitySummary)
    }
}

#Preview(traits: .appAppearance) {
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
