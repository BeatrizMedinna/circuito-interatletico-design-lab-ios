import SwiftUI

/// Placar em caixas "2 : 3". A iniciar mostra "– : –"; W.O. mostra uma caixa só.
/// No encerrado, o placar de quem perdeu fica em cinza para destacar o vencedor
/// sem depender de cor.
struct ScoreBoxes: View {
    enum Size {
        case compact, large
    }

    let match: Match
    var size: Size = .compact

    var body: some View {
        Group {
            if match.walkoverWinner != nil {
                box("W.O.", isDimmed: false)
            } else {
                HStack(spacing: size == .compact ? 6 : Spacing.xs) {
                    box(value(match.scoreA), isDimmed: isDimmed(.a))
                    Text(":")
                        .font(font)
                        .foregroundStyle(.textSecondary)
                    box(value(match.scoreB), isDimmed: isDimmed(.b))
                }
            }
        }
        .fixedSize()
        // O placar já é grande; acima disso ele empurraria os nomes para fora do cartão.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityHidden(true)
    }

    private var font: Font {
        size == .compact ? .title2.weight(.semibold) : .largeTitle.weight(.semibold)
    }

    private func value(_ score: Int?) -> String {
        match.status == .scheduled ? "–" : String(score ?? 0)
    }

    private func isDimmed(_ side: MatchSide) -> Bool {
        if match.status == .scheduled { return true }
        guard let winner = match.winner else { return false }
        return winner != side
    }

    private func box(_ text: String, isDimmed: Bool) -> some View {
        Text(text)
            .font(font)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(isDimmed ? Color.textSecondary : Color.textPrimary)
            .padding(.horizontal, 6)
            .frame(minWidth: size == .compact ? 40 : 56, minHeight: size == .compact ? 44 : 64)
            .background(.surfaceSelected, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        ForEach(MockData.matches.prefix(12)) { match in
            ScoreBoxes(match: match)
        }
    }
    .padding()
}
