import SwiftUI

/// Cabeçalho da tela de Início: edição, botão de notificações, seletor da atlética de coração e abas de escopo.
struct HomeHeader: View {
    @Environment(AppState.self) private var appState
    @Binding var scope: HomeScope
    let onPickFavorite: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            HStack(alignment: .center, spacing: Spacing.s) {
                Text(MockData.edition.name)
                    .font(.title.bold())
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                NavigationLink(value: AppRoute.notifications) {
                    CircleIconLabel(systemName: "bell")
                        .overlay(alignment: .topTrailing) { CountBadge(count: appState.unreadCount) }
                }
                .buttonStyle(.pressableCard)
                .accessibilityLabel(appState.unreadCount > 0 ? "Notificações, \(appState.unreadCount) não lidas" : "Notificações")
            }

            favoriteButton
                .frame(maxWidth: .infinity, alignment: .leading)

            if showsScopeTabs {
                UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.xs)
        .padding(.bottom, showsScopeTabs ? 0 : Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    /// Atlética de coração; tocar abre a troca ou a remoção (RN-86).
    private var favoriteButton: some View {
        Button(action: onPickFavorite) {
            HStack(spacing: Spacing.xs) {
                if let favorite = appState.favoriteAthletic {
                    AthleticBadge(size: .small, fill: .surface)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Atlética de coração")
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                        Text(favorite.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.textPrimary)
                            .lineLimit(1)
                    }
                } else {
                    Image(systemName: "heart")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 32, height: 32)
                        .background(.surface, in: Circle())
                    Text("Escolher atlética de coração")
                        .font(.subheadline.weight(.semibold))
                }
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.textSecondary)
            }
            .foregroundStyle(.textPrimary)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressableCard)
        .accessibilityLabel(appState.favoriteAthletic.map { "Atlética de coração: \($0.name)" } ?? "Escolher atlética de coração")
        .accessibilityHint("Abre a escolha da atlética")
    }

    /// As abas só aparecem com atlética de coração e jogos para filtrar.
    private var showsScopeTabs: Bool {
        guard appState.favoriteAthletic != nil, case .loaded(let matches) = appState.matchesState else { return false }
        return !matches.isEmpty
    }
}

#Preview {
    HomeHeader(scope: .constant(.favorite), onPickFavorite: {})
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}
