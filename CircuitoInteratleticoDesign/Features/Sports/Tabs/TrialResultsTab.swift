import SwiftUI

/// Linha de resultado da prova: posição (ou "—"), atleta e atlética, marca ou situação.
struct ResultRow: View {
    let ranked: RankedResult
    let unit: MarkUnit
    let isTeam: Bool
    let isFavorite: Bool

    var body: some View {
        let result = ranked.result
        HStack(spacing: Spacing.s) {
            Text(ranked.position.map { ranked.isTied ? "\($0)º=" : "\($0)º" } ?? "—")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
                .frame(minWidth: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xxs) {
                    Text(isTeam ? result.athletic.name : (result.athleteName ?? result.athletic.name))
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    if isFavorite {
                        Image(systemName: "heart.fill").font(.caption).foregroundStyle(.textPrimary)
                    }
                }
                if !isTeam {
                    Text(result.athletic.name)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer(minLength: Spacing.xs)
            Text(result.situation == .valid ? result.mark.map(unit.format) ?? "—" : result.situation.label)
                .font(result.situation == .valid ? .headline.monospacedDigit() : .subheadline.italic())
                .foregroundStyle(result.situation == .valid ? Color.textPrimary : Color.textSecondary)
        }
        .padding(.vertical, Spacing.s)
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .overlay(alignment: .leading) {
            Rectangle().fill(isFavorite ? Color.textPrimary : .clear).frame(width: 4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Abre a atlética")
    }

    private var accessibilityText: String {
        let result = ranked.result
        let place = ranked.position.map { ranked.isTied ? "\($0)º lugar, empatado" : "\($0)º lugar" } ?? result.situation.label
        let mark = result.situation == .valid ? result.mark.map(unit.format) : nil
        return [place, result.athleteName, result.athletic.name, mark, isFavorite ? "sua atlética" : nil]
            .compactMap { $0 }.joined(separator: ", ")
    }
}

/// Tela 16 na classificatória: marcas em ordem, empates dividindo a posição,
/// situações sem posição no fim e inscritas que ainda aguardam resultado.
struct TrialResultsTab: View {
    @Environment(AppState.self) private var appState
    let competition: Competition

    var body: some View {
        if let trial = competition.trial, case .ranking(let criterion, let unit, let isTeam) = competition.format {
            VStack(alignment: .leading, spacing: Spacing.l) {
                if trial.results.isEmpty {
                    InlineNote(systemImage: "clock",
                               text: "Os resultados aparecem aqui quando a prova começar, \(Formatters.dayLabel(trial.startDate).lowercased()) às \(Formatters.time(trial.startDate)).")
                } else {
                    InlineNote(systemImage: trial.isClosed ? "checkmark.seal" : "exclamationmark.circle",
                               text: trial.isClosed
                                ? "Prova encerrada. \(criterion.label); marcas iguais dividem a posição."
                                : "Resultados parciais: podem mudar até o encerramento da prova.")
                    VStack(spacing: 1) {
                        ForEach(trial.ranked(by: criterion)) { ranked in
                            NavigationLink(value: AppRoute.athletic(ranked.result.athletic.id)) {
                                ResultRow(ranked: ranked, unit: unit, isTeam: isTeam,
                                          isFavorite: ranked.result.athletic.id == appState.favoriteAthletic?.id)
                            }
                            .buttonStyle(.pressableCard)
                        }
                    }
                    .background(Color.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                }

                let pending = trial.isClosed ? [] : trial.pendingParticipants
                if !pending.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        SectionHeader(title: trial.results.isEmpty ? "Atléticas inscritas" : "Aguardando resultado")
                        VStack(spacing: 1) {
                            ForEach(pending) { athletic in
                                NavigationLink(value: AppRoute.athletic(athletic.id)) {
                                    RankingRow(position: nil, athletic: athletic, detail: athletic.institution,
                                               isFavorite: athletic.id == appState.favoriteAthletic?.id,
                                               showsPosition: false)
                                }
                                .buttonStyle(.pressableCard)
                            }
                        }
                        .background(Color.canvas)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                    }
                }
            }
        } else {
            InlineNote(systemImage: "list.number", text: "Ainda não há prova para esta modalidade.")
        }
    }
}

#Preview {
    if let comp = MockData.competitions.first(where: { $0.trial != nil }) {
        NavigationStack {
            TrialResultsTab(competition: comp)
                .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
                .padding()
                .background(Color.canvas)
        }
    }
}
