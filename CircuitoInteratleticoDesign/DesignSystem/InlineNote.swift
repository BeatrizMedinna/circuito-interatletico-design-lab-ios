import SwiftUI

/// Aviso curto dentro de uma seção (ex.: "Nenhum jogo ao vivo agora").
/// Para a tela inteira vazia ou com erro, use `ContentUnavailableView`.
struct InlineNote: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
            Image(systemName: systemImage)
                .accessibilityHidden(true)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.subheadline)
        .foregroundStyle(.textSecondary)
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}

#Preview {
    InlineNote(systemImage: "dot.radiowaves.left.and.right", text: "Nenhum jogo ao vivo agora.")
        .padding()
}
