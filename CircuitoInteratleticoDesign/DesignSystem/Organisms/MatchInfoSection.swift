import SwiftUI

/// Seção com informações gerais da partida (Data, Horário, Etapa, Divisão, Local).
/// O valor é o conteúdo principal (texto primário); o rótulo fica secundário.
/// Em tamanhos de acessibilidade as duas colunas viram uma (HIG: menos colunas).
struct MatchInfoSection: View {
    let match: Match
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let pair = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.m))
            : AnyLayout(HStackLayout(alignment: .top, spacing: Spacing.m))
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Informações")
            VStack(alignment: .leading, spacing: Spacing.m) {
                pair {
                    item("Data", Formatters.fullDay(match.startDate), symbol: "calendar")
                    item("Horário", Formatters.time(match.startDate), symbol: "clock")
                }
                pair {
                    item("Etapa", match.phase, symbol: "point.3.connected.trianglepath.dotted")
                    item("Divisão", match.division.name, symbol: "shield")
                }
                item("Local", match.venue, symbol: "mappin.and.ellipse")
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()
        }
    }

    /// Ícone junto do rótulo, no mesmo tom secundário, para achar a informação de relance.
    private func item(_ label: String, _ value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(label, systemImage: symbol)
                .labelStyle(InfoLabelStyle())
                .font(.footnote)
                .foregroundStyle(.textSecondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .appAppearance) {
    MatchInfoSection(match: MockData.matches[0])
        .padding()
        .background(Color.canvas)
}
