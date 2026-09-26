import Foundation

/// Every user-facing string. Warm, plain, no shame. A missed day is
/// information. Returning is the skill.
enum Copy {
    static let appName = "Cookie Jar"

    // MARK: Today
    static let todayEyebrow = "Today"
    static let todayHeadline = "Make today count."
    static let cookiesEarnedLabel = "cookies earned"
    static let streakLabel = "day streak"
    static func cookieEarnedSubtext(score: Int, total: Int) -> String {
        score >= total
            ? "All four kept. Cookie earned."
            : "\(score) of \(total) kept. Cookie earned."
    }

    static func progressSubtext(checked: Int, total: Int, target: Int) -> String {
        target >= total
            ? "\(checked) of \(total) habits checked — finish the set to earn a cookie."
            : "\(checked) of \(total) habits checked — keep \(target) to earn a cookie."
    }

    // MARK: Cookie target
    static let targetEyebrow = "To earn a cookie"
    static let targetHeadline = "How many make a good day?"
    static let targetBody = "Start where you can be consistent and raise it when it feels steady. A change applies from today on; past days keep the target they were scored against."
    static let settingsTarget = "Cookie target"

    // MARK: Check-in
    static let checkInEyebrow = "Daily check-in"
    static let checkInHeadline = "How did it go?"
    static let correctionHeadline = "Make a correction"
    static let readOnlyNote = "This day is older than two weeks, so it stays as it was."

    // MARK: Rhythm
    static let rhythmEyebrow = "The last two weeks"
    static let rhythmHeadline = "Your rhythm"
    static let rhythmLegend = "Good day"
    static let rhythmHelper = "Tap any day to check in or make a correction."

    // MARK: Onboarding
    static let ideaEyebrow = "The idea"
    static let ideaHeadline = "Four promises. One honest check-in."
    static let ideaSubhead = "Earn a cookie when you keep all four."
    static let ideaBody = """
    The Cookie Jar is a behavior tracker, a reflection tool, and a way to collect proof that you can follow through.

    Choose one clear standard for each pillar: Diet, Gym, Phone, and Sleep. At the end of the day, mark what you completed. Complete all four and you earn one cookie.

    The cookie is not food, punishment, or a measure of worth. It is a visible record of a day when your actions matched your plan.
    """
    static let ideaButton = "Set my rules"

    static let rulesEyebrow = "Your rules"
    static let rulesHeadline = "Today counts when I…"
    static let rulesBody = "One action per pillar that you can honestly mark yes or no without debating yourself at night."
    static let goodRuleTest = "Specific · Controllable · Realistic · Safe"
    static let rulesButton = "Continue"

    static let reminderEyebrow = "Reminder"
    static let reminderHeadline = "One short check-in each evening."
    static let reminderBody = "Pick a time when the day is mostly done. You can change it later in Settings."
    static let reminderToggle = "Daily reminder"
    static let reminderTimeLabel = "Time"
    static let reminderButton = "Continue"

    // MARK: Settings
    static let settingsTitle = "Settings"
    static let settingsRules = "Your rules"
    static let settingsRulesFooter = "Today counts when I… Keep each rule specific, controllable, realistic, and safe."
    static let settingsReminder = "Daily reminder"
    static let settingsReminderFooter = "The reminder is skipped on any day that already has a cookie."
    static let settingsAbout = "About the Cookie Jar"
    static let settingsReset = "Reset all data"
    static let settingsResetTitle = "Reset all data?"
    static let settingsResetMessage = "This removes every check-in and returns your rules to the defaults. It can't be undone."
    static let settingsResetConfirm = "Reset"
    static let settingsVersion = "Version"
    static let notificationsDenied = "Notifications are off for Cookie Jar in iOS Settings. Turn them on there to get the reminder."

    // MARK: About
    static let aboutTitle = "About the Cookie Jar"
    static let aboutStartHere = """
    The Cookie Jar is a behavior tracker, a reflection tool, and a way to collect proof that you can follow through.

    Choose one clear standard for each pillar: Diet, Gym, Phone, and Sleep. At the end of the day, mark what you completed. Complete all four and you earn one cookie.

    The cookie is not food, punishment, or a measure of worth. It is a visible record of a day when your actions matched your plan. The real reward: every mark becomes evidence for the identity, “I am a person who keeps promises to myself.”
    """
    static let aboutWhyItWorks = """
    Tracking makes a goal harder to ignore. What gets recorded can be reviewed, and what gets reviewed can be adjusted. The Cookie Jar uses a simple feedback loop: choose a specific action, record whether it happened, see the result, and adjust the next day's plan.

    Habits become more automatic when a behavior is repeated in a consistent context. One missed day is not a reset. Resume at the next cue instead of declaring the streak ruined.

    A cookie is feedback, not the finish line. The system works best when the cookie points back to identity and competence: “I did what I said I would do.”
    """
    static let aboutStreaks = """
    A single missed day between two cookie days does not end your streak. Two missed days in a row do. Partial days are kept as evidence, not erased.

    A missed day is information. Returning is the skill.
    """
    static let aboutOrigin = """
    The name borrows the “cookie jar” idea David Goggins describes in Can't Hurt Me (2018): a mental inventory of hard things survived. This app is a daily adaptation inspired by that idea, not his original method. Its mechanics come from research on self-monitoring, habit formation, planning, and feedback.
    """
    /// Verbatim from the field guide. Do not edit.
    static let disclaimer = """
    Important: This guide is educational and is not medical, nutritional, psychological, or fitness advice. It does not diagnose or treat any condition and does not promise weight loss, health improvements, or mental-health outcomes. If tracking increases guilt, anxiety, compulsive behavior, or disordered eating, pause and seek qualified support.
    """
    static let aboutPrivacy = "Cookie Jar stores everything on this device. No account, no server, no analytics."
}
