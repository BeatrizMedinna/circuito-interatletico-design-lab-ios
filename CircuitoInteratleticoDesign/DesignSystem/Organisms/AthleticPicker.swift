import SwiftUI

/// Busca + lista de atléticas. Escolha única no onboarding e na troca da atlética
/// de coração; escolha múltipla no filtro do cronograma.
struct AthleticPicker: View {
    let athletics: [Athletic]
    /// `nil` representa a opção "todas" (`allOptionTitle`).
    private let isSelected: (Athletic.ID?) -> Bool
    private let select: (Athletic.ID?) -> Void
    @Binding var query: String
    var label: String
    /// Primeira linha que limpa a escolha (ex.: "Todas as atléticas" no filtro).
    var allOptionTitle: String?
    /// Linhas empilhadas em tamanhos de acessibilidade (ver `SelectionRow`). Opcional: só o onboarding liga.
    var stacksRowsAtAccessibilitySizes = false
    @State private var feedbackTrigger = 0

    /// Escolha única (onboarding, atlética de coração).
    init(athletics: [Athletic], selectedID: Binding<Athletic.ID?>, query: Binding<String>,
         label: String = "Qual atlética é a sua?", allOptionTitle: String? = nil,
         stacksRowsAtAccessibilitySizes: Bool = false) {
        self.athletics = athletics
        isSelected = { $0 == selectedID.wrappedValue }
        select = { selectedID.wrappedValue = $0 }
        _query = query
        self.label = label
        self.allOptionTitle = allOptionTitle
        self.stacksRowsAtAccessibilitySizes = stacksRowsAtAccessibilitySizes
    }

    /// Escolha múltipla (filtro do cronograma): tocar marca ou desmarca; "todas" limpa.
    init(athletics: [Athletic], selectedIDs: Binding<Set<Athletic.ID>>, query: Binding<String>,
         label: String, allOptionTitle: String) {
        self.athletics = athletics
        isSelected = { id in id.map { selectedIDs.wrappedValue.contains($0) } ?? selectedIDs.wrappedValue.isEmpty }
        select = { id in
            guard let id else { selectedIDs.wrappedValue = []; return }
            if selectedIDs.wrappedValue.contains(id) {
                selectedIDs.wrappedValue.remove(id)
            } else {
                selectedIDs.wrappedValue.insert(id)
            }
        }
        _query = query
        self.label = label
        self.allOptionTitle = allOptionTitle
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(label)
                    .textCase(.uppercase)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textSecondary)
                    .accessibilityAddTraits(.isHeader)
                SearchField(prompt: "Buscar atlética", text: $query)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.l)
            .padding(.bottom, Spacing.s)

            if filtered.isEmpty {
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
                        if let allOptionTitle, query.isEmpty {
                            SelectionRow(title: allOptionTitle, isSelected: isSelected(nil), action: { choose(nil) }) {
                                Image(systemName: "person.3")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.textPrimary)
                                    .frame(width: 44, height: 44)
                                    .background(.surfaceInset, in: Circle())
                            }
                        }
                        ForEach(filtered) { athletic in
                            AthleticSelectionRow(athletic: athletic, isSelected: isSelected(athletic.id),
                                                 stacksAtAccessibilitySizes: stacksRowsAtAccessibilitySizes) {
                                choose(athletic.id)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.xs)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .sensoryFeedback(.selection, trigger: feedbackTrigger)
    }

    private func choose(_ id: Athletic.ID?) {
        select(id)
        feedbackTrigger += 1
    }

    /// Busca por nome ou sigla, ignorando maiúsculas e acentos.
    private var filtered: [Athletic] {
        let term = query.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else { return athletics }
        return athletics.filter { athletic in
            [athletic.name, athletic.acronym].contains {
                $0.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
    }
}

#Preview(traits: .appAppearance) {
    @Previewable @State var selectedID: Athletic.ID? = "ath-bufalos"
    @Previewable @State var query = ""
    AthleticPicker(athletics: MockData.athletics, selectedID: $selectedID, query: $query)
        .background(.canvas)
}
