import SwiftUI

/// Critérios do cronograma. Cada campo aceita uma opção (hipótese do protótipo);
/// campos diferentes se combinam (todos precisam valer).
struct ScheduleFilters: Equatable {
    var sportName: String?
    var gender: Gender?
    var athleticID: Athletic.ID?
    var divisionID: Division.ID?

    var activeCount: Int {
        [sportName != nil, gender != nil, athleticID != nil, divisionID != nil].filter { $0 }.count
    }

    var isEmpty: Bool { activeCount == 0 }

    func includes(_ match: Match) -> Bool {
        (sportName == nil || match.sport.name == sportName)
            && (gender == nil || match.sport.gender == gender)
            && (athleticID.map(match.involves) ?? true)
            && (divisionID == nil || match.division.id == divisionID)
    }
}

/// Tela 08 — Filtros do cronograma. Edita um rascunho: ✕ descarta, ✓ aplica,
/// "Limpar" zera o rascunho. O rodapé mostra quantos jogos o rascunho encontra.
struct ScheduleFilterSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let matches: [Match]
    @Binding var applied: ScheduleFilters
    @State private var draft: ScheduleFilters

    init(matches: [Match], applied: Binding<ScheduleFilters>) {
        self.matches = matches
        _applied = applied
        _draft = State(initialValue: applied.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    field("Modalidade") {
                        NavigationLink {
                            SportFilterPicker(sports: sportOptions, selection: $draft.sportName)
                        } label: {
                            SelectorLabel(value: draft.sportName, placeholder: "Todas as modalidades")
                        }
                        .buttonStyle(.pressableCard)
                    }

                    field("Categoria") {
                        FlowChips(options: genderOptions, selection: $draft.gender) { $0.label }
                    }

                    field("Atlética") {
                        if let favorite = appState.favoriteAthletic {
                            ChoiceChip(title: "Minha atlética · \(favorite.name)", isSelected: draft.athleticID == favorite.id) {
                                draft.athleticID = draft.athleticID == favorite.id ? nil : favorite.id
                            }
                        }
                        NavigationLink {
                            AthleticFilterPicker(selection: $draft.athleticID)
                        } label: {
                            SelectorLabel(value: MockData.athletics.first { $0.id == draft.athleticID }?.name,
                                          placeholder: "Todas as atléticas")
                        }
                        .buttonStyle(.pressableCard)
                    }

                    field("Divisão") {
                        FlowChips(options: [MockData.serieOuro, MockData.seriePrata, MockData.serieBronze],
                                  selection: Binding(
                                    get: { [MockData.serieOuro, MockData.seriePrata, MockData.serieBronze].first { $0.id == draft.divisionID } },
                                    set: { draft.divisionID = $0?.id })) { $0.name }
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
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        applied = draft
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel("Aplicar filtros")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: draft)
    }

    private var resultCount: Int { matches.filter(draft.includes).count }

    private var footer: some View {
        VStack(spacing: Spacing.xs) {
            Text(resultCount == 0 ? "Nenhum jogo com esses filtros"
                 : resultCount == 1 ? "1 jogo no cronograma" : "\(resultCount) jogos no cronograma")
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .contentTransition(.numericText())
                .animation(.snappy, value: resultCount)
            Button {
                withAnimation { draft = ScheduleFilters() }
            } label: {
                Text("Limpar").frame(maxWidth: .infinity)
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
        return matches.map(\.sport).filter { seen.insert($0.name).inserted }.sorted { $0.name < $1.name }
    }

    private var genderOptions: [Gender] {
        [.male, .female, .mixed].filter { gender in matches.contains { $0.sport.gender == gender } }
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

/// Linha "Selecionar >" do wireframe; mostra o valor escolhido quando há.
private struct SelectorLabel: View {
    let value: String?
    let placeholder: String

    var body: some View {
        HStack {
            Text(value ?? placeholder)
                .font(.body.weight(value == nil ? .regular : .semibold))
                .foregroundStyle(value == nil ? Color.textSecondary : Color.textPrimary)
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, Spacing.m)
        .frame(minHeight: 48)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.control))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.control)
                .strokeBorder(.borderStrong, lineWidth: value == nil ? 0 : 1.5)
        }
    }
}

/// Pílulas que quebram linha quando não cabem (nomes longos, fonte grande).
private struct FlowChips<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option?
    let title: (Option) -> String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.xs) { chips }
            VStack(alignment: .leading, spacing: Spacing.xs) { chips }
        }
    }

    private var chips: some View {
        ForEach(options, id: \.self) { option in
            ChoiceChip(title: title(option), isSelected: selection == option) {
                selection = selection == option ? nil : option
            }
        }
    }
}

/// Escolha da modalidade; tocar volta para os filtros.
private struct SportFilterPicker: View {
    @Environment(\.dismiss) private var dismiss
    let sports: [Sport]
    @Binding var selection: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.s) {
                row(title: "Todas as modalidades", symbol: "square.grid.2x2", value: nil)
                ForEach(sports, id: \.name) { sport in
                    row(title: sport.name, symbol: sport.symbol, value: sport.name)
                }
            }
            .padding(Spacing.l)
        }
        .background(Color.canvas.ignoresSafeArea())
        .navigationTitle("Modalidade")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(title: String, symbol: String, value: String?) -> some View {
        SelectionRow(title: title, isSelected: selection == value, action: {
            selection = value
            dismiss()
        }) {
            Image(systemName: symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 44, height: 44)
                .background(.appBackground, in: Circle())
        }
    }
}

/// Escolha da atlética com busca; tocar volta para os filtros.
private struct AthleticFilterPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: Athletic.ID?
    @State private var query = ""

    var body: some View {
        AthleticPicker(athletics: MockData.athletics,
                       selectedID: Binding(get: { selection }, set: { selection = $0; dismiss() }),
                       query: $query,
                       label: "Jogos de qual atlética?",
                       allOptionTitle: "Todas as atléticas")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("Atlética")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var filters = ScheduleFilters(gender: .female)
    Color.clear.sheet(isPresented: .constant(true)) {
        ScheduleFilterSheet(matches: MockData.matches, applied: $filters)
            .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
