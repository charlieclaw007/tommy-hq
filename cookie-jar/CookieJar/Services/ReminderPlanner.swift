import Foundation

/// What the reminder should look like for the next stretch of days.
struct ReminderPlan: Equatable {
    var enabled: Bool
    var hour: Int
    var minute: Int
    /// True when today already has a cookie, so today's reminder is dropped.
    var skipToday: Bool
    var today: Date
    var horizonDays: Int = 14
}

/// A concrete, date-specific reminder. Kept framework-free so it can be tested.
struct ReminderRequest: Equatable {
    let identifier: String
    let fireComponents: DateComponents
    let body: String
}

/// Builds the concrete reminder list from a plan. Pure and testable.
enum ReminderPlanner {
    static let identifierPrefix = "cookiejar.reminder."

    /// Rotating copy. Warm, plain, no shame.
    static let bodies: [String] = [
        "How did today go? Four promises, one honest check-in.",
        "Time to fill the jar.",
        "Check in before you close the day.",
        "Four rules. One honest look back.",
        "A quick check-in keeps the evidence honest.",
    ]

    static func requests(for plan: ReminderPlan, now: Date = .now,
                         calendar: Calendar = .current) -> [ReminderRequest] {
        guard plan.enabled else { return [] }
        let todayKey = DayKey.normalize(plan.today, calendar: calendar)
        var result: [ReminderRequest] = []

        for offset in 0..<plan.horizonDays {
            if offset == 0 && plan.skipToday { continue }
            let day = DayKey.shift(todayKey, by: offset, calendar: calendar)
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = plan.hour
            components.minute = plan.minute
            components.second = 0

            // Never schedule something that is already in the past.
            if let fireDate = calendar.date(from: components), fireDate <= now { continue }

            result.append(ReminderRequest(
                identifier: identifier(for: day, calendar: calendar),
                fireComponents: components,
                body: body(for: day, calendar: calendar)))
        }
        return result
    }

    static func identifier(for day: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: day)
        let year = String(format: "%04d", c.year ?? 0)
        let month = String(format: "%02d", c.month ?? 0)
        let dayNumber = String(format: "%02d", c.day ?? 0)
        return "\(identifierPrefix)\(year)-\(month)-\(dayNumber)"
    }

    static func body(for day: Date, calendar: Calendar = .current) -> String {
        let ordinal = calendar.ordinality(of: .day, in: .year, for: day) ?? 0
        return bodies[ordinal % bodies.count]
    }
}
