import SwiftUI

/// Tela 17 — Filtros de Modalidades: Categoria e Divisão, com rascunho
/// (✕ descarta, ✓ aplica, "Limpar" zera) e contagem do resultado.
struct SportsFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let competitions: [Competition]
    @Binding var applied: SportsFilters
    @State private var draft: SportsFilters

    init(competitions: [Competition], applied: Binding<SportsFilters>) {
        self.competitions = competitions
        _applied = applied
        _draft = State(initialValue: applied.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    field("Categoria") {
                        MultiFlowChips(options: [Gender.male, .female, .mixed].filter { gender in
                            competitions.contains { $0.sport.gender == gender }
                        }, selection: $draft.genders) { $0.label }
                    }
                    field("Divisão") {
                        MultiFlowChips(options: MockData.divisions.map(\.id), selection: $draft.divisionIDs) { id in
                            MockData.divisions.first { $0.id == id }?.name ?? ""
                        }
                    }
                }
                .padding(Spacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    } label: { Image(systemName: "checkmark") }
                        .accessibilityLabel("Aplicar filtros")
                        .barPrimaryAction()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .sensoryFeedback(.selection, trigger: draft)
    }

    private var footer: some View {
        let count = competitions.filter(draft.includes).count
        return VStack(spacing: Spacing.xs) {
            Text(count == 0 ? "Nenhuma modalidade com esses filtros"
                 : count == 1 ? "1 modalidade" : "\(count) modalidades")
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .contentTransition(.numericText())
                .animation(.snappy, value: count)
            Button {
                withAnimation { draft = SportsFilters() }
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
    @Previewable @State var filters = SportsFilters()
    Color.clear.sheet(isPresented: .constant(true)) {
        SportsFilterSheet(competitions: MockData.competitions, applied: $filters)
    }
}
