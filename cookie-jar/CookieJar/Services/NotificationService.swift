import Foundation
import UserNotifications

/// Anything that can turn a `ReminderPlan` into scheduled reminders.
/// The store depends on this protocol so tests can substitute a recorder.
protocol ReminderScheduling: AnyObject {
    func apply(_ plan: ReminderPlan)
}

/// One daily local notification at the user's chosen time. Because a local
/// notification cannot be suppressed at fire time, the service schedules a
/// short rolling window of date-specific reminders and rebuilds it whenever
/// something relevant changes (a toggle, a settings edit, app foreground).
final class NotificationService: NSObject, ReminderScheduling, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    func installDelegate() {
        center.delegate = self
    }

    /// Asks for permission. Returns true when alerts are allowed.
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func apply(_ plan: ReminderPlan) {
        let requests = ReminderPlanner.requests(for: plan)
        Task { [center] in
            let pending = await center.pendingNotificationRequests()
            let ours = pending.map(\.identifier).filter { $0.hasPrefix(ReminderPlanner.identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ours)

            for request in requests {
                let content = UNMutableNotificationContent()
                content.title = "Cookie Jar"
                content.body = request.body
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: request.fireComponents, repeats: false)
                let unRequest = UNNotificationRequest(identifier: request.identifier, content: content, trigger: trigger)
                try? await center.add(unRequest)
            }
        }
    }

    func removeAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // MARK: UNUserNotificationCenterDelegate

    /// Show the reminder even if the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    /// Tapping the reminder simply opens the app, which lands on Today.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
    }
}
