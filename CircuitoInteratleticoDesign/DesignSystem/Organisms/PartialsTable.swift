import SwiftUI

/// Tabela de pontos por período. Ao vivo, a coluna do período atual fica destacada.
/// Em tamanhos de acessibilidade, a tabela vira vertical: uma linha por período e
/// uma coluna por time, para nenhum período ficar escondido fora da tela.
struct PartialsTable: View {
    let match: Match
    @ScaledMetric(relativeTo: .body) private var cellWidth: CGFloat = 40
    @Environment(\.favoriteAthleticID) private var favoriteAthleticID
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                verticalTable
            } else {
                // Sempre na largura da tela: o nome do time cede espaço (até 2 linhas)
                // e os períodos ficam visíveis. Antes, um nome longo fazia a tabela
                // virar rolagem horizontal com os períodos fora da tela.
                table
            }
        }
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.control))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.control)
                .strokeBorder(Color.separatorLine, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.control))
    }

    // MARK: - Horizontal (padrão)

    private var table: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(maxWidth: .infinity, minHeight: 36)
                ForEach(match.periods, id: \.number) { period in
                    cell("\(period.number)º", period: period.number, isHeader: true)
                }
            }
            .accessibilityHidden(true)
            divider
            row(.a)
            divider
            row(.b)
        }
    }

    private func row(_ side: MatchSide) -> some View {
        let team = match.team(side)
        return HStack(spacing: 0) {
            HStack(spacing: Spacing.xs) {
                badge(team)
                Text(team?.name ?? "A definir")
                    .font(.subheadline)
                    .foregroundStyle(team == nil ? Color.textTertiary : Color.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xs)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            ForEach(match.periods, id: \.number) { period in
                cell(String(side == .a ? period.a : period.b), period: period.number, isHeader: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel(side, team: team))
    }

    private func cell(_ text: String, period: Int, isHeader: Bool) -> some View {
        let isCurrent = isCurrentPeriod(period)
        return Text(text)
            .font(isHeader ? .subheadline.weight(.semibold) : .sportNumber(.subheadline))
            .monospacedDigit()
            .foregroundStyle(isHeader && !isCurrent ? Color.textSecondary : Color.textPrimary)
            .frame(width: cellWidth)
            .frame(maxHeight: .infinity)
            .background(isCurrent ? Color.surfaceSelected : Color.clear)
            .overlay(alignment: .leading) {
                Rectangle().fill(Color.separatorLine).frame(width: 1)
            }
            // Período atual marcado em Lime no cabeçalho.
            .overlay(alignment: .top) {
                if isHeader && isCurrent {
                    Rectangle().fill(.actionPrimary).frame(height: 2)
                }
            }
    }

    // MARK: - Vertical (tamanhos de acessibilidade)

    private var verticalTable: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.s) {
                Color.clear.frame(width: 0, height: 0).frame(maxWidth: .infinity)
                verticalTeamHeader(.a)
                verticalTeamHeader(.b)
            }
            .padding(Spacing.s)
            .accessibilityHidden(true)
            ForEach(match.periods, id: \.number) { period in
                divider
                let isCurrent = isCurrentPeriod(period.number)
                HStack(spacing: Spacing.s) {
                    Text(match.sport.periodLabel(period.number))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isCurrent ? Color.textPrimary : Color.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(String(period.a))
                        .font(.sportNumber(.body))
                        .frame(maxWidth: .infinity)
                    Text(String(period.b))
                        .font(.sportNumber(.body))
                        .frame(maxWidth: .infinity)
                }
                .monospacedDigit()
                .foregroundStyle(.textPrimary)
                .padding(Spacing.s)
                .background(isCurrent ? Color.surfaceSelected : Color.clear)
                .overlay(alignment: .leading) {
                    if isCurrent { Rectangle().fill(.actionPrimary).frame(width: 3) }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(match.sport.periodLabel(period.number)): \(match.teamA?.name ?? "A definir") \(period.a), \(match.teamB?.name ?? "A definir") \(period.b)")
            }
        }
    }

    private func verticalTeamHeader(_ side: MatchSide) -> some View {
        let team = match.team(side)
        return VStack(spacing: Spacing.xxs) {
            badge(team)
            Text(team?.name ?? "A definir")
                .font(.caption.weight(.semibold))
                .foregroundStyle(team == nil ? Color.textTertiary : Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Partes comuns

    private var divider: some View {
        Rectangle().fill(Color.separatorLine).frame(height: 1)
    }

    private func badge(_ team: Athletic?) -> some View {
        AthleticBadge(size: .small, isUndefined: team == nil,
                      isFavorite: team != nil && team?.id == favoriteAthleticID)
    }

    private func isCurrentPeriod(_ period: Int) -> Bool {
        match.status == .live && period == match.currentPeriod
    }

    private func rowAccessibilityLabel(_ side: MatchSide, team: Athletic?) -> String {
        let scores = match.periods.map { period in
            "\(match.sport.periodLabel(period.number)): \(side == .a ? period.a : period.b)"
        }
        return ([team?.name ?? "A definir"] + scores).joined(separator: ", ")
    }
}

#Preview(traits: .appAppearance) {
    PartialsTable(match: MockData.matches[0])
        .padding()
        .background(Color.canvas)
}

#Preview("Texto de acessibilidade", traits: .appAppearance) {
    PartialsTable(match: MockData.matches[0])
        .padding()
        .background(Color.canvas)
        .dynamicTypeSize(.accessibility2)
}
