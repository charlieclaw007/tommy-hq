import Foundation

/// Visual state of a day in the Rhythm grid, derived from the score and the
/// cookie target that was in effect for that day.
enum DayState: Equatable {
    /// Score reached the day's target — a cookie day.
    case cookie
    /// Some promises kept, but below the target. Kept evidence, no cookie.
    case partial(score: Int)
    /// 0 of 4, or no log at all.
    case empty

    init(score: Int, target: Int = CookieTarget.max) {
        let target = CookieTarget.clamp(target)
        if score <= 0 {
            self = .empty
        } else if score >= target {
            self = .cookie
        } else {
            self = .partial(score: score)
        }
    }

    var isCookie: Bool {
        if case .cookie = self { return true }
        return false
    }
}

/// A single cell of the two-week Rhythm grid.
struct RhythmDay: Identifiable, Equatable {
    let date: Date
    let weekdayInitial: String
    let dayNumber: Int
    let state: DayState
    let isToday: Bool
    let isEditable: Bool

    var id: Date { date }
}

/// How many of the four promises must be kept for the day to earn a cookie.
/// The user chooses this; it starts at all four. Each `DayLog` stores the
/// target it was scored against, so raising the bar never takes a cookie
/// away from a past day.
enum CookieTarget {
    static let min = 2
    static let max = Pillar.allCases.count
    static let `default` = max
    static let options: [Int] = Array(min...max)

    static func clamp(_ value: Int) -> Int {
        Swift.min(Swift.max(value, min), max)
    }

    static func label(_ value: Int) -> String {
        value >= max ? "All \(max)" : "\(value) of \(max)"
    }
}
