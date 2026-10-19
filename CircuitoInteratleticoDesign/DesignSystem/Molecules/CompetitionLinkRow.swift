import SwiftUI

/// Atalho da partida para a modalidade (chave e classificação).
struct CompetitionLinkRow: View {
    let competition: Competition

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.body.weight(.medium))
                .frame(width: 44, height: 44)
                .background(.appBackground, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ver chave e classificação")
                    .font(.headline)
                Text("\(competition.title) · \(competition.division.name)")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
                .accessibilityHidden(true)
        }
        .foregroundStyle(.textPrimary)
        .padding(Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let competition = MockData.competitions[0]
    CompetitionLinkRow(competition: competition)
        .padding()
        .background(Color.canvas)
}
