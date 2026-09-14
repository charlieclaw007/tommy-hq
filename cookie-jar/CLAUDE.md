# Cookie Jar — project notes for Claude Code

Native iOS habit tracker. Four daily promises (Diet, Gym, Phone, Sleep), one
honest evening check-in, a cookie only when all four are kept. V1 is
single-player and fully offline.

Source of truth for rules, tone, and streak behavior: the field guide PDF
("The Cookie Jar"). The build brief is `BRIEF.md` in this folder.

## Fixed decisions

- SwiftUI, iOS 17+, iPhone only, portrait only, light mode only.
- SwiftData for persistence. Local only. No network calls anywhere.
- UserNotifications for the daily reminder.
- No third-party dependencies. No SPM packages. No Lottie.
- One target (`CookieJar`) plus one unit-test target (`CookieJarTests`).
- Bundle id `com.tjcsolutions.cookiejar` (change in the target build settings if needed).

## Layout

```
CookieJar/
  CookieJarApp.swift        app entry, ModelContainer, day-change + foreground hooks
  Models/                   Pillar, DayLog, UserSettings, DayState/RhythmDay
  ViewModels/HabitStore     the only thing views talk to; derives cookies/streak/rhythm
  Services/                 StreakCalculator, ReminderPlanner (pure), NotificationService,
                            DayKey (date math), HapticService, FontRegistrar
  Views/Today               TodayView, JarView (drop animation), CookieSprite, PillarCard
  Views/Rhythm              RhythmGridView, DayCorrectionSheet
  Views/Onboarding          three-step first launch
  Views/Settings            SettingsView, AboutView
  Design/                   Theme (colors, fonts), Components, Copy (all strings)
  Resources/                Assets.xcassets, Fonts/ (Fraunces, OFL)
CookieJarTests/             XCTest; streak rules, store behavior, reminders, dates
```

The Xcode project uses Xcode 16 file-system-synchronized groups: adding a
file to a folder adds it to the target. No need to edit `project.pbxproj`.

## Rules that must hold

- Everything user-facing is derived from `DayLog` rows. Never persist streaks
  or cookie totals.
- Dates are normalized to local midnight via `DayKey.normalize`. One `DayLog`
  per day (`@Attribute(.unique)`).
- Streak: walk back from today (today counts only if it already has a cookie);
  one missed day between cookie days is repaired; two consecutive misses end it.
  Partial days count as missed. See `StreakCalculator` and its tests.
- The drop animation and haptic play only when the fourth pillar is toggled on
  for today, and only once per fourth toggle. `HabitStore.toggle` returns
  `.earnedCookieToday` exactly in that case.
- Days older than 14 days are read-only (`HabitStore.isEditable`).
- Reminder is skipped on a day that already has a cookie. Because local
  notifications cannot be cancelled at fire time, `NotificationService`
  schedules a rolling 14-day window and rebuilds it on every relevant change.

## Copy and tone

All strings live in `Design/Copy.swift`. Warm, plain, no shame. Never
"failed", "broke", "ruined". No calorie, weight, or appearance language.
Exception: the field guide's educational disclaimer is included verbatim in
About and in the App Store listing, and must not be edited.

## Testing

Run the `CookieJar` scheme's tests (`⌘U`) or:

```
xcodebuild test -project CookieJar.xcodeproj -scheme CookieJar \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Tests use an in-memory `ModelContainer` and a fixed calendar
(America/New_York, 2026-09-14). Keep the streak tests green when touching
`StreakCalculator` or `HabitStore`.
