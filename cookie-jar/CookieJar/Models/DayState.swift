import Foundation

/// Visual state of a day in the Rhythm grid, derived purely from the score.
enum DayState: Equatable {
    /// 4 of 4 — a cookie day.
    case cookie
    /// 1–3 of 4 — kept evidence, but no cookie.
    case partial(score: Int)
    /// 0 of 4, or no log at all.
    case empty

    init(score: Int) {
        switch score {
        case 4...: self = .cookie
        case 1...3: self = .partial(score: score)
        default: self = .empty
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
