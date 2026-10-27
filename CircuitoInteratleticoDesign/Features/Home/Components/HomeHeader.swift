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
                    // Só no maior tamanho de acessibilidade uma palavra longa
                    // ("Universitária") não cabe na linha; aí o título reduz um pouco.
                    .minimumScaleFactor(0.75)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                notificationsButton
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
        // Trilho das abas de ponta a ponta, como em Notificações: separa o cabeçalho do feed.
        .overlay(alignment: .bottom) {
            if showsScopeTabs {
                Rectangle().fill(.separatorLine).frame(height: 1)
            }
        }
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    /// Sino com contador Lime. O círculo tem tamanho fixo (44 pt), como um botão de
    /// barra: o ícone e o contador param de crescer no maior tamanho padrão (xxxLarge)
    /// para o número não cobrir o sino; acima disso, tocar e segurar mostra o
    /// visualizador de conteúdo ampliado do sistema (Large Content Viewer).
    private var notificationsButton: some View {
        NavigationLink(value: AppRoute.notifications) {
            CircleIconLabel(systemName: "bell")
                .overlay(alignment: .topTrailing) { CountBadge(count: appState.unreadCount) }
        }
        .buttonStyle(.pressableCard)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityLabel(notificationsLabel)
        .accessibilityShowsLargeContentViewer {
            Label(notificationsLabel, systemImage: "bell")
        }
    }

    private var notificationsLabel: String {
        appState.unreadCount > 0 ? "Notificações, \(appState.unreadCount) não lidas" : "Notificações"
    }

    /// Atlética de coração; tocar abre a troca ou a remoção (RN-86).
    /// O escudo ganha o anel Teal da atlética de coração e a seta fica junto do
    /// nome, para o rótulo "Atlética de coração" usar a largura toda em textos grandes.
    private var favoriteButton: some View {
        Button(action: onPickFavorite) {
            HStack(spacing: Spacing.s) {
                if let favorite = appState.favoriteAthletic {
                    AthleticBadge(size: .small, isFavorite: true)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Atlética de coração")
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                            Text(favorite.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.textPrimary)
                                .lineLimit(2)
                            chevron
                        }
                    }
                } else {
                    Image(systemName: "heart")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(.surfaceInset, in: Circle())
                        .accessibilityHidden(true)
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xxs) {
                        Text("Escolher atlética de coração")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.textPrimary)
                        chevron
                    }
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressableCard)
        .accessibilityLabel(appState.favoriteAthletic.map { "Atlética de coração: \($0.name)" } ?? "Escolher atlética de coração")
        .accessibilityHint("Abre a escolha da atlética")
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.textSecondary)
            .accessibilityHidden(true)
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
