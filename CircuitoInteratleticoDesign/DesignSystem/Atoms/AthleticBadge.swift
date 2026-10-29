import SwiftUI

/// Escudo circular da atlética (SF Symbol genérico até existir a identidade visual).
/// `isUndefined` mostra a vaga "a definir" com borda tracejada; `isFavorite`
/// desenha o anel branco da atlética de coração; `ringColor` contorna o círculo
/// na cor da atlética (perfil).
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
    /// Fundo do círculo; o padrão é a superfície interna.
    var fill: Color = .surfaceInset
    var isUndefined = false
    var isFavorite = false
    /// Contorno na cor da atlética (ex.: cabeçalho do perfil).
    var ringColor: Color? = nil

    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        let diameter = size.diameter * min(scale, 1.25)
        Image(systemName: isUndefined ? "questionmark" : "shield")
            .font(.system(size: diameter * (isUndefined ? 0.35 : 0.45), weight: .medium))
            .foregroundStyle(isUndefined ? Color.textTertiary : Color.textPrimary)
            .frame(width: diameter, height: diameter)
            .background {
                if isUndefined {
                    Circle().strokeBorder(.textTertiary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                } else {
                    Circle().fill(fill)
                        .overlay { Circle().strokeBorder(ringColor ?? .separatorLine, lineWidth: ringColor == nil ? 1 : 3) }
                }
            }
            .overlay {
                if isFavorite && !isUndefined {
                    Circle().strokeBorder(.favoriteAccent, lineWidth: 2).padding(-3)
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview("Tamanhos", traits: .appAppearance) {
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
