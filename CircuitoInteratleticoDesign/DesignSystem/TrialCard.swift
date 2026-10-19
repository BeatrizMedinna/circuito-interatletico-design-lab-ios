import SwiftUI

/// Cartão de prova classificatória no cronograma. Não tem "A x B": mostra a
/// liderança (ou quantas atléticas disputam) e a situação da prova.
struct TrialCard: View {
    let competition: Competition

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(competition.title.uppercased())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                Text(status.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(isPartial ? Color.textPrimary : Color.textSecondary)
                    .fixedSize()
            }
            HStack(spacing: Spacing.s) {
                Image(systemName: competition.sport.symbol)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.appBackground, in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(headline)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            if let venue = competition.trial?.venue {
                Label(venue, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, Spacing.s)
        .padding(.horizontal, Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.card)
                .strokeBorder(.borderStrong, style: StrokeStyle(lineWidth: isPartial ? 1.5 : 0, dash: [6, 3]))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Prova, \(competition.title), \(status), \(headline), \(detail)")
    }

    private var isPartial: Bool { competition.trial?.hasPartialResults ?? false }

    private var status: String {
        guard let trial = competition.trial else { return "" }
        return trial.isClosed ? "Encerrada" : trial.hasPartialResults ? "Parcial" : "A iniciar"
    }

    private var leader: RankedResult? {
        guard let trial = competition.trial, case .ranking(let criterion, _, _) = competition.format else { return nil }
        return trial.ranked(by: criterion).first { $0.position == 1 }
    }

    private var headline: String {
        guard let leader else { return "Prova classificatória" }
        let name = leader.result.athleteName ?? leader.result.athletic.name
        return "1º \(name)"
    }

    private var detail: String {
        if let leader, case .ranking(_, let unit, _) = competition.format, let mark = leader.result.mark {
            return [leader.result.athleteName == nil ? nil : leader.result.athletic.name, unit.format(mark)]
                .compactMap { $0 }.joined(separator: " · ")
        }
        return "\(competition.trial?.participants.count ?? 0) atléticas inscritas"
    }
}

#Preview {
    VStack(spacing: Spacing.s) {
        ForEach(MockData.competitions.filter { $0.trial != nil }) { competition in
            TrialCard(competition: competition)
        }
    }
    .padding()
}
