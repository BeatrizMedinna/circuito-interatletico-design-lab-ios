import SwiftUI

/// Item do cronograma publicado: uma partida ou uma prova (RN-52).
enum ScheduleItem: Identifiable, Hashable {
    case match(Match)
    case trial(Competition)

    var id: String {
        switch self {
        case .match(let match): match.id
        case .trial(let competition): competition.id
        }
    }

    var startDate: Date {
        switch self {
        case .match(let match): match.startDate
        case .trial(let competition): competition.trial?.startDate ?? .distantFuture
        }
    }

    var sport: Sport {
        switch self {
        case .match(let match): match.sport
        case .trial(let competition): competition.sport
        }
    }

    /// Partida ainda não encerrada ou prova ainda aberta.
    var isOpen: Bool {
        switch self {
        case .match(let match): match.status != .finished
        case .trial(let competition): competition.trial?.isClosed == false
        }
    }
}

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

    func includes(_ item: ScheduleItem) -> Bool {
        switch item {
        case .match(let match):
            return includes(match)
        case .trial(let competition):
            let participants = competition.trial?.participants ?? []
            return (sportName == nil || competition.sport.name == sportName)
                && (gender == nil || competition.sport.gender == gender)
                && (athleticID.map { id in participants.contains { $0.id == id } } ?? true)
                && (divisionID == nil || competition.division.id == divisionID)
        }
    }
}

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
                        FlowChips(options: MockData.divisions,
                                  selection: Binding(
                                    get: { MockData.divisions.first { $0.id == draft.divisionID } },
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

    private var resultCount: Int { items.filter(draft.includes).count }

    private var footer: some View {
        VStack(spacing: Spacing.xs) {
            Text(resultCount == 0 ? "Nenhum jogo com esses filtros"
                 : resultCount == 1 ? "1 jogo ou prova no cronograma" : "\(resultCount) jogos e provas no cronograma")
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
        ScheduleFilterSheet(items: MockData.matches.map(ScheduleItem.match), applied: $filters)
            .environment(AppState(favoriteAthletic: MockData.athletic("ath-bufalos"), scenario: .filled, preloaded: true))
    }
}
