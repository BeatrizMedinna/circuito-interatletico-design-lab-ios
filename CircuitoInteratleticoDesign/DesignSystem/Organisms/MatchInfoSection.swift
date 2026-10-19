import SwiftUI

/// Seção com informações gerais da partida (Data, Horário, Etapa, Divisão, Local).
struct MatchInfoSection: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Informações")
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack(alignment: .top, spacing: Spacing.m) {
                    item("Data", Formatters.fullDay(match.startDate))
                    item("Horário", Formatters.time(match.startDate))
                }
                HStack(alignment: .top, spacing: Spacing.m) {
                    item("Etapa", match.phase)
                    item("Divisão", match.division.name)
                }
                item("Local", match.venue)
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
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
    MatchInfoSection(match: MockData.matches[0])
        .padding()
        .background(Color.canvas)
}
