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
        .font(.caption2.weight(.semibold))
        .foregroundStyle(status == .live ? Color.textPrimary : Color.textSecondary)
    }
}

#Preview {
    HStack(spacing: Spacing.m) {
        MatchStatusTag(status: .live)
        MatchStatusTag(status: .scheduled)
        MatchStatusTag(status: .finished)
    }
    .padding()
}
