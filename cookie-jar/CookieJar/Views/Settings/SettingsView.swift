import SwiftUI

/// Rules, reminder, about, reset, version.
struct SettingsView: View {
    @Environment(HabitStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var reminderEnabled = true
    @State private var reminderTime: Date = .now
    @State private var showResetConfirmation = false
    @State private var showDeniedNotice = false
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(Pillar.allCases) { pillar in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(pillar.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.inkSecondary)
                            TextField(
                                pillar.defaultRule,
                                text: Binding(
                                    get: { storedRule(pillar) },
                                    set: { store.updateRule($0, for: pillar) }),
                                axis: .vertical)
                            .lineLimit(1...3)
                            .foregroundStyle(Theme.ink)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text(Copy.settingsRules)
                } footer: {
                    Text(Copy.settingsRulesFooter)
                }

                Section {
                    CookieTargetPicker(selection: Binding(
                        get: { store.cookieTarget },
                        set: { store.setCookieTarget($0) }))
                    .padding(.vertical, 4)
                } header: {
                    Text(Copy.settingsTarget)
                } footer: {
                    Text(Copy.targetBody)
                }

                Section {
                    Toggle(Copy.reminderToggle, isOn: $reminderEnabled)
                        .tint(Theme.terracotta)
                    if reminderEnabled {
                        DatePicker(
                            Copy.reminderTimeLabel,
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text(Copy.settingsReminder)
                } footer: {
                    Text(showDeniedNotice ? Copy.notificationsDenied : Copy.settingsReminderFooter)
                }

                Section {
                    NavigationLink(Copy.settingsAbout) {
                        AboutView()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text(Copy.settingsReset)
                    }
                }

                Section {
                    LabeledContent(Copy.settingsVersion, value: AppInfo.versionString)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle(Copy.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert(Copy.settingsResetTitle, isPresented: $showResetConfirmation) {
                Button(Copy.settingsResetConfirm, role: .destructive) {
                    store.resetAllData()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(Copy.settingsResetMessage)
            }
            .onAppear(perform: load)
            .onChange(of: reminderEnabled) { _, enabled in
                guard loaded else { return }
                applyReminder(enabled: enabled)
            }
            .onChange(of: reminderTime) { _, _ in
                guard loaded else { return }
                applyReminder(enabled: reminderEnabled)
            }
        }
        .tint(Theme.terracotta)
    }

    // MARK: Helpers

    private func storedRule(_ pillar: Pillar) -> String {
        switch pillar {
        case .diet: return store.settings.dietRule
        case .gym: return store.settings.gymRule
        case .phone: return store.settings.phoneRule
        case .sleep: return store.settings.sleepRule
        }
    }

    private func load() {
        reminderEnabled = store.settings.reminderEnabled
        reminderTime = Calendar.current.date(
            bySettingHour: store.settings.reminderHour,
            minute: store.settings.reminderMinute,
            second: 0, of: .now) ?? .now
        loaded = true
    }

    private func applyReminder(enabled: Bool) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let hour = components.hour ?? UserSettings.defaultReminderHour
        let minute = components.minute ?? UserSettings.defaultReminderMinute

        guard enabled else {
            showDeniedNotice = false
            store.setReminder(enabled: false, hour: hour, minute: minute)
            return
        }

        Task {
            let allowed = await NotificationService.shared.requestAuthorization()
            showDeniedNotice = !allowed
            store.setReminder(enabled: allowed, hour: hour, minute: minute)
            if !allowed {
                reminderEnabled = false
            }
        }
    }
}

enum AppInfo {
    static var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
