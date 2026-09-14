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

    init(date: Date, diet: Bool = false, gym: Bool = false, phone: Bool = false, sleep: Bool = false,
         calendar: Calendar = .current) {
        self.date = DayKey.normalize(date, calendar: calendar)
        self.diet = diet
        self.gym = gym
        self.phone = phone
        self.sleep = sleep
    }

    /// All four promises kept.
    var cookieEarned: Bool { diet && gym && phone && sleep }

    /// Number of promises kept today, 0–4.
    var score: Int {
        [diet, gym, phone, sleep].reduce(0) { $0 + ($1 ? 1 : 0) }
    }

    var state: DayState { DayState(score: score) }

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
