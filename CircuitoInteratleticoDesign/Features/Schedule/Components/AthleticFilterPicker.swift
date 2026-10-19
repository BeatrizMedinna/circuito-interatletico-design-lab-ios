import SwiftUI

/// Escolha da atlética com busca para o filtro do cronograma; tocar volta para os filtros.
struct AthleticFilterPicker: View {
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
    NavigationStack {
        AthleticFilterPicker(selection: .constant(nil))
    }
}
