import SwiftUI

/// Aba de informações da prova classificatória (data, local, critério, unidade, disputa).
struct TrialInfoTab: View {
    let competition: Competition

    var body: some View {
        if let trial = competition.trial, case .ranking(let criterion, let unit, let isTeam) = competition.format {
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Informações")
                VStack(alignment: .leading, spacing: Spacing.m) {
                    HStack(alignment: .top, spacing: Spacing.m) {
                        item("Data", Formatters.fullDay(trial.startDate))
                        item("Horário", Formatters.time(trial.startDate))
                    }
                    HStack(alignment: .top, spacing: Spacing.m) {
                        item("Situação", trial.isClosed ? "Encerrada" : trial.hasPartialResults ? "Resultados parciais" : "Agendada")
                        item("Disputa", isTeam ? "Por equipe" : "Individual")
                    }
                    HStack(alignment: .top, spacing: Spacing.m) {
                        item("Critério", criterion.label)
                        item("Unidade", unit.label)
                    }
                    item("Local", trial.venue)
                }
                .padding(Spacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
            }
        } else {
            InlineNote(systemImage: "calendar", text: "A prova desta modalidade ainda não foi agendada.")
        }
    }

    private func item(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    if let comp = MockData.competitions.first(where: { $0.trial != nil }) {
        TrialInfoTab(competition: comp)
            .padding()
            .background(Color.canvas)
    }
}
