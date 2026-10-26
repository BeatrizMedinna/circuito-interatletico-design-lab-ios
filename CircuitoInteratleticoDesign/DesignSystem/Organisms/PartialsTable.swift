import SwiftUI

/// Tabela de pontos por período. Ao vivo, a coluna do período atual fica destacada.
/// Com fonte muito grande, a tabela passa a rolar na horizontal.
struct PartialsTable: View {
    let match: Match
    @ScaledMetric(relativeTo: .body) private var cellWidth: CGFloat = 40
    @Environment(\.favoriteAthleticID) private var favoriteAthleticID

    var body: some View {
        ViewThatFits(in: .horizontal) {
            table
            ScrollView(.horizontal) { table }
        }
    }

    private var table: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(maxWidth: .infinity, minHeight: 36)
                ForEach(match.periods, id: \.number) { period in
                    cell("\(period.number)º", period: period.number, isHeader: true)
                }
            }
            .accessibilityHidden(true)
            Rectangle().fill(Color.separatorLine).frame(height: 1)
            row(.a)
            Rectangle().fill(Color.separatorLine).frame(height: 1)
            row(.b)
        }
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.control))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.control)
                .strokeBorder(Color.separatorLine, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.control))
    }

    private func row(_ side: MatchSide) -> some View {
        let team = match.team(side)
        return HStack(spacing: 0) {
            HStack(spacing: Spacing.xs) {
                AthleticBadge(size: .small, isUndefined: team == nil,
                              isFavorite: team != nil && team?.id == favoriteAthleticID)
                Text(team?.name ?? "A definir")
                    .font(.subheadline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, Spacing.xs)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            ForEach(match.periods, id: \.number) { period in
                cell(String(side == .a ? period.a : period.b), period: period.number, isHeader: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel(side, team: team))
    }

    private func cell(_ text: String, period: Int, isHeader: Bool) -> some View {
        let isCurrent = match.status == .live && period == match.currentPeriod
        return Text(text)
            .font(isHeader || isCurrent ? .subheadline.weight(.semibold) : .subheadline)
            .monospacedDigit()
            .foregroundStyle(.textPrimary)
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
