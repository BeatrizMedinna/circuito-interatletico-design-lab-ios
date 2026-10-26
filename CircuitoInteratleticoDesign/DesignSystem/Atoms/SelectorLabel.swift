import SwiftUI

/// Linha "Selecionar >" do wireframe; mostra o valor escolhido quando há.
struct SelectorLabel: View {
    let value: String?
    let placeholder: String

    var body: some View {
        HStack {
            Text(value ?? placeholder)
                .font(.body.weight(value == nil ? .regular : .semibold))
                .foregroundStyle(value == nil ? Color.textSecondary : Color.textPrimary)
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, Spacing.m)
        .frame(minHeight: 48)
        .background(.surfaceInset, in: RoundedRectangle(cornerRadius: Radius.control))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.control)
                .strokeBorder(.actionPrimary, lineWidth: value == nil ? 0 : 1.5)
        }
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.m) {
        SelectorLabel(value: nil, placeholder: "Todas as modalidades")
        SelectorLabel(value: "Basquete", placeholder: "Todas as modalidades")
    }
    .padding()
}
