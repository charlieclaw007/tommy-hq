# V1 acceptance checklist

Run on an iPhone SE (3rd gen) simulator and an iPhone 16 Pro Max simulator.

- [ ] Fresh install shows onboarding once; rules and reminder persist after relaunch
- [ ] Toggling pillars saves instantly and survives force-quit
- [ ] Fourth toggle on today plays the drop animation and haptic exactly once
- [ ] Un-toggling removes the cookie and recalculates counts
- [ ] Streak repair rule works: cookie / miss / cookie = 2-day streak; cookie / miss / miss = 0 (covered by `StreakCalculatorTests`, verify visually with the correction sheet)
- [ ] Rhythm grid ends on today, shows correct states, past-day correction sheet works, >14 days is read-only
- [ ] Date boundary uses local midnight; crossing midnight starts a new empty day (simulator: change the device date, background and foreground the app)
- [ ] Reminder fires at chosen time and is suppressed when today already has a cookie (check Settings → Notifications scheduling with a time a minute ahead)
- [ ] Reset clears everything and returns to onboarding
- [ ] No network calls anywhere in the app (no URLSession usage; grep confirms)
- [ ] Builds clean with no warnings; runs on iPhone SE (small) and iPhone Pro Max layouts
- [ ] Dynamic Type up to Accessibility Large keeps the hero and cards readable
