import SwiftUI

/// Abas de texto com sublinhado ("Minha atlética | Geral", períodos da partida).
/// A selecionada usa peso, cor e sublinhado; cada aba tem no mínimo 44 pt de altura.
struct UnderlineTabs<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let title: (Item) -> String

    @Namespace private var underline

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                let isSelected = item == selection
                Button {
                    withAnimation(.snappy) { selection = item }
                } label: {
                    VStack(spacing: 6) {
                        Text(title(item))
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
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
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    @Previewable @State var selection = "Minha atlética"
    UnderlineTabs(items: ["Minha atlética", "Geral"], selection: $selection) { $0 }
        .padding()
}
