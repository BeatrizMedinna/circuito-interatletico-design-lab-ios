import SwiftUI

/// Cor da atlética (definida no cadastro). Só acento decorativo: nunca carrega
/// informação sozinha nem fica atrás de texto, então não depende de contraste.
extension Athletic {
    var brandColor: Color {
        let value = UInt64(colorHex, radix: 16) ?? 0x8A8F98
        return Color(red: Double((value >> 16) & 0xFF) / 255,
                     green: Double((value >> 8) & 0xFF) / 255,
                     blue: Double(value & 0xFF) / 255)
    }
}
