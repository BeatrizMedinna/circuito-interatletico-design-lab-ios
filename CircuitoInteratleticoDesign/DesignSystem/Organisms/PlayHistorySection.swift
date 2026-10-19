import SwiftUI

/// Lances por período, do mais recente para o mais antigo.
struct PlayHistorySection: View {
    let match: Match
    @State private var selectedPeriod: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Histórico")
            if match.plays.isEmpty {
                InlineNote(systemImage: "list.bullet",
                           text: match.status == .live
                                ? "Nenhum lance registrado ainda."
                                : "Os lances desta partida não foram registrados.")
            } else {
                if periods.count > 1 {
                    UnderlineTabs(items: periods, selection: periodBinding) { match.sport.periodLabel($0) }
                }
                let plays = match.plays.filter { $0.period == periodBinding.wrappedValue }.reversed()
                if plays.isEmpty {
                    InlineNote(systemImage: "list.bullet", text: "Nenhum lance registrado neste período.")
                } else {
                    VStack(spacing: 1) {
                        ForEach(Array(plays)) { play in
                            PlayRow(play: play, match: match)
                        }
                    }
                    .background(Color.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                }
            }
        }
    }

    private var periods: [Int] {
        let numbers = match.periods.map(\.number)
        return numbers.isEmpty ? Array(Set(match.plays.map(\.period))).sorted() : numbers
    }

    /// Começa no período atual (ao vivo) ou no último (encerrado).
    private var periodBinding: Binding<Int> {
        Binding {
            selectedPeriod ?? match.currentPeriod ?? periods.last ?? 1
        } set: {
            selectedPeriod = $0
        }
    }
}

#Preview {
    PlayHistorySection(match: MockData.matches[0])
        .padding()
        .background(Color.canvas)
}
