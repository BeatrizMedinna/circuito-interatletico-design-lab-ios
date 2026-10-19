import SwiftUI

/// Ícone em círculo (sino, filtro). Use como label de botão ou link.
/// `isActive` inverte as cores (ex.: filtros aplicados).
struct CircleIconLabel: View {
    let systemName: String
    var isActive = false

    var body: some View {
        Image(systemName: systemName)
            .font(.body.weight(.semibold))
            .foregroundStyle(isActive ? Color.textOnAccent : Color.textPrimary)
            .frame(width: 44, height: 44)
            .background(isActive ? Color.actionPrimary : Color.surface, in: Circle())
    }
}

#Preview {
    HStack(spacing: Spacing.m) {
        CircleIconLabel(systemName: "bell")
        CircleIconLabel(systemName: "line.3.horizontal.decrease", isActive: true)
    }
    .padding()
}
