import Foundation
import Observation
import SwiftData

/// Result of a toggle, so the view can decide whether to celebrate.
enum ToggleOutcome: Equatable {
    /// The fourth promise was just kept for today. Play the drop.
    case earnedCookieToday
    /// A day that had a cookie no longer does. Fade the cookie.
    case lostCookie
    case changed
    /// The day is outside the editable window.
    case ignored
}

/// The single source of truth for the UI. Wraps the SwiftData context and
/// exposes derived values (cookies, streak, rhythm) computed from `DayLog`
/// rows. Nothing derived is ever persisted.
@Observable
@MainActor
final class HabitStore {
    static let rhythmDayCount = 14

    private let context: ModelContext
    private let scheduler: ReminderScheduling?
    let calendar: Calendar

    private(set) var today: Date
    private(set) var settings: UserSettings
    private(set) var logs: [DayLog] = []

    init(context: ModelContext,
         calendar: Calendar = .current,
         now: Date = .now,
         scheduler: ReminderScheduling? = NotificationService.shared) {
        self.context = context
        self.calendar = calendar
        self.scheduler = scheduler
        self.today = DayKey.normalize(now, calendar: calendar)
        self.settings = HabitStore.loadOrCreateSettings(in: context)
        reload()
    }

    // MARK: - Loading

    private static func loadOrCreateSettings(in context: ModelContext) -> UserSettings {
        var descriptor = FetchDescriptor<UserSettings>(sortBy: [SortDescriptor(\.createdAt)])
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let fresh = UserSettings()
        context.insert(fresh)
        try? context.save()
        return fresh
    }

    func reload() {
        let descriptor = FetchDescriptor<DayLog>(sortBy: [SortDescriptor(\.date)])
        logs = (try? context.fetch(descriptor)) ?? []
    }

    /// Re-evaluates "today". Called on foreground and when the calendar day changes.
    func refreshToday(now: Date = .now) {
        let key = DayKey.normalize(now, calendar: calendar)
        if key != today {
            today = key
        }
    }

    // MARK: - Reading

    func log(for date: Date) -> DayLog? {
        let key = DayKey.normalize(date, calendar: calendar)
        return logs.first { $0.date == key }
    }

    func score(on date: Date) -> Int { log(for: date)?.score ?? 0 }

    func isDone(_ pillar: Pillar, on date: Date) -> Bool {
        log(for: date)?.isDone(pillar) ?? false
    }

    var todayScore: Int { score(on: today) }
    var todayHasCookie: Bool { todayScore == Pillar.allCases.count }

    var cookieDays: Set<Date> { Set(logs.filter(\.cookieEarned).map(\.date)) }

    var cookiesEarned: Int { logs.reduce(0) { $0 + ($1.cookieEarned ? 1 : 0) } }

    var streak: Int {
        StreakCalculator(calendar: calendar).streak(cookieDays: cookieDays, today: today)
    }

    /// Fourteen days, oldest first, ending on today.
    var rhythmDays: [RhythmDay] {
        DayKey.window(endingOn: today, count: HabitStore.rhythmDayCount, calendar: calendar).map { day in
            RhythmDay(
                date: day,
                weekdayInitial: DayKey.weekdayInitial(for: day, calendar: calendar),
                dayNumber: DayKey.dayNumber(for: day, calendar: calendar),
                state: DayState(score: score(on: day)),
                isToday: day == today,
                isEditable: isEditable(day))
        }
    }

    /// Editable: today or one of the 13 days before it. Older days are read-only.
    func isEditable(_ date: Date) -> Bool {
        let key = DayKey.normalize(date, calendar: calendar)
        let oldest = DayKey.shift(today, by: -(HabitStore.rhythmDayCount - 1), calendar: calendar)
        return key >= oldest && key <= today
    }

    func rule(for pillar: Pillar) -> String { settings.rule(for: pillar) }

    // MARK: - Writing

    @discardableResult
    func toggle(_ pillar: Pillar, on date: Date) -> ToggleOutcome {
        let key = DayKey.normalize(date, calendar: calendar)
        guard isEditable(key) else { return .ignored }

        let log = fetchOrCreateLog(for: key)
        let hadCookie = log.cookieEarned
        log.set(pillar, to: !log.isDone(pillar))
        let hasCookie = log.cookieEarned
        persist()

        let outcome: ToggleOutcome
        if !hadCookie && hasCookie && key == today {
            outcome = .earnedCookieToday
        } else if hadCookie && !hasCookie {
            outcome = .lostCookie
        } else {
            outcome = .changed
        }
        if key == today && hadCookie != hasCookie {
            rescheduleReminders()
        }
        return outcome
    }

    func updateRule(_ text: String, for pillar: Pillar) {
        settings.setRule(text, for: pillar)
        persist()
    }

    func setReminder(enabled: Bool, hour: Int, minute: Int) {
        settings.reminderEnabled = enabled
        settings.reminderHour = hour
        settings.reminderMinute = minute
        persist()
        rescheduleReminders()
    }

    func completeOnboarding(rules: [Pillar: String], reminderEnabled: Bool, hour: Int, minute: Int) {
        for pillar in Pillar.allCases {
            settings.setRule(rules[pillar] ?? pillar.defaultRule, for: pillar)
        }
        settings.reminderEnabled = reminderEnabled
        settings.reminderHour = hour
        settings.reminderMinute = minute
        settings.onboardingComplete = true
        persist()
        rescheduleReminders()
    }

    /// Deletes every log and returns settings to defaults (onboarding shows again).
    func resetAllData() {
        for log in logs {
            context.delete(log)
        }
        context.delete(settings)
        let fresh = UserSettings()
        context.insert(fresh)
        settings = fresh
        persist()
        scheduler?.apply(ReminderPlan(enabled: false, hour: 0, minute: 0, skipToday: false, today: today))
    }

    /// Rebuilds the rolling reminder window from current settings.
    func rescheduleReminders() {
        guard settings.onboardingComplete else { return }
        let plan = ReminderPlan(
            enabled: settings.reminderEnabled,
            hour: settings.reminderHour,
            minute: settings.reminderMinute,
            skipToday: todayHasCookie,
            today: today)
        scheduler?.apply(plan)
    }

    // MARK: - Private

    private func fetchOrCreateLog(for key: Date) -> DayLog {
        if let existing = log(for: key) { return existing }
        let target = key
        var descriptor = FetchDescriptor<DayLog>(predicate: #Predicate<DayLog> { $0.date == target })
        descriptor.fetchLimit = 1
        if let stored = try? context.fetch(descriptor).first {
            return stored
        }
        let created = DayLog(date: key, calendar: calendar)
        context.insert(created)
        return created
    }

    private func persist() {
        do {
            try context.save()
        } catch {
            assertionFailure("Save failed: \(error)")
        }
        reload()
    }
}
