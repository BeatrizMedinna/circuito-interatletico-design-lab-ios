import SwiftUI

/// Título de seção com ação opcional à direita (ex.: "Ver mais"), que recebe
/// o estilo de link de seção: Lime com chevron.
struct SectionHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.sectionTitle)
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.xs)
            trailing
                .buttonStyle(.sectionLink)
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(title: String) {
        self.init(title: title) { EmptyView() }
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.l) {
        SectionHeader(title: "Próximos jogos") {
            Button("Ver mais") {}
        }
        SectionHeader(title: "Informações")
    }
    .padding()
}
