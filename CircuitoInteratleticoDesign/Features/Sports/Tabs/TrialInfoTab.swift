import SwiftUI

/// Aba de informações da prova classificatória (data, local, critério, unidade, disputa).
struct TrialInfoTab: View {
    let competition: Competition
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let pair = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.m))
            : AnyLayout(HStackLayout(alignment: .top, spacing: Spacing.m))
        if let trial = competition.trial, case .ranking(let criterion, let unit, let isTeam) = competition.format {
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Informações")
                VStack(alignment: .leading, spacing: Spacing.m) {
                    pair {
                        item("Data", Formatters.fullDay(trial.startDate), symbol: "calendar")
                        item("Horário", Formatters.time(trial.startDate), symbol: "clock")
                    }
                    pair {
                        item("Situação", symbol: "info.circle", trial.isClosed ? "Encerrada" : trial.hasPartialResults ? "Resultados parciais" : "A iniciar")
                        item("Disputa", isTeam ? "Por equipe" : "Individual", symbol: isTeam ? "person.3" : "person")
                    }
                    pair {
                        item("Critério", criterion.label, symbol: "list.number")
                        item("Unidade", unit.label, symbol: "ruler")
                    }
                    item("Local", trial.venue, symbol: "mappin.and.ellipse")
                }
                .padding(Spacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardSurface()
            }
        } else {
            InlineNote(systemImage: "calendar", text: "A prova desta modalidade ainda não foi agendada.")
        }
    }

    private func item(_ label: String, symbol: String, _ value: String) -> some View {
        item(label, value, symbol: symbol)
    }

    private func item(_ label: String, _ value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            // Mesmo padrão das Informações da partida: ícone e rótulo secundários, valor em destaque.
            Label(label, systemImage: symbol)
                .labelStyle(InfoLabelStyle())
                .font(.footnote)
                .foregroundStyle(.textSecondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
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
