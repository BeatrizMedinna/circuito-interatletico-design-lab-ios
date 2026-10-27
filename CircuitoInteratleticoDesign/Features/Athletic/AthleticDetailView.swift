import SwiftUI

/// Telas 10, 11 e 12 — Detalhes da atlética: resumo no topo (com a ação de atlética
/// de coração) e três abas (Agenda, Sobre, Modalidades).
struct AthleticDetailView: View {
    enum Tab: Hashable, CaseIterable {
        case matches, about, sports

        var title: String {
            switch self {
            case .matches: "Agenda"
            case .about: "Sobre"
            case .sports: "Modalidades"
            }
        }

        var symbol: String {
            switch self {
            case .matches: "calendar"
            case .about: "info.circle"
            case .sports: "trophy"
            }
        }
    }

    @Environment(AppState.self) private var appState
    let athleticID: Athletic.ID
    @State private var tab: Tab = .about
    /// O nome aparece na barra só depois que o cartão do topo sai da tela,
    /// para não repetir o cabeçalho (padrão das telas de perfil do iOS).
    @State private var showsBarTitle = false

    var body: some View {
        Group {
            if let athletic = MockData.athletics.first(where: { $0.id == athleticID }) {
                content(athletic)
            } else {
                ContentUnavailableView {
                    Label("Atlética indisponível", systemImage: "shield")
                } description: {
                    Text("Não foi possível abrir esta atlética. Volte e tente novamente.")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.canvas.ignoresSafeArea())
        // O título usa o nome da atlética (também no menu do botão Voltar e no VoiceOver).
        .navigationTitle(MockData.athletics.first { $0.id == athleticID }?.name ?? "Atlética")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(MockData.athletics.first { $0.id == athleticID }?.name ?? "Atlética")
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .opacity(showsBarTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: showsBarTitle)
                    .accessibilityHidden(!showsBarTitle)
            }
        }
    }

    private func content(_ athletic: Athletic) -> some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                AthleticSummaryCard(athletic: athletic,
                                    entry: appState.rankingEntry(for: athletic.id),
                                    profile: MockData.profile(for: athletic.id),
                                    isFavorite: athletic.id == appState.favoriteAthletic?.id) {
                    FavoriteChoice(athletic: athletic)
                }
                    .padding(Spacing.l)
                Section {
                    Group {
                        switch tab {
                        case .matches: AthleticMatchesTab(athletic: athletic)
                        case .about: AthleticAboutTab(athletic: athletic, profile: MockData.profile(for: athletic.id))
                        case .sports: AthleticSportsTab(athletic: athletic)
                        }
                    }
                    .padding(Spacing.l)
                } header: {
                    UnderlineTabs(items: Tab.allCases, selection: $tab, systemImage: \.symbol) { $0.title }
                        .padding(.horizontal, Spacing.l)
                        .background(Color.canvas)
                        // Trilho de ponta a ponta, como nas demais abas do app.
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(.separatorLine).frame(height: 1)
                        }
                }
            }
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top > 56
        } action: { _, isPastHeader in
            showsBarTitle = isPastHeader
        }
        .refreshable { await appState.refresh() }
    }
}

// MARK: - Previews

private func athleticPreview(_ id: Athletic.ID, favorite: Athletic.ID? = "ath-bufalos") -> some View {
    NavigationStack { AthleticDetailView(athleticID: id) }
        .environment(AppState(favoriteAthletic: favorite.map { MockData.athletic($0) }, scenario: .filled, preloaded: true))
}

#Preview("Sua atlética") { athleticPreview("ath-bufalos") }
#Preview("Empatada, sem descrição") { athleticPreview("ath-diastolica") }
#Preview("Sem classificação") { athleticPreview("ath-nce") }
#Preview("Sem jogos nem dados") { athleticPreview("ath-falcoes") }
#Preview("Indisponível") { athleticPreview("inexistente") }
