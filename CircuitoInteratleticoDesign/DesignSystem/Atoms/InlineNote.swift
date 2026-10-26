import SwiftUI

/// Aviso curto dentro de uma seção (ex.: "Nenhum jogo ao vivo agora").
/// Para a tela inteira vazia ou com erro, use `ContentUnavailableView`.
/// `tone` muda o ícone e a faixa à esquerda para atenção ou erro (o texto continua legível).
struct InlineNote: View {
    enum Tone {
        case neutral, warning, critical
    }

    let systemImage: String
    let text: String
    var tone: Tone = .neutral

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
            Image(systemName: systemImage)
                .foregroundStyle(accent ?? Color.textSecondary)
                .accessibilityHidden(true)
            Text(text)
                .foregroundStyle(tone == .neutral ? Color.textSecondary : Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.subheadline)
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            if let accent {
                Rectangle().fill(accent).frame(width: 3)
            }
        }
        .cardSurface()
    }

    private var accent: Color? {
        switch tone {
        case .neutral: nil
        case .warning: .warning
        case .critical: .critical
        }
    }
}

#Preview(traits: .appAppearance) {
    InlineNote(systemImage: "dot.radiowaves.left.and.right", text: "Nenhum jogo ao vivo agora.")
        .padding()
}
