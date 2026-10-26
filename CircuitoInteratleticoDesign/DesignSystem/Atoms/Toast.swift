import SwiftUI

/// Confirmação curta de uma ação ("Agora você torce por…"). Some sozinha;
/// o VoiceOver lê a mesma mensagem (ver `AppState.showToast`).
struct Toast: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.success)
                .accessibilityHidden(true)
            Text(message)
                .multilineTextAlignment(.leading)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.textPrimary)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(.surfaceSelected, in: Capsule())
        .overlay { Capsule().strokeBorder(Color.white.opacity(0.06), lineWidth: 1) }
        .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
        .padding(.horizontal, Spacing.l)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview(traits: .appAppearance) {
    Toast(message: "Agora você torce por Búfalos")
}
