import SwiftUI

/// Pílulas de escolha múltipla com a opção "Todas" no início.
/// "Todas" fica marcada quando nada está escolhido; escolher uma opção a desmarca;
/// tocar em "Todas" limpa a escolha. Layout estável (as pílulas não mudam de lugar).
struct MultiFlowChips<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Set<Option>
    var allTitle = "Todas"
    let title: (Option) -> String

    var body: some View {
        ChipFlowLayout {
            ChoiceChip(title: allTitle, isSelected: selection.isEmpty, keepsWidthStable: true) {
                selection = []
            }
            ForEach(options, id: \.self) { option in
                ChoiceChip(title: title(option), isSelected: selection.contains(option), keepsWidthStable: true) {
                    if selection.contains(option) {
                        selection.remove(option)
                    } else {
                        selection.insert(option)
                    }
                }
            }
        }
    }
}

#Preview(traits: .appAppearance) {
    @Previewable @State var selection: Set<String> = ["Série Ouro"]
    MultiFlowChips(options: ["Série Ouro", "Série Prata", "Série Bronze"], selection: $selection) { $0 }
        .padding()
}
