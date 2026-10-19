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

    /// Cabeçalho dos cartões: "HOJE, 08:00 · FUTSAL FEMININO" ou, sem o dia, "08:00 · FUTSAL FEMININO".
    static func cardHeader(_ match: Match, includingDay: Bool = true) -> String {
        let when = includingDay ? "\(dayLabel(match.startDate)), \(time(match.startDate))" : time(match.startDate)
        return "\(when) · \(match.sport.title)".uppercased()
    }

    /// "Atualizado há 8 s" / "Atualizado há 3 min".
    static func updatedAgo(since date: Date, now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        if seconds < 60 { return "Atualizado há \(seconds) s" }
        return "Atualizado há \(seconds / 60) min"
    }
}
