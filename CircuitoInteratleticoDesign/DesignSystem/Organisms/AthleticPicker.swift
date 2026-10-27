import SwiftUI

/// Busca + lista de atléticas com escolha única. Usada no onboarding,
/// na troca da atlética de coração e no filtro do cronograma.
struct AthleticPicker: View {
    let athletics: [Athletic]
    @Binding var selectedID: Athletic.ID?
    @Binding var query: String
    var label = "Qual atlética é a sua?"
    /// Primeira linha que limpa a escolha (ex.: "Todas as atléticas" no filtro).
    var allOptionTitle: String? = nil
    /// Linhas empilhadas em tamanhos de acessibilidade (ver `SelectionRow`). Opcional: só o onboarding liga.
    var stacksRowsAtAccessibilitySizes = false

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
                            SelectionRow(title: allOptionTitle, isSelected: selectedID == nil, action: { selectedID = nil }) {
                                Image(systemName: "person.3")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.textPrimary)
                                    .frame(width: 44, height: 44)
                                    .background(.surfaceInset, in: Circle())
                            }
                        }
                        ForEach(filtered) { athletic in
                            AthleticSelectionRow(athletic: athletic, isSelected: athletic.id == selectedID,
                                                 stacksAtAccessibilitySizes: stacksRowsAtAccessibilitySizes) {
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
        .sensoryFeedback(.selection, trigger: selectedID)
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
