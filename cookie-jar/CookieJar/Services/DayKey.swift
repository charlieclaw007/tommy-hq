import Foundation

/// Date helpers. Every stored date is a local-midnight "day key".
enum DayKey {
    static func normalize(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    static func shift(_ day: Date, by days: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: day) ?? day
    }

    /// The `count` consecutive days ending on `today`, oldest first.
    static func window(endingOn today: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        let end = normalize(today, calendar: calendar)
        return (0..<count).reversed().map { shift(end, by: -$0, calendar: calendar) }
    }

    /// Single-letter weekday label ("M", "T", ...).
    static func weekdayInitial(for day: Date, calendar: Calendar = .current) -> String {
        let index = calendar.component(.weekday, from: day) - 1
        let symbols = calendar.veryShortWeekdaySymbols
        guard symbols.indices.contains(index) else { return "" }
        return String(symbols[index].prefix(1)).uppercased()
    }

    static func dayNumber(for day: Date, calendar: Calendar = .current) -> Int {
        calendar.component(.day, from: day)
    }
}
