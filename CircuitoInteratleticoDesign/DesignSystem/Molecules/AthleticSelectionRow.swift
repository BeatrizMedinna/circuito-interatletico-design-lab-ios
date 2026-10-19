import SwiftUI

/// Linha de atlética: escudo, nome e divisão.
struct AthleticSelectionRow: View {
    let athletic: Athletic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectionRow(title: athletic.name, subtitle: athletic.division.name, isSelected: isSelected, action: action) {
            AthleticBadge(size: .medium)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.s) {
        AthleticSelectionRow(athletic: MockData.athletic("ath-bufalos"), isSelected: true, action: {})
        AthleticSelectionRow(athletic: MockData.athletic("ath-engenharia"), isSelected: false, action: {})
    }
    .padding()
}
