# Cookie Jar — V1 Build Brief (iOS)

## 1. What we're building

A native iOS habit tracker built around one idea: four daily promises, one honest evening check-in, and a cookie earned only when all four are kept. The cookie is visible proof of a day when actions matched the plan.

V1 is **single-player and fully offline**. No accounts, no server, no payments. The community layer (friends' streaks, comment board) is V2 and must not shape V1 architecture beyond keeping the data model clean.

Reference material:
- Two screenshots of the existing prototype (Today screen, Rhythm grid). Match the look and feel closely.
- "The Cookie Jar" PDF field guide. This is the source of truth for rules, tone, and streak behavior.

## 2. Tech decisions (fixed)

- **SwiftUI**, iOS 17+, iPhone only, portrait only
- **SwiftData** for persistence (local only)
- **UserNotifications** for the daily reminder
- **No third-party dependencies**
- Xcode project, one target, one bundle id: `com.[owner].cookiejar`
- Structure: `Models/`, `Views/`, `ViewModels/`, `Services/`, `Design/`, `Resources/`

## 3. Data model

```
Pillar (enum, fixed order): diet, gym, phone, sleep
  - letter: "D" / "G" / "P" / "S"
  - title: "Diet" / "Gym" / "Phone" / "Sleep"
  - defaultRule:
      diet:  "Ate the way I intended"
      gym:   "Moved my body"
      phone: "Kept screen time in check"
      sleep: "Protected my rest"

DayLog (SwiftData @Model)
  - date: Date (normalized to local midnight, unique)
  - diet, gym, phone, sleep: Bool (default false)
  - computed cookieEarned: all four true
  - computed score: count of true (0–4)

UserSettings (SwiftData @Model, single row)
  - dietRule, gymRule, phoneRule, sleepRule: String (user's own wording, defaults above)
  - reminderEnabled: Bool (default true)
  - reminderTime: DateComponents (default 20:30)
  - onboardingComplete: Bool
  - createdAt: Date
```

Everything user-facing is derived from `DayLog` rows. Do not store streak or cookie totals separately.

## 4. Derived logic

**Cookies earned:** count of `DayLog` where `cookieEarned == true`.

**Streak (consecutive cookie days, with repair):**
- Walk backwards from today. Today counts if it has a cookie; if today has no cookie yet, start from yesterday.
- Each consecutive cookie day adds 1.
- **Repair rule (from the guide):** a single missed day between two cookie days does not break the streak. The missed day contributes 0 but the count continues through it.
- Two consecutive non-cookie days end the streak.
- Days with partial marks (1–3) are "kept evidence" but count as missed for streak purposes.

**Day states for the Rhythm grid:**
- `cookie` — 4/4 (filled amber dot)
- `partial` — 1–3 (dot with thin ring, or small fraction; keep subtle)
- `empty` — 0/4 or no log
- `today` — outlined card as in screenshot, regardless of state

## 5. Screens

### 5.1 Onboarding (first launch only, 3 steps)
1. **The idea** — one screen: "Four promises. One honest check-in. Earn a cookie when you keep all four." Short paragraph from the guide's "Start here" section. Button: *Set my rules*.
2. **Your rules** — one card per pillar with the prompt "Today counts when I…" and a text field prefilled with the default rule. Show the good-rule test as small helper text: *Specific · Controllable · Realistic · Safe*.
3. **Reminder** — time picker (default 8:30 PM), toggle, request notification permission on *Continue*.

Sets `onboardingComplete = true` and lands on Today.

### 5.2 Today (home screen — see screenshot 2)
- Nav title "Cookie Jar", overflow menu (•••) opens Settings.
- Eyebrow label **TODAY** in terracotta caps.
- Headline in bold serif: **"Make today count."**
- Subtext: `"{n} of 4 habits checked — finish the set to earn a cookie."` When 4/4: `"All four kept. Cookie earned."`
- Two stats: **cookies earned** and **day streak** (large serif numerals).
- **Jar illustration** on the right: cream jar with terracotta ridged lid, containing cookies. Show up to ~12 cookie sprites stacked at the bottom, representing cookies earned (cap the visible count, show the number in the stat).
- Divider.
- Eyebrow **DAILY CHECK-IN**, headline **"How did it go?"**
- Four pillar cards: letter tile (serif letter on tan square), title, user's rule as subtitle, circular toggle on the right. Tap anywhere on the card to toggle. Toggled state: filled circle with check, card tint slightly darker.
- Save immediately on toggle (no save button).
- Below the cards: the Rhythm section (5.3) on the same scroll view.

### 5.3 Rhythm (see screenshot 1)
- Eyebrow **THE LAST TWO WEEKS**, headline **"Your rhythm"**, legend "● Good day".
- Two rows of 7 columns, oldest first, ending on today (today is bottom-right). Show weekday initial, day number, state dot.
- Tapping any day opens a sheet for that date with the same four toggles. Editing past days is allowed within these 14 days ("make a correction"). Days older than 14 days are read-only.
- Helper text: "Tap any day to check in or make a correction."

### 5.4 Settings (from ••• menu)
- Edit the four rules
- Reminder toggle + time
- "About the Cookie Jar" (short, from guide; link out to nothing in V1)
- Reset all data (confirmation alert)
- Version number

## 6. The cookie animation (must ship in V1)

When the user toggles the **fourth** pillar on for **today**:
1. Brief haptic (`.success`).
2. A cookie sprite appears just above the jar's mouth, drops into the jar with a spring, lands on the pile with a small bounce and a subtle squash.
3. The cookies-earned and streak numerals tick up.
4. The subtext changes to "All four kept. Cookie earned."

Constraints:
- Pure SwiftUI (`withAnimation`, spring, `matchedGeometryEffect` or offset transitions). No Lottie.
- Duration ~0.8s total. Must not block interaction.
- If the user un-toggles a pillar afterwards, the cookie fades out (no reverse animation needed) and counts recalc.
- Triggering the fourth toggle on a **past** day from the correction sheet does **not** play the animation; the pile just updates.

Cookie sprite: round, amber (#D99A3E-ish), darker outline, two dark chip dots, matches the screenshot.

## 7. Notifications

- One daily local notification at the user's chosen time.
- Copy rotates through a small set, e.g. "How did today go? Four promises, one honest check-in." / "Time to fill the jar." / "Check in before you close the day."
- Skip the notification if today already has a cookie.
- Tapping it opens Today.

## 8. Design system

- **Background:** warm cream (#F3EBDD). Cards: slightly lighter cream with a thin tan border, 20pt radius.
- **Accent:** terracotta (#C0533D) for eyebrows and the lid. Amber (#D99A3E) for cookies and "good day" dots. Ink: near-black brown (#2B2119).
- **Type:** headlines in a heavy slab/serif (use a bundled open-license serif such as *Fraunces* or *Roboto Slab*; fall back to `.serif` design if not bundled). Body and labels in SF Pro. Eyebrows in caps with wide tracking.
- Letter tiles: tan square (#E5D6BC), serif letter in ink.
- Light mode only in V1; respect Dynamic Type up to Accessibility Large.

## 9. Tone and copy rules

- Warm, plain, no shame. Never "failed", "broke", "ruined".
- A missed day is "information". Returning is "the skill".
- No calorie, weight, or appearance language anywhere.
- App Store description and About text derive from the guide's "Start here" and "Why it works" pages. Include the guide's educational disclaimer verbatim in About and in the App Store listing.

## 10. Explicitly out of scope for V1

- Accounts, sign-in, cloud sync
- Friends, shared streaks, community board, comments
- Custom or additional pillars (the four are fixed; only the rule wording is editable)
- Widgets, Apple Watch, iPad, dark mode
- Subscriptions or in-app purchases
- Analytics or any third-party SDK

## 11. App Store prep (do in parallel with the build)

- Confirm the name "Cookie Jar" is available on the App Store; have a fallback ("Cookie Jar: Daily Habits" or similar).
- Privacy nutrition label: **Data not collected**. Ship a one-paragraph privacy policy URL (required even when nothing is collected).
- Screenshots: Today (empty), Today (cookie just landed), Rhythm, Onboarding rules.
- Age rating 4+. Category: Health & Fitness.
- The cookie counter is a motivation symbol, not a health claim; keep the listing consistent with the disclaimer.

## 12. Acceptance checklist

- [ ] Fresh install shows onboarding once; rules and reminder persist after relaunch
- [ ] Toggling pillars saves instantly and survives force-quit
- [ ] Fourth toggle on today plays the drop animation and haptic exactly once
- [ ] Un-toggling removes the cookie and recalculates counts
- [ ] Streak repair rule works: cookie / miss / cookie = 2-day streak; cookie / miss / miss = 0
- [ ] Rhythm grid ends on today, shows correct states, past-day correction sheet works, >14 days is read-only
- [ ] Date boundary uses local midnight; crossing midnight starts a new empty day
- [ ] Reminder fires at chosen time and is suppressed when today already has a cookie
- [ ] Reset clears everything and returns to onboarding
- [ ] No network calls anywhere in the app
- [ ] Builds clean with no warnings; runs on iPhone SE (small) and iPhone Pro Max layouts

## 13. Suggested first prompt for Claude Code

> Read `CLAUDE.md`. Scaffold the Xcode project with the folder structure in section 2, implement the data model and derived logic from sections 3–4 with unit tests for the streak rules, then build the Today screen (5.2) with static placeholder data. Stop and show me before starting the jar animation.

Work in that order: model + tests → Today screen → Rhythm grid → correction sheet → animation → onboarding → settings → notifications → App Store assets.
