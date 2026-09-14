import SwiftData
import XCTest
@testable import CookieJar

@MainActor
final class HabitStoreTests: XCTestCase {
    private var store: HabitStore!
    private var container: ModelContainer!
    private var scheduler: RecordingScheduler!

    override func setUp() async throws {
        let made = try TestSupport.makeStore()
        store = made.0
        container = made.1
        scheduler = made.2
    }

    override func tearDown() async throws {
        store = nil
        container = nil
        scheduler = nil
    }

    private func earnCookie(on date: Date) {
        for pillar in Pillar.allCases where !store.isDone(pillar, on: date) {
            store.toggle(pillar, on: date)
        }
    }

    func testFreshStoreHasNoLogsAndDefaultSettings() {
        XCTAssertEqual(store.logs.count, 0)
        XCTAssertEqual(store.cookiesEarned, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertFalse(store.settings.onboardingComplete)
        XCTAssertEqual(store.rule(for: .diet), Pillar.diet.defaultRule)
    }

    func testToggleSavesAndOnlyOneRowPerDay() {
        store.toggle(.diet, on: TestSupport.today)
        store.toggle(.gym, on: TestSupport.today)
        XCTAssertEqual(store.logs.count, 1)
        XCTAssertEqual(store.todayScore, 2)
        XCTAssertTrue(store.isDone(.diet, on: TestSupport.today))
        XCTAssertFalse(store.isDone(.phone, on: TestSupport.today))

        // A second store on the same container sees the same data (persisted).
        let second = HabitStore(context: container.mainContext, calendar: TestSupport.calendar,
                                now: TestSupport.today, scheduler: nil)
        XCTAssertEqual(second.todayScore, 2)
    }

    func testFourthToggleTodayReportsCookieExactlyOnce() {
        XCTAssertEqual(store.toggle(.diet, on: TestSupport.today), .changed)
        XCTAssertEqual(store.toggle(.gym, on: TestSupport.today), .changed)
        XCTAssertEqual(store.toggle(.phone, on: TestSupport.today), .changed)
        XCTAssertEqual(store.toggle(.sleep, on: TestSupport.today), .earnedCookieToday)
        XCTAssertTrue(store.todayHasCookie)
        XCTAssertEqual(store.cookiesEarned, 1)
        XCTAssertEqual(store.streak, 1)

        // Un-toggling removes the cookie and recalculates.
        XCTAssertEqual(store.toggle(.sleep, on: TestSupport.today), .lostCookie)
        XCTAssertEqual(store.cookiesEarned, 0)
        XCTAssertEqual(store.streak, 0)

        // Re-toggling earns it again (a new fourth toggle, a new drop).
        XCTAssertEqual(store.toggle(.sleep, on: TestSupport.today), .earnedCookieToday)
    }

    func testFourthToggleOnPastDayDoesNotReportTodayCookie() {
        let yesterday = TestSupport.day(-1)
        for pillar in [Pillar.diet, .gym, .phone] {
            XCTAssertEqual(store.toggle(pillar, on: yesterday), .changed)
        }
        XCTAssertEqual(store.toggle(.sleep, on: yesterday), .changed)
        XCTAssertEqual(store.cookiesEarned, 1)
        XCTAssertEqual(store.streak, 1)
    }

    func testStreakRepairThroughTheStore() {
        earnCookie(on: TestSupport.day(-2))
        earnCookie(on: TestSupport.today)
        XCTAssertEqual(store.streak, 2, "cookie / miss / cookie = 2")

        // Partial evidence on the missed day still counts as missed.
        store.toggle(.diet, on: TestSupport.day(-1))
        XCTAssertEqual(store.streak, 2)
    }

    func testEditableWindowIsFourteenDays() {
        XCTAssertTrue(store.isEditable(TestSupport.today))
        XCTAssertTrue(store.isEditable(TestSupport.day(-13)))
        XCTAssertFalse(store.isEditable(TestSupport.day(-14)))
        XCTAssertFalse(store.isEditable(TestSupport.day(1)))
        XCTAssertEqual(store.toggle(.diet, on: TestSupport.day(-14)), .ignored)
        XCTAssertEqual(store.logs.count, 0)
    }

    func testRhythmDaysEndOnTodayWithStates() {
        earnCookie(on: TestSupport.day(-1))
        store.toggle(.gym, on: TestSupport.day(-3))
        let days = store.rhythmDays
        XCTAssertEqual(days.count, 14)
        XCTAssertEqual(days.last?.date, TestSupport.todayKey)
        XCTAssertTrue(days.last!.isToday)
        XCTAssertEqual(days.filter(\.isToday).count, 1)
        XCTAssertEqual(days[12].state, .cookie)
        XCTAssertEqual(days[10].state, .partial(score: 1))
        XCTAssertEqual(days[0].state, .empty)
        XCTAssertTrue(days.allSatisfy(\.isEditable))
    }

    func testCrossingMidnightStartsAnEmptyDay() {
        earnCookie(on: TestSupport.today)
        XCTAssertTrue(store.todayHasCookie)

        let tomorrowMorning = TestSupport.calendar.date(byAdding: .hour, value: 10, to: TestSupport.today)!
        store.refreshToday(now: tomorrowMorning)
        XCTAssertEqual(store.today, TestSupport.day(1))
        XCTAssertEqual(store.todayScore, 0)
        XCTAssertFalse(store.todayHasCookie)
        XCTAssertEqual(store.streak, 1, "yesterday's cookie keeps the streak alive")
        XCTAssertEqual(store.rhythmDays.last?.date, TestSupport.day(1))
    }

    func testOnboardingPersistsRulesAndReminder() {
        store.completeOnboarding(
            rules: [.diet: "Packed lunch", .gym: "Walked 20 minutes"],
            reminderEnabled: true, hour: 21, minute: 15)
        XCTAssertTrue(store.settings.onboardingComplete)
        XCTAssertEqual(store.rule(for: .diet), "Packed lunch")
        XCTAssertEqual(store.rule(for: .gym), "Walked 20 minutes")
        XCTAssertEqual(store.rule(for: .phone), Pillar.phone.defaultRule)
        XCTAssertEqual(store.settings.reminderTime, DateComponents(hour: 21, minute: 15))
        XCTAssertEqual(scheduler.plans.last?.hour, 21)
        XCTAssertEqual(scheduler.plans.last?.skipToday, false)

        let second = HabitStore(context: container.mainContext, calendar: TestSupport.calendar,
                                now: TestSupport.today, scheduler: nil)
        XCTAssertTrue(second.settings.onboardingComplete)
        XCTAssertEqual(second.rule(for: .diet), "Packed lunch")
    }

    func testReminderSkipsTodayOnceCookieIsEarned() {
        store.completeOnboarding(rules: [:], reminderEnabled: true, hour: 20, minute: 30)
        earnCookie(on: TestSupport.today)
        XCTAssertEqual(scheduler.plans.last?.skipToday, true)

        store.toggle(.diet, on: TestSupport.today)
        XCTAssertEqual(scheduler.plans.last?.skipToday, false)
    }

    func testRemindersAreNotScheduledBeforeOnboarding() {
        store.rescheduleReminders()
        XCTAssertTrue(scheduler.plans.isEmpty)
    }

    func testResetClearsEverythingAndReturnsToOnboarding() {
        store.completeOnboarding(rules: [.sleep: "Lights out by 11"], reminderEnabled: true, hour: 20, minute: 30)
        earnCookie(on: TestSupport.today)
        earnCookie(on: TestSupport.day(-1))
        XCTAssertEqual(store.cookiesEarned, 2)

        store.resetAllData()
        XCTAssertEqual(store.logs.count, 0)
        XCTAssertEqual(store.cookiesEarned, 0)
        XCTAssertEqual(store.streak, 0)
        XCTAssertFalse(store.settings.onboardingComplete)
        XCTAssertEqual(store.rule(for: .sleep), Pillar.sleep.defaultRule)
        XCTAssertEqual(scheduler.plans.last?.enabled, false)

        let settingsCount = (try? container.mainContext.fetchCount(FetchDescriptor<UserSettings>())) ?? -1
        XCTAssertEqual(settingsCount, 1, "exactly one settings row after reset")
    }
}
