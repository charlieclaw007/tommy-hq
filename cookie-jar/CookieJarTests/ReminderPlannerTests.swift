import XCTest
@testable import CookieJar

final class ReminderPlannerTests: XCTestCase {
    private let calendar = TestSupport.calendar

    private func plan(enabled: Bool = true, skipToday: Bool = false) -> ReminderPlan {
        ReminderPlan(enabled: enabled, hour: 20, minute: 30, skipToday: skipToday, today: TestSupport.today)
    }

    func testDisabledPlanProducesNothing() {
        XCTAssertTrue(ReminderPlanner.requests(for: plan(enabled: false), now: TestSupport.today, calendar: calendar).isEmpty)
    }

    func testOnePerDayAcrossTheHorizon() {
        let requests = ReminderPlanner.requests(for: plan(), now: TestSupport.today, calendar: calendar)
        XCTAssertEqual(requests.count, 14)
        XCTAssertEqual(requests.first?.identifier, "cookiejar.reminder.2026-09-14")
        XCTAssertEqual(requests.first?.fireComponents.hour, 20)
        XCTAssertEqual(requests.first?.fireComponents.minute, 30)
        XCTAssertEqual(Set(requests.map(\.identifier)).count, 14, "identifiers are unique per day")
    }

    func testTodayIsSkippedWhenCookieAlreadyEarned() {
        let requests = ReminderPlanner.requests(for: plan(skipToday: true), now: TestSupport.today, calendar: calendar)
        XCTAssertEqual(requests.count, 13)
        XCTAssertEqual(requests.first?.identifier, "cookiejar.reminder.2026-09-15")
    }

    func testPastTimeTodayIsSkipped() {
        let lateEvening = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: TestSupport.today)!
        let requests = ReminderPlanner.requests(for: plan(), now: lateEvening, calendar: calendar)
        XCTAssertEqual(requests.count, 13)
        XCTAssertEqual(requests.first?.identifier, "cookiejar.reminder.2026-09-15")
    }

    func testCopyRotatesThroughTheSet() {
        let requests = ReminderPlanner.requests(for: plan(), now: TestSupport.today, calendar: calendar)
        let bodies = requests.map(\.body)
        XCTAssertEqual(Set(bodies).count, ReminderPlanner.bodies.count)
        XCTAssertNotEqual(bodies[0], bodies[1])
        for body in bodies {
            XCTAssertTrue(ReminderPlanner.bodies.contains(body))
        }
    }

    func testCopyToneHasNoShameWords() {
        for body in ReminderPlanner.bodies {
            let lower = body.lowercased()
            for banned in ["fail", "broke", "ruin", "weight", "calorie"] {
                XCTAssertFalse(lower.contains(banned), "\"\(body)\" contains \"\(banned)\"")
            }
        }
    }
}
