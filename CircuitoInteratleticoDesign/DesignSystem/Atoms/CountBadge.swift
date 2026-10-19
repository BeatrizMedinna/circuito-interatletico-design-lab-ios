import SwiftUI

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
    HStack(spacing: Spacing.xl) {
        CircleIconLabel(systemName: "bell")
            .overlay(alignment: .topTrailing) { CountBadge(count: 3) }
        CircleIconLabel(systemName: "bell")
            .overlay(alignment: .topTrailing) { CountBadge(count: 12) }
    }
    .padding()
}
