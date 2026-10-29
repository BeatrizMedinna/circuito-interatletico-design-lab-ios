import SwiftUI

/// Tela 01 — Escolha da atlética de coração no primeiro acesso.
/// O torcedor busca, seleciona uma atlética e toca em "Continuar", ou segue sem
/// atlética de coração (RN-86: a escolha é opcional e pode ser feita depois).
struct OnboardingView: View {
    /// `nil` quando não há edição ativa.
    let editionName: String?
    let state: LoadState<[Athletic]>
    let onRetry: () -> Void
    let onEnter: (Athletic) -> Void
    /// Entra no app sem atlética de coração.
    let onSkip: () -> Void

    @State private var selectedID: Athletic.ID?
    @State private var query: String

    init(editionName: String?,
         state: LoadState<[Athletic]>,
         initialSelectionID: Athletic.ID? = nil,
         initialQuery: String = "",
         onRetry: @escaping () -> Void = {},
         onEnter: @escaping (Athletic) -> Void = { _ in },
         onSkip: @escaping () -> Void = {}) {
        self.editionName = editionName
        self.state = state
        self.onRetry = onRetry
        self.onEnter = onEnter
        self.onSkip = onSkip
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
    }

    // MARK: - Seções

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            // Mesmo estilo dos títulos das telas principais (Início, Cronograma, Ranking).
            Text("Escolha sua atlética")
                .font(.title.bold())
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
            AthleticPicker(athletics: Array(MockData.athletics.prefix(5)), selectedID: .constant(nil), query: .constant(""))
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Carregando atléticas")
        case .loaded(let athletics):
            AthleticPicker(athletics: athletics, selectedID: $selectedID, query: $query,
                           stacksRowsAtAccessibilitySizes: true)
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

    private var enterBar: some View {
        VStack(spacing: Spacing.xxs) {
            Button("Continuar") {
                if let selectedAthletic {
                    onEnter(selectedAthletic)
                }
            }
            .buttonStyle(.primary)
            .disabled(selectedAthletic == nil)
            .accessibilityHint(selectedAthletic == nil ? "Selecione uma atlética para continuar" : "")

            // Ação secundária discreta: a escolha é opcional e pode ser feita depois.
            Button("Seguir sem atlética", action: onSkip)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .underline()
                .frame(minHeight: 44)
                .disabled(!isLoaded)
                .opacity(!isLoaded ? 0 : 1)
                .accessibilityHidden(!isLoaded)
                .accessibilityHint("Você pode escolher sua atlética depois, na Início")
        }
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

    private var isLoaded: Bool {
        if case .loaded = state { true } else { false }
    }

    private var selectedAthletic: Athletic? {
        guard case .loaded(let athletics) = state else { return nil }
        return athletics.first { $0.id == selectedID }
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
