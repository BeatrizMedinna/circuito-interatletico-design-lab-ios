import Foundation

/// Datas e horários sempre em pt-BR e no formato 24h.
enum Formatters {
    private static let locale = Locale(identifier: "pt_BR")

    private static let weekdayDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE, d 'de' MMMM"
        return formatter
    }()

    /// "08:00"
    static func time(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(locale: locale).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }

    /// "Hoje", "Ontem", "Amanhã" ou "qui, 30 de abril".
    static func dayLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Hoje" }
        if calendar.isDateInYesterday(date) { return "Ontem" }
        if calendar.isDateInTomorrow(date) { return "Amanhã" }
        return weekdayDay.string(from: date).replacingOccurrences(of: ".", with: "")
    }

    /// "qui, 30 de abril", mesmo para hoje (usado em "Informações").
    static func fullDay(_ date: Date) -> String {
        weekdayDay.string(from: date).replacingOccurrences(of: ".", with: "")
    }

    /// Quanto da data o cabeçalho do cartão mostra.
    enum CardDate {
        /// "HOJE, 08:00 · FUTSAL FEMININO"
        case dayAndTime
        /// "08:00 · FUTSAL FEMININO" (listas agrupadas por dia)
        case time
        /// "FUTSAL FEMININO" (linha do tempo, que já mostra o horário)
        case none
    }

    static func cardHeader(_ match: Match, date: CardDate = .dayAndTime) -> String {
        let when: String? = switch date {
        case .dayAndTime: "\(dayLabel(match.startDate)), \(time(match.startDate))"
        case .time: time(match.startDate)
        case .none: nil
        }
        return [when, match.sport.title].compactMap { $0 }.joined(separator: " · ").uppercased()
    }

    /// Aba de dia do cronograma: "Hoje" ou "sex, 16 out".
    static func dayTab(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Hoje" }
        return shortDay.string(from: date).replacingOccurrences(of: ".", with: "")
    }

    private static let shortDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "EEE, d MMM"
        return formatter
    }()

    /// "Atualizado há 8 s" / "Atualizado há 3 min".
    static func updatedAgo(since date: Date, now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        if seconds < 60 { return "Atualizado há \(seconds) s" }
        return "Atualizado há \(seconds / 60) min"
    }
}
