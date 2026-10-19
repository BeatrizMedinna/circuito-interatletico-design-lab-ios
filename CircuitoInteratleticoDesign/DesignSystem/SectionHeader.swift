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

/// Ícone em círculo (sino, filtro). Use como label de botão ou link.
/// `isActive` inverte as cores (ex.: filtros aplicados).
struct CircleIconLabel: View {
    let systemName: String
    var isActive = false

    var body: some View {
        Image(systemName: systemName)
            .font(.body.weight(.semibold))
            .foregroundStyle(isActive ? Color.textOnAccent : Color.textPrimary)
            .frame(width: 44, height: 44)
            .background(isActive ? Color.actionPrimary : Color.surface, in: Circle())
    }
}

/// Contador sobre um ícone (avisos não lidos, filtros ativos). Some quando é zero.
struct CountBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text(count > 9 ? "9+" : "\(count)")
                .font(.caption2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.textOnAccent)
                .padding(.horizontal, 5)
                .frame(minWidth: 20, minHeight: 20)
                .background(.actionPrimary, in: Capsule())
                .overlay { Capsule().strokeBorder(.appBackground, lineWidth: 2) }
                .offset(x: 4, y: -4)
                .accessibilityHidden(true)
        }
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
