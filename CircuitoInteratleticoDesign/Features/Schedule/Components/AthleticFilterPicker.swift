import SwiftUI

/// Escolha das atléticas (uma ou várias) para o filtro do cronograma.
/// Tocar marca ou desmarca; "Todas as atléticas" limpa; Voltar retorna aos filtros.
struct AthleticFilterPicker: View {
    @Binding var selection: Set<Athletic.ID>
    @State private var query = ""

    var body: some View {
        AthleticPicker(athletics: MockData.athletics,
                       selectedIDs: $selection,
                       query: $query,
                       label: "Jogos de quais atléticas?",
                       allOptionTitle: "Todas as atléticas")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("Atléticas")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var selection: Set<Athletic.ID> = ["ath-bufalos"]
    NavigationStack {
        AthleticFilterPicker(selection: $selection)
    }
}
