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
    /// (nomes inteiros, sem truncar). Opcional: hoje os carrosséis da Início e o Cronograma usam.
    var stacksAtAccessibilitySizes = false
    /// Empilha também quando um dos nomes é longo demais para a coluna
    /// (ver `TeamRow.isLongName`). Opcional: hoje só o Cronograma usa.
    var stacksLongNames = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var headerText: some View {
        Text(caption ?? Formatters.cardHeader(match, date: date))
            .font(.caption.weight(.semibold))
            .tracking(0.3)
            .foregroundStyle(.textSecondary)
    }

    @ViewBuilder
    private var statusTag: some View {
        if showsStatus || match.status == .live {
            MatchStatusTag(status: match.status)
                .fixedSize()
        }
    }

    private var isStacked: Bool {
        // O cartão do carrossel é estreito: já no maior tamanho padrão (xxxLarge) os nomes truncavam.
        (stacksAtAccessibilitySizes && dynamicTypeSize >= .xxxLarge)
            || (stacksLongNames && (TeamRow.isLongName(match.teamA) || TeamRow.isLongName(match.teamB)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            // Em tamanhos de acessibilidade o selo de situação sobe e o cabeçalho
            // ("BASQUETE MASCULINO · …") usa a largura toda, sem reticências.
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    statusTag
                    headerText.fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    headerText.lineLimit(2)
                    Spacer(minLength: 0)
                    statusTag
                }
            }
            if isStacked {
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
