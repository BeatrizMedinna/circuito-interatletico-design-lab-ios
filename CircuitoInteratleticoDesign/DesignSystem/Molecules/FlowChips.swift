import SwiftUI

/// Pílulas que quebram linha quando não cabem (nomes longos, fonte grande).
struct FlowChips<Option: Hashable>: View {
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

#Preview(traits: .appAppearance) {
    @Previewable @State var selected: String? = "Feminino"
    FlowChips(options: ["Masculino", "Feminino", "Misto"], selection: $selected) { $0 }
        .padding()
}
