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
                .textCase(.uppercase)
                .font(.caption.weight(.bold))
                .tracking(0.6)
        }
        .foregroundStyle(.textPrimary)
        .padding(.horizontal, Spacing.s)
        .padding(.vertical, 6)
        .background(Color.live.opacity(0.16), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .appAppearance) {
    LiveBadge()
        .padding()
        .background(Color.canvas)
}
