import Foundation

/// Consecutive cookie days, with the guide's repair rule.
///
/// Walk backwards from today. Today counts if it already has a cookie;
/// otherwise the walk starts from yesterday (today is never a miss while it
/// is still in progress). Each cookie day adds 1. A single missed day between
/// cookie days contributes 0 but does not end the walk. Two consecutive
/// missed days end the streak. Partial days (1–3) count as missed here.
struct StreakCalculator {
    var calendar: Calendar = .current

    /// - Parameter cookieDays: normalized (local midnight) dates that earned a cookie.
    func streak(cookieDays: Set<Date>, today: Date) -> Int {
        let todayKey = DayKey.normalize(today, calendar: calendar)
        guard let earliest = cookieDays.min() else { return 0 }

        var cursor = cookieDays.contains(todayKey)
            ? todayKey
            : DayKey.shift(todayKey, by: -1, calendar: calendar)
        var streak = 0
        var missRun = 0

        while cursor >= earliest {
            if cookieDays.contains(cursor) {
                streak += 1
                missRun = 0
            } else {
                missRun += 1
                if missRun >= 2 { break }
            }
            cursor = DayKey.shift(cursor, by: -1, calendar: calendar)
        }
        return streak
    }
}
