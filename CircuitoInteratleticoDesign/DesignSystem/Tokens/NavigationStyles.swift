import SwiftUI

// Controles das barras superiores (navegação e sheets) sobre Liquid Glass.
// Regra da HIG (Toolbars, Color › Liquid Glass): barras monocromáticas; a cor
// fica só para a ação principal. No app, o Lime aparece na aba selecionada e
// na ação principal de uma sheet (ex.: aplicar filtros). O botão Voltar já é
// o padrão do sistema e não precisa de ajuste.

extension View {
    /// Fechar, cancelar ou ação secundária da barra ("Ler todas"): branco,
    /// como o padrão do iOS 26, em vez do Lime herdado do tint do app.
    func barControlNeutral() -> some View {
        tint(.textPrimary)
    }

    /// Ação principal da barra (ex.: ✓ "Aplicar filtros"): vidro preenchido
    /// em Lime com o símbolo em On Lime (12,6:1). Usar uma vez por barra.
    func barPrimaryAction() -> some View {
        buttonStyle(.glassProminent)
            .tint(.actionPrimary)
            .foregroundStyle(.textOnAccent)
    }
}
