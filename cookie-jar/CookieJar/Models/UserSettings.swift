import Foundation
import SwiftData

/// Single-row settings. The reminder time is stored as hour/minute integers
/// and exposed as `DateComponents` so the rest of the app never sees the split.
@Model
final class UserSettings {
    var dietRule: String
    var gymRule: String
    var phoneRule: String
    var sleepRule: String
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var onboardingComplete: Bool
    var createdAt: Date

    static let defaultReminderHour = 20
    static let defaultReminderMinute = 30

    init(createdAt: Date = .now) {
        self.dietRule = Pillar.diet.defaultRule
        self.gymRule = Pillar.gym.defaultRule
        self.phoneRule = Pillar.phone.defaultRule
        self.sleepRule = Pillar.sleep.defaultRule
        self.reminderEnabled = true
        self.reminderHour = UserSettings.defaultReminderHour
        self.reminderMinute = UserSettings.defaultReminderMinute
        self.onboardingComplete = false
        self.createdAt = createdAt
    }

    var reminderTime: DateComponents {
        get { DateComponents(hour: reminderHour, minute: reminderMinute) }
        set {
            reminderHour = newValue.hour ?? UserSettings.defaultReminderHour
            reminderMinute = newValue.minute ?? UserSettings.defaultReminderMinute
        }
    }

    func rule(for pillar: Pillar) -> String {
        let stored: String
        switch pillar {
        case .diet: stored = dietRule
        case .gym: stored = gymRule
        case .phone: stored = phoneRule
        case .sleep: stored = sleepRule
        }
        let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? pillar.defaultRule : trimmed
    }

    func setRule(_ text: String, for pillar: Pillar) {
        switch pillar {
        case .diet: dietRule = text
        case .gym: gymRule = text
        case .phone: phoneRule = text
        case .sleep: sleepRule = text
        }
    }
}
