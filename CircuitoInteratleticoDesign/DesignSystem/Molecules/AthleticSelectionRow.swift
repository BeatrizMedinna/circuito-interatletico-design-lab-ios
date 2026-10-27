import SwiftUI

/// Linha de atlética: escudo, nome e divisão.
struct AthleticSelectionRow: View {
    let athletic: Athletic
    let isSelected: Bool
    var stacksAtAccessibilitySizes = false
    let action: () -> Void

    init(athletic: Athletic, isSelected: Bool, stacksAtAccessibilitySizes: Bool = false, action: @escaping () -> Void) {
        self.athletic = athletic
        self.isSelected = isSelected
        self.stacksAtAccessibilitySizes = stacksAtAccessibilitySizes
        self.action = action
    }

    var body: some View {
        SelectionRow(title: athletic.name, subtitle: athletic.division.name, isSelected: isSelected, action: action,
                     stacksAtAccessibilitySizes: stacksAtAccessibilitySizes) {
            AthleticBadge(size: .medium)
        }
    }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.s) {
        AthleticSelectionRow(athletic: MockData.athletic("ath-bufalos"), isSelected: true, action: {})
        AthleticSelectionRow(athletic: MockData.athletic("ath-engenharia"), isSelected: false, action: {})
    }
    .padding()
}
