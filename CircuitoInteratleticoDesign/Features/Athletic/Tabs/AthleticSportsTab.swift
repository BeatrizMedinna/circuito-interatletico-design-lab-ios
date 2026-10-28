import SwiftUI

/// Situação da atlética em cada modalidade que disputa: até onde chegou no
/// mata-mata ou posição e marca na prova. Cada linha abre a modalidade.
struct AthleticSportsTab: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        let standings = MockData.standings(for: athletic.id, matches: appState.matches)
        // Coluna de posição só quando alguma modalidade já define a colocação.
        let showsPosition = standings.contains { position(in: $0.competition) != nil }
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Modalidades")
            if standings.isEmpty {
                InlineNote(systemImage: "trophy", text: "\(athletic.name) ainda não disputa modalidades nesta edição.")
            } else {
                VStack(spacing: 1) {
                    ForEach(standings) { standing in
                        NavigationLink(value: AppRoute.competition(standing.competition.id)) {
                            row(standing, showsPosition: showsPosition)
                        }
                        .buttonStyle(.pressableCard)
                    }
                }
                .background(Color.separatorLine)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                .overlay {
                    RoundedRectangle(cornerRadius: Radius.card).strokeBorder(Color.separatorLine, lineWidth: 1)
                }
            }
        }
    }

    /// Posição já definida pelos resultados: 1º/2º quando a chave termina; na prova,
    /// a colocação da melhor marca válida. Sem posição definida, nada é inventado.
    private func position(in competition: Competition) -> Int? {
        switch competition.format {
        case .elimination:
            return competition.campaign(matches: appState.matches).first { $0.athletic.id == athletic.id }?.position
        case .ranking(let criterion, _, _):
            return competition.trial?.ranked(by: criterion)
                .first { $0.result.athletic.id == athletic.id && $0.position != nil }?.position
        }
    }

    private func row(_ standing: SportStanding, showsPosition: Bool) -> some View {
        let competition = standing.competition
        let place = position(in: competition)
        let isHighlight = standing.status == "Campeã" || place == 1
        // Na prova, a posição sai do texto ("1º lugar · 5,12 m" → "5,12 m"): o número fica na coluna.
        let prefix = place.map { "\($0)º lugar · " } ?? ""
        let status = !prefix.isEmpty && standing.status.hasPrefix(prefix)
            ? String(standing.status.dropFirst(prefix.count)) : standing.status
        return HStack(spacing: Spacing.s) {
            if showsPosition {
                Text(place.map { "\($0)º" } ?? "—")
                    .font(.sportNumber())
                    .monospacedDigit()
                    .foregroundStyle(place == nil ? Color.textTertiary : Color.textPrimary)
                    .frame(minWidth: 36, alignment: .leading)
            }
            // Título ou 1º lugar: troféu em Lime, como o líder do pódio (o texto também diz).
            Image(systemName: isHighlight ? "trophy.fill" : competition.sport.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(isHighlight ? Color.brandPrimary : Color.textPrimary)
                .frame(width: 44, height: 44)
                .background(.surfaceInset, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(competition.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(status)
                    .font(.subheadline.weight(isHighlight ? .semibold : .regular))
                    .foregroundStyle(isHighlight ? Color.textPrimary : Color.textSecondary)
                Text("\(competition.division.name) · \(competition.format.label)")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
            }
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Abre a modalidade")
    }
}

#Preview {
    NavigationStack {
        AthleticSportsTab(athletic: MockData.athletic("ath-bufalos"))
            .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
            .padding()
            .background(Color.canvas)
    }
}
