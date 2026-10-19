import SwiftUI

/// Confirmação curta de uma ação ("Agora você torce por…"). Some sozinha;
/// o VoiceOver lê a mesma mensagem (ver `AppState.showToast`).
struct Toast: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .accessibilityHidden(true)
            Text(message)
                .multilineTextAlignment(.leading)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.textOnAccent)
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(.actionPrimary, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .padding(.horizontal, Spacing.l)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    Toast(message: "Agora você torce por Búfalos")
}
