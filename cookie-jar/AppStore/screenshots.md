# Screenshot plan

Capture on the 6.9" (iPhone 16 Pro Max) and 6.5" simulators in light mode.
Use the shared `CookieJar` scheme; no special build flags are needed.

| # | Screen | How to reach it | Caption idea |
| --- | --- | --- | --- |
| 1 | Today, empty | Fresh install, finish onboarding, don't toggle anything | "Four promises. One honest check-in." |
| 2 | Today, cookie just landed | Toggle all four; capture within a second of the fourth tap so the cookie is mid-bounce and the subtext reads "All four kept. Cookie earned." | "Keep all four, earn a cookie." |
| 3 | Rhythm | Scroll to "Your rhythm" with a mix of cookie, partial, and empty days (use the correction sheet to fill past days) | "See your rhythm. Fix a day if you need to." |
| 4 | Onboarding, rules | Settings → Reset all data, tap "Set my rules" | "Your rules, in your words." |

Tips
- For screenshot 2, run in the simulator with Debug → Slow Animations to
  catch the landing frame.
- Seed the rhythm grid quickly: tap past days in the grid and toggle all four
  on a few of them, and one or two pillars on others.
- Keep the status bar clean with `xcrun simctl status_bar <device> override --time 9:41 --batteryLevel 100 --cellularBars 4`.
