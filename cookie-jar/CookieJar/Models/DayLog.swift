import Foundation
import SwiftData

/// One row per local calendar day. Everything user-facing (cookies, streak,
/// rhythm grid) is derived from these rows; nothing else is stored.
@Model
final class DayLog {
    /// Normalized to local midnight. Unique per day.
    @Attribute(.unique) var date: Date
    var diet: Bool
    var gym: Bool
    var phone: Bool
    var sleep: Bool
    /// The cookie target in effect when this day was scored (2–4). Stored per
    /// day so a later change of the setting never rewrites history. The
    /// default keeps rows created before this field existed at "all four".
    var cookieTarget: Int = 4

    init(date: Date, diet: Bool = false, gym: Bool = false, phone: Bool = false, sleep: Bool = false,
         cookieTarget: Int = CookieTarget.default, calendar: Calendar = .current) {
        self.date = DayKey.normalize(date, calendar: calendar)
        self.diet = diet
        self.gym = gym
        self.phone = phone
        self.sleep = sleep
        self.cookieTarget = CookieTarget.clamp(cookieTarget)
    }

    /// Enough promises kept to reach this day's target.
    var cookieEarned: Bool { score >= CookieTarget.clamp(cookieTarget) }

    /// Number of promises kept today, 0–4.
    var score: Int {
        [diet, gym, phone, sleep].reduce(0) { $0 + ($1 ? 1 : 0) }
    }

    var state: DayState { DayState(score: score, target: cookieTarget) }

    func isDone(_ pillar: Pillar) -> Bool {
        switch pillar {
        case .diet: return diet
        case .gym: return gym
        case .phone: return phone
        case .sleep: return sleep
        }
    }

    func set(_ pillar: Pillar, to value: Bool) {
        switch pillar {
        case .diet: diet = value
        case .gym: gym = value
        case .phone: phone = value
        case .sleep: sleep = value
        }
    }
}
