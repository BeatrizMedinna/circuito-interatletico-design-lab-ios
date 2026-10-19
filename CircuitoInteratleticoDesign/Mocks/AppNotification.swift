import Foundation

/// Aviso recebido pelo torcedor. Os tipos seguem o wireframe 06; só a mudança
/// de cronograma (horário/local) está prevista no domínio (RN-62).
struct AppNotification: Identifiable, Hashable {
    enum Kind: Hashable {
        case startingSoon, venueChange, timeChange, fanMeter, champion

        var symbol: String {
            switch self {
            case .startingSoon: "flame"
            case .venueChange: "exclamationmark.triangle"
            case .timeChange: "clock.arrow.circlepath"
            case .fanMeter: "chart.bar"
            case .champion: "trophy"
            }
        }
    }

    let id: String
    let kind: Kind
    let title: String
    let message: String
    let date: Date
    /// Partida relacionada; quando existe, tocar no aviso abre a partida.
    var matchID: Match.ID? = nil
    /// Atléticas envolvidas, usadas na aba "Minha atlética".
    let athleticIDs: [Athletic.ID]
}
