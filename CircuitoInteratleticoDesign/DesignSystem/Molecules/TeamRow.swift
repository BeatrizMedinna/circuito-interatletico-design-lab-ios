import SwiftUI

/// Escudo + nome da atlética lado a lado. Versão horizontal de `TeamColumn`,
/// usada nos cartões de partida quando o texto está em tamanho de acessibilidade
/// (HIG: empilhar e reduzir colunas em vez de truncar nomes).
struct TeamRow: View {
    let athletic: Athletic?
    var badgeSize: AthleticBadge.Size = .medium
    var isDimmed = false
    @Environment(\.favoriteAthleticID) private var favoriteAthleticID

    var body: some View {
        HStack(spacing: Spacing.s) {
            AthleticBadge(size: badgeSize, isUndefined: athletic == nil,
                          isFavorite: athletic != nil && athletic?.id == favoriteAthleticID)
            Text(athletic?.name ?? "A definir")
                .font(.headline)
                .foregroundStyle(athletic == nil || isDimmed ? Color.textTertiary : Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.s) {
        TeamRow(athletic: MockData.athletic("ath-bufalos"))
        TeamRow(athletic: nil)
        TeamRow(athletic: MockData.athletic("ath-poraque"), isDimmed: true)
    }
    .padding()
    .environment(\.favoriteAthleticID, "ath-bufalos")
    .dynamicTypeSize(.accessibility2)
}
