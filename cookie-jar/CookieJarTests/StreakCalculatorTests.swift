import XCTest
@testable import CookieJar

final class StreakCalculatorTests: XCTestCase {
    private let calc = StreakCalculator(calendar: TestSupport.calendar)
    private let today = TestSupport.today

    /// Builds a cookie-day set from day offsets relative to today (0 = today, -1 = yesterday).
    private func cookies(_ offsets: [Int]) -> Set<Date> {
        Set(offsets.map { TestSupport.day($0) })
    }

    func testNoCookiesIsZero() {
        XCTAssertEqual(calc.streak(cookieDays: [], today: today), 0)
    }

    func testTodayCookieCountsOne() {
        XCTAssertEqual(calc.streak(cookieDays: cookies([0]), today: today), 1)
    }

    func testTodayNotYetCheckedStartsFromYesterday() {
        XCTAssertEqual(calc.streak(cookieDays: cookies([-1, -2, -3]), today: today), 3)
    }

    func testConsecutiveDaysIncludingToday() {
        XCTAssertEqual(calc.streak(cookieDays: cookies([0, -1, -2, -3, -4]), today: today), 5)
    }

    /// Acceptance: cookie / miss / cookie = 2-day streak.
    func testSingleMissIsRepaired() {
        XCTAssertEqual(calc.streak(cookieDays: cookies([0, -2]), today: today), 2)
    }

    /// Acceptance: cookie / miss / miss = 0.
    func testTwoMissesEndTheStreak() {
        // Yesterday and the day before were missed; today is not yet checked.
        XCTAssertEqual(calc.streak(cookieDays: cookies([-3]), today: today), 0)
        // Same shape with today earned: the walk stops at the two misses.
        XCTAssertEqual(calc.streak(cookieDays: cookies([0, -3]), today: today), 1)
    }

    /// Yesterday missed, today not yet checked: the streak is still alive (return window).
    func testYesterdayMissedTodayPendingKeepsStreakAlive() {
        XCTAssertEqual(calc.streak(cookieDays: cookies([-2, -3]), today: today), 2)
    }

    func testMultipleRepairsAcrossAStreak() {
        // C M C M C (oldest → newest, ending today)
        XCTAssertEqual(calc.streak(cookieDays: cookies([0, -2, -4]), today: today), 3)
    }

    func testRepairAtTheOldEndDoesNotAddDays() {
        // Only cookie days count; the miss contributes 0.
        XCTAssertEqual(calc.streak(cookieDays: cookies([0, -1, -3]), today: today), 3)
    }

    func testOldCookiesFarInThePastDoNotCount() {
        XCTAssertEqual(calc.streak(cookieDays: cookies([-30, -31, -32]), today: today), 0)
    }

    func testUnnormalizedTodayIsNormalized() {
        let lateTonight = TestSupport.calendar.date(byAdding: .hour, value: 9, to: today)!
        XCTAssertEqual(calc.streak(cookieDays: cookies([0, -1]), today: lateTonight), 2)
    }
}
