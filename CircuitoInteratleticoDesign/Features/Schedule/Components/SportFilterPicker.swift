import SwiftUI

/// Escolha das modalidades (uma ou várias) para o filtro do cronograma.
/// Tocar marca ou desmarca; "Todas as modalidades" limpa; Voltar retorna aos filtros.
struct SportFilterPicker: View {
    let sports: [Sport]
    @Binding var selection: Set<String>
    @State private var feedbackTrigger = 0

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
        .navigationTitle("Modalidades")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: feedbackTrigger)
    }

    private func row(title: String, symbol: String, value: String?) -> some View {
        let isSelected = value.map(selection.contains) ?? selection.isEmpty
        return SelectionRow(title: title, isSelected: isSelected, action: {
            if let value {
                if selection.contains(value) { selection.remove(value) } else { selection.insert(value) }
            } else {
                selection = []
            }
            feedbackTrigger += 1
        }) {
            Image(systemName: symbol)
                .font(.body.weight(.medium))
                .foregroundStyle(.textPrimary)
                .frame(width: 44, height: 44)
                .background(.surfaceInset, in: Circle())
        }
    }
}

#Preview {
    @Previewable @State var selection: Set<String> = ["Futsal"]
    NavigationStack {
        SportFilterPicker(sports: [MockData.futsalMale, MockData.swimmingMale], selection: $selection)
    }
}
