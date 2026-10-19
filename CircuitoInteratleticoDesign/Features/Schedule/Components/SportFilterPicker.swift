import SwiftUI

/// Escolha da modalidade para o filtro do cronograma; tocar volta para os filtros.
struct SportFilterPicker: View {
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

#Preview {
    NavigationStack {
        SportFilterPicker(
            sports: [
                MockData.futsalMale,
                MockData.swimmingMale
            ],
            selection: .constant(nil)
        )
    }
}
