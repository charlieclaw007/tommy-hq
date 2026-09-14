import XCTest
@testable import CookieJar

final class DayLogTests: XCTestCase {
    func testScoreAndCookie() {
        let log = DayLog(date: TestSupport.today, calendar: TestSupport.calendar)
        XCTAssertEqual(log.score, 0)
        XCTAssertFalse(log.cookieEarned)
        XCTAssertEqual(log.state, .empty)

        log.set(.diet, to: true)
        log.set(.gym, to: true)
        XCTAssertEqual(log.score, 2)
        XCTAssertEqual(log.state, .partial(score: 2))
        XCTAssertFalse(log.cookieEarned)

        log.set(.phone, to: true)
        log.set(.sleep, to: true)
        XCTAssertEqual(log.score, 4)
        XCTAssertTrue(log.cookieEarned)
        XCTAssertEqual(log.state, .cookie)

        log.set(.sleep, to: false)
        XCTAssertFalse(log.cookieEarned)
    }

    func testDateIsNormalizedToLocalMidnight() {
        let log = DayLog(date: TestSupport.today, calendar: TestSupport.calendar)
        XCTAssertEqual(log.date, TestSupport.todayKey)
    }

    func testDayStateFromScore() {
        XCTAssertEqual(DayState(score: 0), .empty)
        XCTAssertEqual(DayState(score: 1), .partial(score: 1))
        XCTAssertEqual(DayState(score: 3), .partial(score: 3))
        XCTAssertEqual(DayState(score: 4), .cookie)
        XCTAssertTrue(DayState(score: 4).isCookie)
        XCTAssertFalse(DayState(score: 3).isCookie)
    }

    func testPillarDefaults() {
        XCTAssertEqual(Pillar.allCases, [.diet, .gym, .phone, .sleep])
        XCTAssertEqual(Pillar.allCases.map(\.letter), ["D", "G", "P", "S"])
        XCTAssertEqual(Pillar.diet.defaultRule, "Ate the way I intended")
        XCTAssertEqual(Pillar.gym.defaultRule, "Moved my body")
        XCTAssertEqual(Pillar.phone.defaultRule, "Kept screen time in check")
        XCTAssertEqual(Pillar.sleep.defaultRule, "Protected my rest")
    }

    func testUserSettingsDefaultsAndReminderTime() {
        let settings = UserSettings()
        XCTAssertTrue(settings.reminderEnabled)
        XCTAssertFalse(settings.onboardingComplete)
        XCTAssertEqual(settings.reminderTime, DateComponents(hour: 20, minute: 30))
        settings.reminderTime = DateComponents(hour: 7, minute: 5)
        XCTAssertEqual(settings.reminderHour, 7)
        XCTAssertEqual(settings.reminderMinute, 5)

        settings.setRule("   ", for: .gym)
        XCTAssertEqual(settings.rule(for: .gym), Pillar.gym.defaultRule, "blank rules fall back to the default")
        settings.setRule("Walked after lunch", for: .gym)
        XCTAssertEqual(settings.rule(for: .gym), "Walked after lunch")
    }
}
