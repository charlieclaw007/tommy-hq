import XCTest
@testable import CookieJar

final class DayKeyTests: XCTestCase {
    private let calendar = TestSupport.calendar

    func testNormalizeUsesLocalMidnight() {
        let key = DayKey.normalize(TestSupport.today, calendar: calendar)
        let components = calendar.dateComponents([.hour, .minute, .second], from: key)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testJustBeforeAndAfterMidnightAreDifferentDays() {
        let beforeMidnight = calendar.date(from: DateComponents(year: 2026, month: 9, day: 14, hour: 23, minute: 59, second: 59))!
        let afterMidnight = calendar.date(from: DateComponents(year: 2026, month: 9, day: 15, hour: 0, minute: 0, second: 1))!
        XCTAssertNotEqual(DayKey.normalize(beforeMidnight, calendar: calendar),
                          DayKey.normalize(afterMidnight, calendar: calendar))
        XCTAssertEqual(DayKey.shift(DayKey.normalize(beforeMidnight, calendar: calendar), by: 1, calendar: calendar),
                       DayKey.normalize(afterMidnight, calendar: calendar))
    }

    func testWindowEndsOnTodayOldestFirst() {
        let window = DayKey.window(endingOn: TestSupport.today, count: 14, calendar: calendar)
        XCTAssertEqual(window.count, 14)
        XCTAssertEqual(window.last, TestSupport.todayKey)
        XCTAssertEqual(window.first, TestSupport.day(-13))
        for (a, b) in zip(window, window.dropFirst()) {
            XCTAssertEqual(DayKey.shift(a, by: 1, calendar: calendar), b)
        }
    }

    func testWeekdayInitialsAndDayNumbers() {
        // 2026-09-14 is a Monday.
        XCTAssertEqual(DayKey.weekdayInitial(for: TestSupport.todayKey, calendar: calendar), "M")
        XCTAssertEqual(DayKey.weekdayInitial(for: TestSupport.day(-1), calendar: calendar), "S")
        XCTAssertEqual(DayKey.weekdayInitial(for: TestSupport.day(-6), calendar: calendar), "T")
        XCTAssertEqual(DayKey.dayNumber(for: TestSupport.todayKey, calendar: calendar), 14)
        XCTAssertEqual(DayKey.dayNumber(for: TestSupport.day(-13), calendar: calendar), 1)
    }
}
