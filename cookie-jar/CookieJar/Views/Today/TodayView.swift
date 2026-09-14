import SwiftUI

/// Home screen: hero with jar and stats, the daily check-in, and the rhythm grid.
struct TodayView: View {
    @Environment(HabitStore.self) private var store

    @State private var dropTrigger = 0
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var selectedDay: RhythmDay?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    hero
                    SectionDivider()
                    checkIn
                    SectionDivider()
                    RhythmGridView(days: store.rhythmDays) { day in
                        selectedDay = day
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle(Copy.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showSettings = true
                        } label: {
                            Label(Copy.settingsTitle, systemImage: "gearshape")
                        }
                        Button {
                            showAbout = true
                        } label: {
                            Label(Copy.settingsAbout, systemImage: "book")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Theme.card))
                            .overlay(Circle().stroke(Theme.border, lineWidth: 1))
                    }
                    .accessibilityLabel("More")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAbout) {
                NavigationStack {
                    AboutView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") { showAbout = false }
                            }
                        }
                }
            }
            .sheet(item: $selectedDay) { day in
                DayCorrectionSheet(day: day) { pillar in
                    handleToggle(pillar, on: day.date)
                }
            }
        }
        .tint(Theme.terracotta)
    }

    // MARK: Hero

    private var subtext: String {
        store.todayHasCookie
            ? Copy.cookieEarnedSubtext
            : Copy.progressSubtext(checked: store.todayScore, total: Pillar.allCases.count)
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Eyebrow(text: Copy.todayEyebrow)
                Text(Copy.todayHeadline)
                    .font(Theme.hero)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtext)
                    .font(.body)
                    .foregroundStyle(Theme.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)
                    .padding(.top, 4)
                HStack(alignment: .top, spacing: 28) {
                    StatView(value: store.cookiesEarned, label: Copy.cookiesEarnedLabel)
                    StatView(value: store.streak, label: Copy.streakLabel)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            JarView(cookieCount: store.cookiesEarned, dropTrigger: dropTrigger)
                .frame(width: 140)
                .padding(.top, 8)
        }
    }

    // MARK: Check-in

    private var checkIn: some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: Copy.checkInEyebrow)
            Text(Copy.checkInHeadline)
                .font(Theme.headline)
                .foregroundStyle(Theme.ink)
                .padding(.bottom, 8)
            ForEach(Pillar.allCases) { pillar in
                PillarCard(
                    pillar: pillar,
                    rule: store.rule(for: pillar),
                    isOn: store.isDone(pillar, on: store.today)
                ) {
                    handleToggle(pillar, on: store.today)
                }
            }
        }
    }

    // MARK: Actions

    /// Shared by the cards and the correction sheet. The drop plays only when
    /// the fourth promise is kept for *today*, and exactly once per fourth toggle.
    private func handleToggle(_ pillar: Pillar, on date: Date) {
        let key = DayKey.normalize(date, calendar: store.calendar)
        let aboutToEarn = key == store.today
            && store.score(on: key) == Pillar.allCases.count - 1
            && !store.isDone(pillar, on: key)

        // The store mutates synchronously, so the toggle runs inside the
        // transaction. When a cookie is about to land, the numerals and
        // subtext wait until the drop has finished; cards and dots carry
        // their own animations and are unaffected by the delay.
        let animation: Animation = aboutToEarn
            ? .snappy(duration: 0.35).delay(0.45)
            : .snappy(duration: 0.25)

        var outcome: ToggleOutcome = .changed
        withAnimation(animation) {
            outcome = store.toggle(pillar, on: key)
        }

        if outcome == .earnedCookieToday {
            HapticService.success()
            dropTrigger += 1
        }
    }
}

/// Large serif numeral with a small label.
private struct StatView: View {
    let value: Int
    let label: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(value)")
                .font(Theme.statNumeral)
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText(value: Double(value)))
                .monospacedDigit()
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
