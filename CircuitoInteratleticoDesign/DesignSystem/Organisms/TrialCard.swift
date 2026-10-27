import SwiftUI

/// Cartão de prova classificatória no cronograma. Não tem "A x B": mostra a
/// liderança (ou quantas atléticas disputam) e a situação da prova.
struct TrialCard: View {
    let competition: Competition
    /// O cronograma já mostra o horário (`.none`); a agenda da atlética mostra dia e hora.
    var date: Formatters.CardDate = .none
    var showsVenue = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            // Em tamanhos de acessibilidade a situação sobe e o cabeçalho não é cortado.
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    statusLabel
                    headerText.fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    headerText.lineLimit(2)
                    Spacer(minLength: 0)
                    statusLabel
                }
            }
            HStack(spacing: Spacing.s) {
                Image(systemName: competition.sport.symbol)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(.surfaceInset, in: Circle())
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
            if showsVenue, let venue = competition.trial?.venue {
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
        .cardSurface()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Prova, \(competition.title), \(status), \(headline), \(detail)")
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var headerText: some View {
        Text(Formatters.cardHeader(start: competition.trial?.startDate ?? .now, title: competition.title, date: date))
            .font(.caption.weight(.semibold))
            .tracking(0.3)
            .foregroundStyle(.textSecondary)
    }

    private var statusLabel: some View {
        Label {
            Text(status.uppercased())
        } icon: {
            if isPartial { Image(systemName: "exclamationmark.triangle.fill") }
        }
        .labelStyle(.titleAndIcon)
        .font(.eyebrow)
        .tracking(0.6)
        .foregroundStyle(statusColor)
        .fixedSize()
    }

    private var isPartial: Bool { competition.trial?.hasPartialResults ?? false }

    /// Parcial em amarelo de atenção (com ícone); encerrada apagada; a iniciar em cinza.
    private var statusColor: Color {
        if isPartial { return .warning }
        return competition.trial?.isClosed == true ? .textTertiary : .textSecondary
    }

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

#Preview(traits: .appAppearance) {
    VStack(spacing: Spacing.s) {
        ForEach(MockData.competitions.filter { $0.trial != nil }) { competition in
            TrialCard(competition: competition)
        }
    }
    .padding()
}
