import SwiftUI

/// Pílulas que quebram linha quando não cabem (nomes longos, fonte grande).
struct FlowChips<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option?
    /// Layout estável: pílulas com largura fixa (✓ reservado) que quebram linha
    /// uma a uma. Opcional: hoje só os filtros do Cronograma usam; sem a opção,
    /// continua "tudo numa linha ou tudo numa coluna".
    var keepsLayoutStable = false
    let title: (Option) -> String

    init(options: [Option], selection: Binding<Option?>, keepsLayoutStable: Bool = false,
         title: @escaping (Option) -> String) {
        self.options = options
        _selection = selection
        self.keepsLayoutStable = keepsLayoutStable
        self.title = title
    }

    var body: some View {
        if keepsLayoutStable {
            ChipFlowLayout { chips }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.xs) { chips }
                VStack(alignment: .leading, spacing: Spacing.xs) { chips }
            }
        }
    }

    private var chips: some View {
        ForEach(options, id: \.self) { option in
            ChoiceChip(title: title(option), isSelected: selection == option,
                       keepsWidthStable: keepsLayoutStable) {
                selection = selection == option ? nil : option
            }
        }
    }
}

#Preview(traits: .appAppearance) {
    @Previewable @State var selected: String? = "Feminino"
    FlowChips(options: ["Masculino", "Feminino", "Misto"], selection: $selected) { $0 }
        .padding()
}
