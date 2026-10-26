import SwiftUI

/// Situação da partida em texto: "● AO VIVO", "A INICIAR", "ENCERRADO".
struct MatchStatusTag: View {
    let status: MatchStatus

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if status == .live {
                Circle().frame(width: 6, height: 6)
            }
            Text(status.title.uppercased())
        }
        .font(.eyebrow)
        .tracking(0.6)
        .foregroundStyle(color)
    }

    /// Ao vivo > a iniciar > encerrado.
    private var color: Color {
        switch status {
        case .live: .live
        case .scheduled: .textSecondary
        case .finished: .textTertiary
        }
    }
}

#Preview(traits: .appAppearance) {
    HStack(spacing: Spacing.m) {
        MatchStatusTag(status: .live)
        MatchStatusTag(status: .scheduled)
        MatchStatusTag(status: .finished)
    }
    .padding()
}
