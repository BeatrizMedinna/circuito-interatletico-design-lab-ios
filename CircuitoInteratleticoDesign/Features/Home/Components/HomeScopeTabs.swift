import SwiftUI

/// Abas "Minha atlética | Geral" da Início. Ficam fixas no topo enquanto o
/// cabeçalho (edição, sino, atlética) rola com o conteúdo — seção fixa do LazyVStack.
struct HomeScopeTabs: View {
    @Environment(AppState.self) private var appState
    @Binding var scope: HomeScope

    var body: some View {
        if Self.isVisible(appState) {
            UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
                .padding(.horizontal, Spacing.l)
                .frame(maxWidth: .infinity)
                // Trilho de ponta a ponta, como em Notificações.
                .overlay(alignment: .bottom) {
                    Rectangle().fill(.separatorLine).frame(height: 1)
                }
                // Fundo sólido: o feed passa por baixo das abas fixadas sem misturar.
                .background(Color.appBackground)
        }
    }

    /// As abas só aparecem com atlética de coração e jogos para filtrar (regra anterior, sem mudança).
    static func isVisible(_ appState: AppState) -> Bool {
        guard appState.favoriteAthletic != nil, case .loaded(let matches) = appState.matchesState else { return false }
        return !matches.isEmpty
    }
}

#Preview(traits: .appAppearance) {
    HomeScopeTabs(scope: .constant(.favorite))
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}
