import SwiftUI

/// Cabeçalho da tela de Ranking: título, busca de atlética e abas de divisões.
struct RankingHeader: View {
    let hasAnyRanking: Bool
    @Binding var query: String
    @Binding var divisionID: Division.ID

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Ranking")
                .font(.title.bold())
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)

            if hasAnyRanking {
                SearchField(prompt: "Buscar atlética", text: $query)
                if query.isEmpty {
                    UnderlineTabs(items: MockData.divisions.map(\.id), selection: $divisionID) { id in
                        MockData.divisions.first { $0.id == id }?.name ?? ""
                    }
                    // Trilho das abas de ponta a ponta, como na Início e no Cronograma.
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(.separatorLine).frame(height: 1)
                            .padding(.horizontal, -Spacing.l)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.xs)
        .padding(.bottom, hasAnyRanking && query.isEmpty ? 0 : Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }
}

#Preview {
    RankingHeader(
        hasAnyRanking: true,
        query: .constant(""),
        divisionID: .constant(MockData.divisions[0].id)
    )
}
