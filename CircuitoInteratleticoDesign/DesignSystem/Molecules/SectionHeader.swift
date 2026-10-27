import SwiftUI

/// Título de seção com ação opcional à direita (ex.: "Ver mais"), que recebe
/// o estilo de link de seção: Lime com chevron.
struct SectionHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        // Título e ação lado a lado quando cabem numa linha; senão a ação desce,
        // em vez de o título quebrar com hífen ("encer-rado") em texto grande.
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) {
                titleText
                Spacer(minLength: Spacing.xs)
                trailingAction
            }
            VStack(alignment: .leading, spacing: 0) {
                titleText.fixedSize(horizontal: false, vertical: true)
                trailingAction
            }
        }
    }

    private var titleText: some View {
        Text(title)
            .font(.sectionTitle)
            .foregroundStyle(.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    private var trailingAction: some View {
        trailing
            .buttonStyle(.sectionLink)
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
