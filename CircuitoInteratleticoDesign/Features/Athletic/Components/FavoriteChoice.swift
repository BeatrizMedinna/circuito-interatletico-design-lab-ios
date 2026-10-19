import SwiftUI

/// Ação única e reversível, escrita conforme o estado: escolher, trocar ou remover.
/// Substitui o coração solto na barra, que sugeria favoritar várias atléticas.
struct FavoriteChoice: View {
    @Environment(AppState.self) private var appState
    let athletic: Athletic

    var body: some View {
        let current = appState.favoriteAthletic
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if current?.id == athletic.id {
                Text("Esta é a sua atlética de coração. Você vê os jogos e avisos dela em destaque.")
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                Button("Remover atlética de coração") { appState.setFavorite(nil) }
                    .font(.subheadline.weight(.semibold))
                    .underline()
                    .foregroundStyle(.textPrimary)
                    .frame(minHeight: 44)
            } else {
                Button {
                    appState.setFavorite(athletic)
                } label: {
                    Text(current == nil ? "Escolher como atlética de coração" : "Torcer para \(athletic.name)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.secondary)
                Text(current.map { "Hoje você torce por \($0.name). Clique se deseja trocar sua torcida." }
                     ?? "Você acompanha uma atlética por vez e pode trocar quando quiser.")
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .sensoryFeedback(.selection, trigger: current?.id)
    }
}

#Preview {
    FavoriteChoice(athletic: MockData.athletic("ath-bufalos"))
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
        .padding()
}
