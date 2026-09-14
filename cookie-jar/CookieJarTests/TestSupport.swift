import Foundation
import SwiftData
import XCTest
@testable import CookieJar

/// Shared helpers: a fixed calendar, day arithmetic, and an in-memory store.
enum TestSupport {
    static var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/New_York")!
        c.locale = Locale(identifier: "en_US")
        return c
    }

    /// 2026-09-14 14:32 local — a Monday, mid-afternoon.
    static var today: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 14, hour: 14, minute: 32))!
    }

    static var todayKey: Date { calendar.startOfDay(for: today) }

    static func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: todayKey)!
    }

    @MainActor
    static func makeStore(now: Date = today) throws -> (HabitStore, ModelContainer, RecordingScheduler) {
        let schema = Schema([DayLog.self, UserSettings.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let scheduler = RecordingScheduler()
        let store = HabitStore(context: container.mainContext, calendar: calendar, now: now, scheduler: scheduler)
        return (store, container, scheduler)
    }
}

/// Captures reminder plans instead of touching UserNotifications.
final class RecordingScheduler: ReminderScheduling {
    private(set) var plans: [ReminderPlan] = []
    func apply(_ plan: ReminderPlan) { plans.append(plan) }
}
