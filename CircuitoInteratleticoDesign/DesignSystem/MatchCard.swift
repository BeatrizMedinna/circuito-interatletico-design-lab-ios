import SwiftUI

/// Escudo + nome da atlética de um lado da partida. Sem atlética, mostra "A definir".
/// `isDimmed` deixa o nome em cinza (quem perdeu a partida encerrada).
struct TeamColumn: View {
    let athletic: Athletic?
    var badgeSize: AthleticBadge.Size = .medium
    var isDimmed = false

    var body: some View {
        let name = athletic?.name ?? "A definir"
        VStack(spacing: Spacing.xs) {
            AthleticBadge(size: badgeSize, isUndefined: athletic == nil)
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(athletic == nil || isDimmed ? Color.textSecondary : Color.textPrimary)
                .multilineTextAlignment(.center)
                // Nome de uma palavra só encolhe em vez de quebrar com hífen.
                .lineLimit(name.contains(" ") ? 2 : 1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Situação da partida em texto: "● AO VIVO", "A INICIAR", "ENCERRADO".
struct MatchStatusTag: View {
    let status: MatchStatus

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if status == .live {
                Circle().frame(width: 6, height: 6)
            }
            Text(status.title.uppercased())
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(status == .live ? Color.textPrimary : Color.textSecondary)
    }
}

extension View {
    /// Barras laterais dos cartões (lado A cinza, lado B preto), herdadas do wireframe.
    /// Na alta fidelidade podem receber as cores das atléticas.
    func teamSideBars() -> some View {
        overlay(alignment: .leading) {
            UnevenRoundedRectangle(bottomTrailingRadius: 2, topTrailingRadius: 2)
                .fill(Color(white: 0.55))
                .frame(width: 4, height: 48)
        }
        .overlay(alignment: .trailing) {
            UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 2)
                .fill(Color.textPrimary)
                .frame(width: 4, height: 48)
        }
    }
}

/// Cartão compacto de partida (carrosséis e listas).
/// Ao vivo ganha borda forte, além do selo, para não depender só de texto.
struct MatchCard: View {
    let match: Match
    var showsStatus = false
    /// Falso em listas já agrupadas por dia: o cabeçalho mostra só o horário.
    var showsDay = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(Formatters.cardHeader(match, includingDay: showsDay))
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
        .accessibilityLabel(match.accessibilitySummary)
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
