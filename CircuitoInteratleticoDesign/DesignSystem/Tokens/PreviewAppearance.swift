import SwiftUI

/// Previews no escuro, como o app (o Canvas ignora o Info.plist).
/// Uso: `#Preview(traits: .appAppearance) { ... }`.
struct AppAppearancePreview: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        content.preferredColorScheme(.dark)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var appAppearance: Self { .modifier(AppAppearancePreview()) }
}
