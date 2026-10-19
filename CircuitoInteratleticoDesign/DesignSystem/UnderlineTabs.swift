import SwiftUI

/// Abas de texto com sublinhado ("Minha atlética | Geral", períodos da partida).
/// A selecionada usa peso, cor e sublinhado; cada aba tem no mínimo 44 pt de altura.
struct UnderlineTabs<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    /// Ícone acima do texto (abas da atlética e da modalidade).
    var systemImage: ((Item) -> String)? = nil
    let title: (Item) -> String

    @Namespace private var underline

    /// Quando as abas não cabem (nomes longos, fonte grande), passam a rolar na horizontal.
    var body: some View {
        ViewThatFits(in: .horizontal) {
            tabs
            ScrollView(.horizontal) { tabs.padding(.horizontal, Spacing.xs) }
                .scrollIndicators(.hidden)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                let isSelected = item == selection
                Button {
                    withAnimation(.snappy) { selection = item }
                } label: {
                    VStack(spacing: 6) {
                        if let systemImage {
                            Image(systemName: systemImage(item))
                                .font(.title3)
                                .symbolVariant(isSelected ? .fill : .none)
                                .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                                .accessibilityHidden(true)
                        }
                        Text(title(item))
                            .font((systemImage == nil ? Font.subheadline : .caption).weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        ZStack {
                            Capsule().fill(.clear).frame(height: 3)
                            if isSelected {
                                Capsule()
                                    .fill(.textPrimary)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "underline", in: underline)
                            }
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, Spacing.xs)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
    }
}

#Preview {
    @Previewable @State var selection = "Minha atlética"
    UnderlineTabs(items: ["Minha atlética", "Geral"], selection: $selection) { $0 }
        .padding()
}
