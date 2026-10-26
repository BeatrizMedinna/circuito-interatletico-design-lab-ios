import SwiftUI

/// Escudo + nome da atlética de um lado da partida. Sem atlética, mostra "A definir".
/// `isDimmed` deixa o nome em cinza (quem perdeu a partida encerrada).
struct TeamColumn: View {
    let athletic: Athletic?
    var badgeSize: AthleticBadge.Size = .medium
    var isDimmed = false
    @Environment(\.favoriteAthleticID) private var favoriteAthleticID

    var body: some View {
        let name = athletic?.name ?? "A definir"
        VStack(spacing: Spacing.xs) {
            AthleticBadge(size: badgeSize, isUndefined: athletic == nil,
                          isFavorite: athletic != nil && athletic?.id == favoriteAthleticID)
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(athletic == nil || isDimmed ? Color.textTertiary : Color.textPrimary)
                .multilineTextAlignment(.center)
                // Nome de uma palavra só encolhe em vez de quebrar com hífen.
                .lineLimit(name.contains(" ") ? 2 : 1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .appAppearance) {
    HStack(spacing: Spacing.m) {
        TeamColumn(athletic: MockData.athletic("ath-bufalos"))
        TeamColumn(athletic: nil)
        TeamColumn(athletic: MockData.athletic("ath-engenharia"), isDimmed: true)
    }
    .padding()
}
