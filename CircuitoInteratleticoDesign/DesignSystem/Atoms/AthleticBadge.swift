import SwiftUI

/// Escudo circular da atlética. Na média fidelidade é um SF Symbol genérico;
/// na alta fidelidade receberá a identidade visual da atlética.
/// `isUndefined` mostra a vaga "a definir" com borda tracejada.
struct AthleticBadge: View {
    enum Size {
        case small, medium, prominent, large

        var diameter: CGFloat {
            switch self {
            case .small: 32
            case .medium: 44
            case .prominent: 60
            case .large: 80
            }
        }
    }

    var size: Size = .medium
    /// Branco sobre superfícies cinza; cinza sobre fundo branco.
    var fill: Color = .appBackground
    var isUndefined = false

    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        let diameter = size.diameter * min(scale, 1.25)
        Image(systemName: isUndefined ? "questionmark" : "shield")
            .font(.system(size: diameter * (isUndefined ? 0.35 : 0.45), weight: .medium))
            .foregroundStyle(isUndefined ? Color.textSecondary : Color.textPrimary)
            .frame(width: diameter, height: diameter)
            .background {
                if isUndefined {
                    Circle().strokeBorder(.textSecondary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                } else {
                    Circle().fill(fill)
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview("Tamanhos") {
    HStack(spacing: Spacing.m) {
        AthleticBadge(size: .small)
        AthleticBadge(size: .medium)
        AthleticBadge(size: .prominent)
        AthleticBadge(size: .large)
        AthleticBadge(size: .prominent, isUndefined: true)
    }
    .padding()
    .background(.surface)
}
