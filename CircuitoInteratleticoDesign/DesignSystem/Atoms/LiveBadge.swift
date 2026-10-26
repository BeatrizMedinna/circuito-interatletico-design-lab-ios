import SwiftUI

/// Selo "● Ao vivo": ponto vermelho pulsante + rótulo (a cor nunca vem sozinha).
/// O pulso some com "Reduzir movimento".
struct LiveBadge: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundStyle(.live)
                .symbolEffect(.pulse)
            Text("Ao vivo")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.textPrimary)
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, 6)
        .background(.appBackground, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    LiveBadge()
        .padding()
        .background(Color.canvas)
}
