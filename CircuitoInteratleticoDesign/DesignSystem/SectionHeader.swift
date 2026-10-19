import SwiftUI

/// Título de seção com ação opcional à direita (ex.: "Ver mais").
struct SectionHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.xs)
            trailing
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

/// Ícone em círculo cinza (sino, filtro). Use como label de botão ou link.
struct CircleIconLabel: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.body.weight(.semibold))
            .foregroundStyle(.textPrimary)
            .frame(width: 44, height: 44)
            .background(.surface, in: Circle())
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        SectionHeader(title: "Próximos jogos") {
            Button("Ver mais") {}
        }
        SectionHeader(title: "Informações")
        CircleIconLabel(systemName: "bell")
    }
    .padding()
}
