import SwiftUI

/// Contador sobre um ícone (avisos não lidos, filtros ativos). Some quando é zero.
/// Lime (o vermelho fica reservado para "ao vivo"); sobre um botão já em Lime,
/// use `onAccent` para inverter as cores e o número não sumir.
struct CountBadge: View {
    let count: Int
    var onAccent = false

    var body: some View {
        if count > 0 {
            Text(count > 9 ? "9+" : "\(count)")
                .font(.caption2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(onAccent ? Color.actionPrimary : Color.textOnAccent)
                .padding(.horizontal, 5)
                .frame(minWidth: 20, minHeight: 20)
                .background(onAccent ? Color.textOnAccent : Color.actionPrimary, in: Capsule())
                .overlay { Capsule().strokeBorder(.appBackground, lineWidth: 2) }
                .offset(x: 4, y: -4)
                .accessibilityHidden(true)
        }
    }
}

#Preview(traits: .appAppearance) {
    HStack(spacing: Spacing.xl) {
        CircleIconLabel(systemName: "bell")
            .overlay(alignment: .topTrailing) { CountBadge(count: 3) }
        CircleIconLabel(systemName: "bell")
            .overlay(alignment: .topTrailing) { CountBadge(count: 12) }
    }
    .padding()
}
