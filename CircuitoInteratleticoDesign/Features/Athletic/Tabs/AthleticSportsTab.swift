import SwiftUI

/// Situação da atlética em cada modalidade que disputa: até onde chegou no
/// mata-mata ou posição e marca na prova. Cada linha abre a modalidade.
struct AthleticSportsTab: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        let standings = MockData.standings(for: athletic.id, matches: appState.matches)
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Modalidades")
            if standings.isEmpty {
                InlineNote(systemImage: "trophy", text: "\(athletic.name) ainda não disputa modalidades nesta edição.")
            } else {
                VStack(spacing: 1) {
                    ForEach(standings) { standing in
                        NavigationLink(value: AppRoute.competition(standing.competition.id)) {
                            row(standing)
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

    private func row(_ standing: SportStanding) -> some View {
        let competition = standing.competition
        let isHighlight = standing.status == "Campeã" || standing.status.hasPrefix("1º")
        return HStack(spacing: Spacing.s) {
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
                Text(standing.status)
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
