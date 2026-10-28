import SwiftUI

/// Rótulo de informação com ícone pequeno à esquerda (Data, Horário, Local…).
/// O ícone acompanha o Dynamic Type e não é lido pelo VoiceOver (o texto já diz).
struct InfoLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.xxs) {
            configuration.icon
                .imageScale(.small)
                .accessibilityHidden(true)
            configuration.title
        }
    }
}
