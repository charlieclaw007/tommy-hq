# Cookie Jar (iOS, V1)

Four daily promises. One honest check-in. A cookie only when all four are kept.

This folder is a self-contained Xcode project. Open `CookieJar.xcodeproj`
with Xcode 16 or later, pick an iPhone simulator, and run. There are no
package dependencies, no accounts, and no network access.

## What's here

| Area | Where |
| --- | --- |
| App entry, SwiftData container | `CookieJar/CookieJarApp.swift` |
| Data model (`DayLog`, `UserSettings`, `Pillar`) | `CookieJar/Models/` |
| Derived logic (streak with repair, rhythm window, reminder planning) | `CookieJar/Services/` |
| Single source of truth for the UI | `CookieJar/ViewModels/HabitStore.swift` |
| Today screen, jar + drop animation, pillar cards | `CookieJar/Views/Today/` |
| Two-week rhythm grid and correction sheet | `CookieJar/Views/Rhythm/` |
| Onboarding (3 steps), Settings, About | `CookieJar/Views/Onboarding/`, `CookieJar/Views/Settings/` |
| Design tokens, shared components, all copy | `CookieJar/Design/` |
| Fonts (Fraunces, OFL) and asset catalog | `CookieJar/Resources/` |
| Unit tests | `CookieJarTests/` |
| App Store listing, privacy policy, screenshot plan | `AppStore/`, `privacy/` |

## Running the tests

In Xcode: select the `CookieJar` scheme and press ⌘U. From the terminal:

```
xcodebuild test -project CookieJar.xcodeproj -scheme CookieJar \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The tests cover the streak rules (including `cookie / miss / cookie = 2` and
`cookie / miss / miss = 0`), instant saves, the fourth-toggle outcome, the
14-day editable window, midnight rollover, reminder suppression on cookie
days, onboarding persistence, and reset.

## Before shipping

- Set your team in Signing & Capabilities. The bundle id is
  `com.tjcsolutions.cookiejar`; change it there if you want a different owner.
- The app icon in `Resources/Assets.xcassets/AppIcon.appiconset` is a
  generated placeholder in the app's palette. Replace it with final art.
- Host `privacy/index.html` somewhere public and paste the URL into App Store
  Connect. If this repository deploys as a static site, the file is served at
  `/cookie-jar/privacy/`.
- Walk the acceptance checklist in `AppStore/acceptance.md` on an iPhone SE
  and an iPhone Pro Max simulator.

## Notes on a few decisions

- **Fonts.** Fraunces Bold and Black are bundled and registered at launch
  with CoreText, so the generated Info.plist stays untouched. If registration
  fails the app falls back to the system serif design.
- **Reminder time** is stored as hour and minute integers and exposed as
  `DateComponents`, which keeps SwiftData's storage simple.
- **Reminder suppression.** iOS cannot cancel a local notification at fire
  time, so the app schedules one date-specific reminder per day for the next
  two weeks and rebuilds that set whenever today's cookie status, the
  settings, or the foreground state changes.
- **The disclaimer** from the field guide appears verbatim in About and in
  the listing copy, even though it mentions weight loss, which the rest of the
  app avoids. The brief asks for it verbatim.
