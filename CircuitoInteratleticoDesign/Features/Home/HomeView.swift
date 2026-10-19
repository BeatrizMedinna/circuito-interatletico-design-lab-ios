import SwiftUI

/// Recorte da Home e das Notificações: jogos/avisos da atlética de coração ou de todas.
enum HomeScope: Hashable, CaseIterable {
    case favorite, general

    var title: String {
        switch self {
        case .favorite: "Minha atlética"
        case .general: "Geral"
        }
    }
}

/// Tela 02 — Início: ao vivo, próximos e últimos jogos, com acesso às notificações.
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var scope: HomeScope = .favorite

    var body: some View {
        VStack(spacing: 0) {
            header
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Cabeçalho

    private var header: some View {
        VStack(spacing: Spacing.xxs) {
            HStack(alignment: .center, spacing: Spacing.s) {
                Text(MockData.edition.name)
                    .font(.title.bold())
                    .foregroundStyle(.textPrimary)
                    .lineLimit(2)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                NavigationLink(value: HomeRoute.notifications) {
                    CircleIconLabel(systemName: "bell")
                }
                .buttonStyle(.pressableCard)
                .accessibilityLabel("Notificações")
            }
            if showsScopeTabs {
                UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.xs)
        .padding(.bottom, showsScopeTabs ? 0 : Spacing.s)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    /// As abas só aparecem quando há jogos para filtrar.
    private var showsScopeTabs: Bool {
        guard case .loaded(let matches) = appState.matchesState else { return false }
        return !matches.isEmpty
    }

    // MARK: - Conteúdo

    @ViewBuilder
    private var content: some View {
        switch appState.matchesState {
        case .loading:
            loadingFeed
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar os jogos", systemImage: "wifi.exclamationmark")
            } description: {
                Text("Verifique sua conexão e tente novamente.")
            } actions: {
                Button("Tentar novamente") { Task { await appState.retry() } }
                    .buttonStyle(.secondary)
            }
        case .unavailable:
            ContentUnavailableView {
                Label("Nenhuma edição em andamento", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Quando a próxima edição começar, os jogos aparecem aqui.")
            }
        case .loaded(let allMatches):
            feed(allMatches)
        }
    }

    @ViewBuilder
    private func feed(_ allMatches: [Match]) -> some View {
        let favorite = appState.favoriteAthletic
        let matches = scope == .favorite ? allMatches.filter { $0.involves(favorite.id) } : allMatches

        if allMatches.isEmpty {
            ContentUnavailableView {
                Label("Cronograma ainda não publicado", systemImage: "calendar")
            } description: {
                Text("Os jogos aparecem aqui assim que a organização publicar o cronograma.")
            }
        } else if matches.isEmpty {
            ContentUnavailableView {
                Label("Sua atlética ainda não tem jogos", systemImage: "sportscourt")
            } description: {
                Text("Quando houver jogos de \(favorite.name) no cronograma, eles aparecem aqui.")
            } actions: {
                Button("Ver todos os jogos") { withAnimation { scope = .general } }
                    .buttonStyle(.secondary)
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    liveSection(matches.filter { $0.status == .live }.sorted { $0.startDate < $1.startDate })
                    listSection(.upcoming, matches: MatchListKind.upcoming.select(from: matches))
                    listSection(.recent, matches: MatchListKind.recent.select(from: matches))
                }
                .padding(.vertical, Spacing.l)
            }
            .refreshable { await appState.refresh() }
        }
    }

    @ViewBuilder
    private func liveSection(_ live: [Match]) -> some View {
        if live.isEmpty {
            InlineNote(systemImage: "dot.radiowaves.left.and.right",
                       text: scope == .favorite ? "Sua atlética não tem jogo ao vivo agora." : "Nenhum jogo ao vivo agora.")
                .padding(.horizontal, Spacing.l)
        } else {
            LiveCarousel(matches: live, lastRefresh: appState.lastRefresh)
        }
    }

    private func listSection(_ kind: MatchListKind, matches: [Match]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: kind.title) {
                if matches.count > 1 {
                    NavigationLink("Ver mais", value: HomeRoute.matchList(kind, scope))
                        .frame(minHeight: 44)
                        .accessibilityLabel("Ver mais \(kind.title.lowercased())")
                }
            }
            .padding(.horizontal, Spacing.l)

            if matches.isEmpty {
                InlineNote(systemImage: kind.emptySymbol, text: kind.emptyMessage)
                    .padding(.horizontal, Spacing.l)
            } else {
                MatchCarousel(matches: Array(matches.prefix(5)))
            }
        }
    }

    private var loadingFeed: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            MatchHeaderCard(match: MockData.matches[0])
                .padding(.horizontal, Spacing.l)
            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Próximos jogos")
                MatchCard(match: MockData.matches[3])
            }
            .padding(.horizontal, Spacing.l)
            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.l)
        .redacted(reason: .placeholder)
        .disabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carregando jogos")
    }
}

/// Carrossel paginado dos jogos ao vivo, com indicador de página.
private struct LiveCarousel: View {
    let matches: [Match]
    let lastRefresh: Date
    @State private var currentID: Match.ID?

    var body: some View {
        VStack(spacing: Spacing.s) {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: Spacing.s) {
                    ForEach(matches) { match in
                        NavigationLink(value: HomeRoute.match(match.id)) {
                            MatchHeaderCard(match: match, lastRefresh: lastRefresh, showsLiveBadge: true)
                        }
                        .buttonStyle(.pressableCard)
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, Spacing.l, for: .scrollContent)
            .scrollPosition(id: $currentID)

            if matches.count > 1 {
                let index = matches.firstIndex { $0.id == currentID } ?? 0
                HStack(spacing: 6) {
                    ForEach(matches.indices, id: \.self) { item in
                        Capsule()
                            .fill(item == index ? Color.textPrimary : Color.surfaceSelected)
                            .frame(width: item == index ? 24 : 12, height: 4)
                    }
                }
                .animation(.snappy, value: index)
                .frame(maxWidth: .infinity)
                .accessibilityElement()
                .accessibilityLabel("Jogo ao vivo \(index + 1) de \(matches.count)")
            }
        }
    }
}

/// Carrossel horizontal de cartões compactos, mostrando a borda do próximo.
private struct MatchCarousel: View {
    let matches: [Match]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: Spacing.s) {
                ForEach(matches) { match in
                    NavigationLink(value: HomeRoute.match(match.id)) {
                        MatchCard(match: match)
                    }
                    .buttonStyle(.pressableCard)
                    .containerRelativeFrame(.horizontal, count: 7, span: 6, spacing: Spacing.s)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, Spacing.l, for: .scrollContent)
    }
}

#Preview("Minha atlética") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}

#Preview("Atlética sem jogos") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-poraque"), scenario: .filled, preloaded: true))
}

#Preview("Cronograma não publicado") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .empty, preloaded: true))
}

#Preview("Carregando") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .loading, preloaded: true))
}

#Preview("Erro") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .error, preloaded: true))
}

#Preview("Sem edição ativa") {
    NavigationStack { HomeView() }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .unavailable, preloaded: true))
}
