import SwiftUI

/// Listas completas abertas pelo "Ver mais" da Home.
enum MatchListKind: Hashable {
    case upcoming, recent

    var title: String {
        switch self {
        case .upcoming: "Próximos jogos"
        case .recent: "Últimos jogos"
        }
    }

    var emptyMessage: String {
        switch self {
        case .upcoming: "Nenhum jogo agendado por enquanto."
        case .recent: "Nenhum jogo encerrado ainda."
        }
    }

    var emptySymbol: String {
        switch self {
        case .upcoming: "calendar"
        case .recent: "flag.checkered"
        }
    }

    /// Próximos: do mais cedo ao mais tarde. Últimos: do mais recente ao mais antigo.
    func select(from matches: [Match]) -> [Match] {
        switch self {
        case .upcoming:
            matches.filter { $0.status == .scheduled }.sorted { $0.startDate < $1.startDate }
        case .recent:
            matches.filter { $0.status == .finished }.sorted { $0.startDate > $1.startDate }
        }
    }
}

/// Lista vertical agrupada por dia, com o cabeçalho do dia fixo ao rolar.
struct MatchListView: View {
    @Environment(AppState.self) private var appState
    let kind: MatchListKind
    /// `nil` = todas as atléticas.
    let athleticID: Athletic.ID?

    var body: some View {
        Group {
            if groups.isEmpty {
                ContentUnavailableView {
                    Label(kind.title, systemImage: kind.emptySymbol)
                } description: {
                    Text(kind.emptyMessage)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Spacing.s, pinnedViews: [.sectionHeaders]) {
                        ForEach(groups, id: \.day) { group in
                            Section {
                                ForEach(group.matches) { match in
                                    NavigationLink(value: AppRoute.match(match.id)) {
                                        MatchCard(match: match, date: .time)
                                    }
                                    .buttonStyle(.pressableCard)
                                }
                            } header: {
                                Text(Formatters.dayLabel(group.day))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.textSecondary)
                                    .padding(.vertical, Spacing.xs)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.canvas)
                                    .accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, Spacing.l)
                }
                .refreshable { await appState.refresh() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.canvas.ignoresSafeArea())
        .navigationTitle(kind.title)
        .navigationSubtitle(MockData.athletics.first { $0.id == athleticID }?.name ?? "Todas as atléticas")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var groups: [(day: Date, matches: [Match])] {
        guard case .loaded(let all) = appState.matchesState else { return [] }
        let matches = kind.select(from: athleticID.map { id in all.filter { $0.involves(id) } } ?? all)
        let calendar = Calendar.current
        var result: [(day: Date, matches: [Match])] = []
        for match in matches {
            let day = calendar.startOfDay(for: match.startDate)
            if let last = result.indices.last, result[last].day == day {
                result[last].matches.append(match)
            } else {
                result.append((day, [match]))
            }
        }
        return result
    }
}

#Preview("Próximos · Geral") {
    NavigationStack { MatchListView(kind: .upcoming, athleticID: nil) }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}

#Preview("Últimos · Minha atlética") {
    NavigationStack { MatchListView(kind: .recent, athleticID: "ath-bufalos") }
        .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
}
