import SwiftUI

/// Escudo, nome, instituição e números da atlética. Dados ausentes aparecem como "—".
struct AthleticSummaryCard<Action: View>: View {
    let athletic: Athletic
    let entry: RankingEntry?
    let profile: AthleticProfile
    let isFavorite: Bool
    @ViewBuilder var action: Action
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Em tamanhos de acessibilidade, o escudo vai para cima do nome: o nome
        // usa a largura toda e não é cortado (HIG: empilhar em vez de truncar).
        let identity = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.s))
            : AnyLayout(HStackLayout(spacing: Spacing.m))
        VStack(alignment: .leading, spacing: Spacing.m) {
            identity {
                // Contorno na cor da atlética; "Sua atlética" ao lado já marca a de coração.
                AthleticBadge(size: .large, ringColor: athletic.brandColor)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(athletic.name)
                        .font(.title3.bold())
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text(athletic.institution)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if isFavorite {
                        Label("Sua atlética", systemImage: "heart.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.favoriteAccent)
                            .padding(.top, 2)
                    }
                }
            }
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: Spacing.xs) { stats }
                Grid(alignment: .leading, horizontalSpacing: Spacing.m, verticalSpacing: Spacing.s) {
                    GridRow { stat(athletic.division.name, "Divisão"); stat(place, "Lugar") }
                    GridRow { stat(pointsText, "Pontos"); stat(fansText, "Torcedores") }
                }
                // Último recurso (maiores tamanhos): uma linha por número, rótulo à esquerda.
                VStack(alignment: .leading, spacing: Spacing.s) {
                    statRow(athletic.division.name, "Divisão")
                    statRow(place, "Lugar")
                    statRow(pointsText, "Pontos")
                    statRow(fansText, "Torcedores")
                }
            }
            Rectangle().fill(Color.separatorLine).frame(height: 1)
            action
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    @ViewBuilder
    private var stats: some View {
        stat(athletic.division.name, "Divisão")
        stat(place, "Lugar")
        stat(pointsText, "Pontos")
        stat(fansText, "Torcedores")
    }

    private var place: String {
        guard let entry else { return "—" }
        return entry.isTied ? "\(entry.position)º =" : "\(entry.position)º"
    }

    private var pointsText: String {
        entry.map { $0.points.formatted(.number.locale(Locale(identifier: "pt_BR"))) } ?? "—"
    }

    private var fansText: String {
        profile.fanCount.map { $0.formatted(.number.locale(Locale(identifier: "pt_BR"))) } ?? "—"
    }

    private func statRow(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
            Text(value)
                .font(.sportNumber())
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value == "—" ? "sem dados" : value.replacingOccurrences(of: " =", with: ", empatada"))")
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.sportNumber())
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value == "—" ? "sem dados" : value.replacingOccurrences(of: " =", with: ", empatada"))")
    }
}

#Preview(traits: .appAppearance) {
    let athletic = MockData.athletic("ath-bufalos")
    AthleticSummaryCard(athletic: athletic, entry: MockData.rankings[0].entries[1], profile: MockData.profile(for: athletic.id), isFavorite: true) {
        Button("Ação") {}
    }
    .padding()
    .background(Color.canvas)
}
