import SwiftUI

/// Ação principal da tela (ex.: "Entrar"). Ocupa a largura disponível.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, Spacing.m)
            .foregroundStyle(isEnabled ? Color.textOnAccent : Color.disabledText)
            .background(isEnabled ? Color.actionPrimary : Color.disabledFill,
                        in: RoundedRectangle(cornerRadius: Radius.control))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

/// Ação secundária com contorno (ex.: "Tentar novamente", "Limpar").
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, Spacing.l)
            .frame(minHeight: 44)
            .background(.surfaceInset, in: RoundedRectangle(cornerRadius: Radius.control))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.control)
                    .strokeBorder(.borderStrong, lineWidth: 1.5)
            }
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// Cartões tocáveis: leve redução e transparência ao pressionar.
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Link de seção ("Ver mais", "Ver todos"): Lime com chevron, para ler como tocável.
struct SectionLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 2) {
            configuration.label
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .accessibilityHidden(true)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.brandPrimary)
        .opacity(configuration.isPressed ? 0.6 : 1)
        .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == SectionLinkStyle {
    static var sectionLink: SectionLinkStyle { SectionLinkStyle() }
}

extension ButtonStyle where Self == PressableCardStyle {
    static var pressableCard: PressableCardStyle { PressableCardStyle() }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.m) {
        Button("Entrar") {}.buttonStyle(.primary)
        Button("Entrar") {}.buttonStyle(.primary).disabled(true)
        Button("Tentar novamente") {}.buttonStyle(.secondary)
    }
    .padding()
}
