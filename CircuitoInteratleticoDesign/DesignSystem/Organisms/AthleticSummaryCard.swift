import SwiftUI

/// Escudo, nome, instituição e números da atlética. Dados ausentes aparecem como "—".
struct AthleticSummaryCard<Action: View>: View {
    let athletic: Athletic
    let entry: RankingEntry?
    let profile: AthleticProfile
    let isFavorite: Bool
    @ViewBuilder var action: Action

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                AthleticBadge(size: .large, fill: .surface)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(athletic.name)
                        .font(.title3.bold())
                        .foregroundStyle(.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(athletic.institution)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                    if isFavorite {
                        Label("Sua atlética", systemImage: "heart.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.textPrimary)
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
            }
            Divider()
            action
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground, in: RoundedRectangle(cornerRadius: Radius.card))
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

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
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

#Preview {
    let athletic = MockData.athletic("ath-bufalos")
    AthleticSummaryCard(athletic: athletic, entry: MockData.rankings[0].entries[1], profile: MockData.profile(for: athletic.id), isFavorite: true) {
        Button("Ação") {}
    }
    .padding()
    .background(Color.canvas)
}
