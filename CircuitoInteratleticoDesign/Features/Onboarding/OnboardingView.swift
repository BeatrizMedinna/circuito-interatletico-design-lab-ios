import SwiftUI

/// Tela 01 — Escolha da atlética de coração no primeiro acesso.
/// O torcedor busca, seleciona uma atlética e toca em "Entrar".
struct OnboardingView: View {
    /// `nil` quando não há edição ativa.
    let editionName: String?
    let state: LoadState<[Athletic]>
    let onRetry: () -> Void
    let onEnter: (Athletic) -> Void

    @State private var selectedID: Athletic.ID?
    @State private var query: String

    init(editionName: String?,
         state: LoadState<[Athletic]>,
         initialSelectionID: Athletic.ID? = nil,
         initialQuery: String = "",
         onRetry: @escaping () -> Void = {},
         onEnter: @escaping (Athletic) -> Void = { _ in }) {
        self.editionName = editionName
        self.state = state
        self.onRetry = onRetry
        self.onEnter = onEnter
        _selectedID = State(initialValue: initialSelectionID)
        _query = State(initialValue: initialQuery)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.canvas.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsEnterButton {
                enterBar
            }
        }
        .sensoryFeedback(.selection, trigger: selectedID)
    }

    // MARK: - Seções

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("Escolha sua Atlética")
                .font(.title2.bold())
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let editionName {
                Text(editionName.uppercased())
                    .font(.footnote)
                    .foregroundStyle(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.m)
        .padding(.bottom, Spacing.m)
        .background(Color.appBackground.ignoresSafeArea(edges: .top))
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            VStack(spacing: 0) {
                searchSection
                placeholderList
            }
            .disabled(true)
        case .loaded(let athletics):
            VStack(spacing: 0) {
                searchSection
                list(of: filtered(athletics))
            }
        case .failed:
            ContentUnavailableView {
                Label("Não foi possível carregar as atléticas", systemImage: "wifi.exclamationmark")
            } description: {
                Text("Verifique sua conexão e tente novamente.")
            } actions: {
                Button("Tentar novamente", action: onRetry)
                    .buttonStyle(.secondary)
            }
        case .unavailable:
            ContentUnavailableView {
                Label("Nenhuma edição em andamento", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Quando a próxima edição começar, você poderá escolher sua atlética aqui.")
            }
        }
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Qual atlética é a sua?")
                .textCase(.uppercase)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
                .accessibilityAddTraits(.isHeader)
            SearchField(prompt: "Buscar atlética", text: $query)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.l)
        .padding(.bottom, Spacing.s)
    }

    @ViewBuilder
    private func list(of athletics: [Athletic]) -> some View {
        if athletics.isEmpty {
            ContentUnavailableView {
                Label("Nenhuma atlética encontrada", systemImage: "magnifyingglass")
            } description: {
                Text("Confira a grafia ou busque pela sigla, como ENG ou MED.")
            } actions: {
                Button("Limpar busca") { query = "" }
                    .buttonStyle(.secondary)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.s) {
                    ForEach(athletics) { athletic in
                        AthleticSelectionRow(athletic: athletic, isSelected: athletic.id == selectedID) {
                            selectedID = athletic.id
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.xs)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var placeholderList: some View {
        ScrollView {
            VStack(spacing: Spacing.s) {
                ForEach(MockData.athletics.prefix(5)) { athletic in
                    AthleticSelectionRow(athletic: athletic, isSelected: false) {}
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.xs)
        }
        .redacted(reason: .placeholder)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Carregando atléticas")
    }

    private var enterBar: some View {
        Button("Entrar") {
            if let selectedAthletic {
                onEnter(selectedAthletic)
            }
        }
        .buttonStyle(.primary)
        .disabled(selectedAthletic == nil)
        .accessibilityHint(selectedAthletic == nil ? "Selecione uma atlética para continuar" : "")
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.xs)
        .background(Color.appBackground.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Lógica local

    private var showsEnterButton: Bool {
        switch state {
        case .loading, .loaded: true
        case .failed, .unavailable: false
        }
    }

    private var selectedAthletic: Athletic? {
        guard case .loaded(let athletics) = state else { return nil }
        return athletics.first { $0.id == selectedID }
    }

    /// Busca por nome ou sigla, ignorando maiúsculas e acentos.
    private func filtered(_ athletics: [Athletic]) -> [Athletic] {
        let term = query.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return athletics }
        return athletics.filter { athletic in
            [athletic.name, athletic.acronym].contains {
                $0.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
    }
}

/// Linha selecionável da lista de atléticas. A seleção é indicada por fundo,
/// borda e ícone, não apenas por tom de cinza.
private struct AthleticSelectionRow: View {
    let athletic: Athletic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                AthleticBadge(size: .medium)
                VStack(alignment: .leading, spacing: 2) {
                    Text(athletic.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text(athletic.division.name)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
                .multilineTextAlignment(.leading)
                Spacer(minLength: Spacing.xs)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                    .accessibilityHidden(true)
            }
            .padding(Spacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.surfaceSelected : Color.surface,
                        in: RoundedRectangle(cornerRadius: Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.card)
                    .strokeBorder(.borderStrong, lineWidth: isSelected ? 2 : 0)
            }
            .contentShape(RoundedRectangle(cornerRadius: Radius.card))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Previews

#Preview("Sem seleção") {
    OnboardingView(editionName: MockData.edition.name, state: .loaded(MockData.athletics))
}

#Preview("Com seleção") {
    OnboardingView(editionName: MockData.edition.name,
                   state: .loaded(MockData.athletics),
                   initialSelectionID: "ath-bufalos")
}

#Preview("Busca sem resultado") {
    OnboardingView(editionName: MockData.edition.name,
                   state: .loaded(MockData.athletics),
                   initialQuery: "Odontologia")
}

#Preview("Carregando") {
    OnboardingView(editionName: MockData.edition.name, state: .loading)
}

#Preview("Erro") {
    OnboardingView(editionName: MockData.edition.name, state: .failed)
}

#Preview("Edição indisponível") {
    OnboardingView(editionName: nil, state: .unavailable)
}

#Preview("Dynamic Type grande") {
    OnboardingView(editionName: MockData.edition.name,
                   state: .loaded(MockData.athletics),
                   initialSelectionID: "ath-nce")
        .environment(\.dynamicTypeSize, .accessibility2)
}
