import SwiftUI

/// Tela 08 — Filtros do cronograma. Edita um rascunho: ✕ descarta, ✓ aplica,
/// "Limpar" zera o rascunho. O rodapé mostra quantos jogos o rascunho encontra.
struct ScheduleFilterSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let items: [ScheduleItem]
    @Binding var applied: ScheduleFilters
    @State private var draft: ScheduleFilters

    init(items: [ScheduleItem], applied: Binding<ScheduleFilters>) {
        self.items = items
        _applied = applied
        _draft = State(initialValue: applied.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    field("Modalidade") {
                        NavigationLink {
                            SportFilterPicker(sports: sportOptions, selection: $draft.sportNames)
                        } label: {
                            SelectorLabel(value: summary(draft.sportNames.count, one: "modalidade", many: "modalidades"),
                                          placeholder: "Todas as modalidades")
                        }
                        .buttonStyle(.pressableCard)
                        // Escolhas em lista, cada uma com ✕ (a barra de pílulas fica só na tela).
                        if !draft.sportNames.isEmpty {
                            SelectedItemsList(items: sportOptions.filter { draft.sportNames.contains($0.name) },
                                              title: \.name,
                                              onRemove: { draft.sportNames.remove($0.name) },
                                              onRemoveAll: { draft.sportNames = [] }) { sport in
                                Image(systemName: sport.symbol)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.textPrimary)
                                    .frame(width: 32, height: 32)
                                    .background(.surfaceInset, in: Circle())
                                    .accessibilityHidden(true)
                            }
                        }
                    }

                    field("Categoria") {
                        MultiFlowChips(options: genderOptions, selection: $draft.genders) { $0.label }
                    }

                    field("Atlética") {
                        if let favorite = appState.favoriteAthletic {
                            ChoiceChip(title: "Minha atlética · \(favorite.name)",
                                       isSelected: draft.athleticIDs.contains(favorite.id)) {
                                if draft.athleticIDs.contains(favorite.id) {
                                    draft.athleticIDs.remove(favorite.id)
                                } else {
                                    draft.athleticIDs.insert(favorite.id)
                                }
                            }
                        }
                        NavigationLink {
                            AthleticFilterPicker(selection: $draft.athleticIDs)
                        } label: {
                            SelectorLabel(value: summary(draft.athleticIDs.count, one: "atlética", many: "atléticas"),
                                          placeholder: "Todas as atléticas")
                        }
                        .buttonStyle(.pressableCard)
                        if !draft.athleticIDs.isEmpty {
                            SelectedItemsList(items: MockData.athletics.filter { draft.athleticIDs.contains($0.id) },
                                              title: \.name,
                                              onRemove: { draft.athleticIDs.remove($0.id) },
                                              onRemoveAll: { draft.athleticIDs = [] }) { athletic in
                                AthleticBadge(size: .small, isFavorite: athletic.id == appState.favoriteAthletic?.id)
                            }
                        }
                    }

                    field("Divisão") {
                        MultiFlowChips(options: MockData.divisions.map(\.id), selection: $draft.divisionIDs) { id in
                            MockData.divisions.first { $0.id == id }?.name ?? ""
                        }
                    }
                }
                .padding(Spacing.l)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { footer }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Cancelar")
                        .barControlNeutral()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        applied = draft
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel("Aplicar filtros")
                    .barPrimaryAction()
                }
            }
        }
        .sensoryFeedback(.selection, trigger: draft)
    }

    /// Texto do campo: "1 modalidade", "3 atléticas"; vazio mostra o "Todas…".
    private func summary(_ count: Int, one: String, many: String) -> String? {
        count == 0 ? nil : "\(count) \(count == 1 ? one : many)"
    }

    private var resultCount: Int { items.filter(draft.includes).count }

    private var footer: some View {
        VStack(spacing: Spacing.xs) {
            Text(resultCount == 0 ? "Nenhum jogo ou prova com esses filtros"
                 : resultCount == 1 ? "1 jogo ou prova no cronograma" : "\(resultCount) jogos e provas no cronograma")
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .contentTransition(.numericText())
                .animation(.snappy, value: resultCount)
            Button {
                withAnimation { draft = ScheduleFilters() }
            } label: {
                Text("Limpar filtros").frame(maxWidth: .infinity)
            }
            .buttonStyle(.secondary)
            .disabled(draft.isEmpty)
            .opacity(draft.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.xs)
        .background(Color.appBackground.ignoresSafeArea(edges: .bottom))
    }

    private var sportOptions: [Sport] {
        var seen = Set<String>()
        return items.map(\.sport).filter { seen.insert($0.name).inserted }.sorted { $0.name < $1.name }
    }

    private var genderOptions: [Gender] {
        [.male, .female, .mixed].filter { gender in items.contains { $0.sport.gender == gender } }
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

#Preview {
    @Previewable @State var filters = ScheduleFilters(gender: .female)
    Color.clear.sheet(isPresented: .constant(true)) {
        ScheduleFilterSheet(items: MockData.matches.map(ScheduleItem.match), applied: $filters)
            .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
