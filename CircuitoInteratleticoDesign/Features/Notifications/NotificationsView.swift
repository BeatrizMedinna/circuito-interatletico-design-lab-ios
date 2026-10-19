import SwiftUI

/// Tela 06 — Notificações, separadas em "Minha atlética" e "Geral".
/// Avisos ligados a uma partida abrem o detalhe dela.
struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    @State private var scope: HomeScope = .favorite

    var body: some View {
        VStack(spacing: 0) {
            UnderlineTabs(items: HomeScope.allCases, selection: $scope) { $0.title }
                .padding(.horizontal, Spacing.l)
                .background(Color.appBackground)
            Divider()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch appState.notificationsState {
        case .loading:
            VStack(spacing: 0) {
                ForEach(MockData.notifications.prefix(3)) { notification in
                    NotificationRow(notification: notification, opensMatch: false)
                    Divider().padding(.leading, Spacing.l)
                }
                Spacer(minLength: 0)
            }
            .redacted(reason: .placeholder)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Carregando notificações")
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar as notificações", systemImage: "wifi.exclamationmark")
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
                Text("Os avisos da próxima edição aparecem aqui.")
            }
        case .loaded(let all):
            list(all)
        }
    }

    @ViewBuilder
    private func list(_ all: [AppNotification]) -> some View {
        let favoriteID = appState.favoriteAthletic.id
        let items = (scope == .favorite ? all.filter { $0.athleticIDs.contains(favoriteID) } : all)
            .sorted { $0.date > $1.date }

        if items.isEmpty {
            if scope == .favorite && !all.isEmpty {
                ContentUnavailableView {
                    Label("Nenhum aviso da sua atlética", systemImage: "bell.slash")
                } description: {
                    Text("Avisos sobre os jogos de \(appState.favoriteAthletic.name) aparecem aqui.")
                } actions: {
                    Button("Ver avisos gerais") { withAnimation { scope = .general } }
                        .buttonStyle(.secondary)
                }
            } else {
                ContentUnavailableView {
                    Label("Nenhuma notificação", systemImage: "bell.slash")
                } description: {
                    Text("Avisos de jogos e mudanças de horário ou local aparecem aqui.")
                }
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(groups(items), id: \.day) { group in
                        Section {
                            ForEach(group.items) { notification in
                                row(notification)
                                Divider().padding(.leading, Spacing.l)
                            }
                        } header: {
                            Text(Formatters.dayLabel(group.day))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.textSecondary)
                                .padding(.horizontal, Spacing.l)
                                .padding(.vertical, Spacing.xs)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.canvas)
                                .accessibilityAddTraits(.isHeader)
                        }
                    }
                }
            }
            .refreshable { await appState.refresh() }
        }
    }

    /// Só vira link quando a partida existe; os demais avisos não levam a lugar nenhum.
    @ViewBuilder
    private func row(_ notification: AppNotification) -> some View {
        if let matchID = notification.matchID, appState.match(id: matchID) != nil {
            NavigationLink(value: HomeRoute.match(matchID)) {
                NotificationRow(notification: notification, opensMatch: true)
            }
            .buttonStyle(.pressableCard)
        } else {
            NotificationRow(notification: notification, opensMatch: false)
        }
    }

    private func groups(_ items: [AppNotification]) -> [(day: Date, items: [AppNotification])] {
        let calendar = Calendar.current
        var result: [(day: Date, items: [AppNotification])] = []
        for item in items {
            let day = calendar.startOfDay(for: item.date)
            if let last = result.indices.last, result[last].day == day {
                result[last].items.append(item)
            } else {
                result.append((day, [item]))
            }
        }
        return result
    }
}

private struct NotificationRow: View {
    let notification: AppNotification
    let opensMatch: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: notification.kind.symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Spacer(minLength: 0)
                    Text(Formatters.time(notification.date))
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.textSecondary)
                }
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if opensMatch {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textSecondary)
                    .padding(.top, 4)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, Spacing.m)
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint(opensMatch ? "Abre a partida" : "")
    }
}

private func notificationsPreview(_ scenario: LabScenario, favorite: Athletic.ID = "ath-bufalos") -> some View {
    NavigationStack { NotificationsView() }
        .environment(AppState(favoriteAthletic: MockData.athletic(favorite), scenario: scenario, preloaded: true))
}

#Preview("Com avisos") { notificationsPreview(.filled) }
#Preview("Atlética sem avisos") { notificationsPreview(.filled, favorite: "ath-poraque") }
#Preview("Vazio") { notificationsPreview(.empty) }
#Preview("Carregando") { notificationsPreview(.loading) }
#Preview("Erro") { notificationsPreview(.error) }
