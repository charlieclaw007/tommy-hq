import SwiftUI

/// Three steps on first launch: the idea, your rules, the reminder.
struct OnboardingView: View {
    @Environment(HabitStore.self) private var store

    @State private var step = 0
    @State private var rules: [Pillar: String] = Dictionary(
        uniqueKeysWithValues: Pillar.allCases.map { ($0, $0.defaultRule) })
    @State private var cookieTarget = CookieTarget.default
    @State private var reminderEnabled = true
    @State private var reminderTime: Date = OnboardingView.defaultReminderDate
    @State private var isFinishing = false
    @FocusState private var focusedPillar: Pillar?

    private static var defaultReminderDate: Date {
        Calendar.current.date(
            bySettingHour: UserSettings.defaultReminderHour,
            minute: UserSettings.defaultReminderMinute,
            second: 0, of: .now) ?? .now
    }

    var body: some View {
        VStack(spacing: 0) {
            stepIndicator
                .padding(.top, 20)
            ScrollView {
                Group {
                    switch step {
                    case 0: ideaStep
                    case 1: rulesStep
                    default: reminderStep
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
            }
            .scrollDismissesKeyboard(.interactively)
            footer
        }
        .background(Theme.cream.ignoresSafeArea())
        .animation(.snappy(duration: 0.35), value: step)
        .tint(Theme.terracotta)
    }

    // MARK: Steps

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == step ? Theme.terracotta : Theme.border)
                    .frame(width: index == step ? 28 : 10, height: 6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step + 1) of 3")
    }

    private var ideaStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            CookieSprite(diameter: 64)
                .padding(.bottom, 8)
            Eyebrow(text: Copy.ideaEyebrow)
            Text(Copy.ideaHeadline)
                .font(Theme.hero)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(Copy.ideaSubhead)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.terracotta)
            Text(Copy.ideaBody)
                .font(.body)
                .foregroundStyle(Theme.inkSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rulesStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: Copy.rulesEyebrow)
            Text(Copy.rulesHeadline)
                .font(Theme.titleSerif)
                .foregroundStyle(Theme.ink)
            Text(Copy.rulesBody)
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(Pillar.allCases) { pillar in
                RuleCard(
                    pillar: pillar,
                    text: Binding(
                        get: { rules[pillar] ?? pillar.defaultRule },
                        set: { rules[pillar] = $0 }),
                    focus: $focusedPillar)
            }

            Text(Copy.goodRuleTest)
                .font(.footnote.weight(.medium))
                .tracking(0.5)
                .foregroundStyle(Theme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(text: Copy.targetEyebrow)
                Text(Copy.targetHeadline)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                CookieTargetPicker(selection: $cookieTarget)
                Text(Copy.targetBody)
                    .font(.footnote)
                    .foregroundStyle(Theme.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(CardBackground())
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var reminderStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(text: Copy.reminderEyebrow)
            Text(Copy.reminderHeadline)
                .font(Theme.titleSerif)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(Copy.reminderBody)
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                Toggle(isOn: $reminderEnabled) {
                    Text(Copy.reminderToggle)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                }
                .tint(Theme.terracotta)
                .padding(18)

                if reminderEnabled {
                    Divider().padding(.horizontal, 18)
                    DatePicker(
                        Copy.reminderTimeLabel,
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.vertical, 4)
                }
            }
            .background(CardBackground())
            .animation(.snappy(duration: 0.25), value: reminderEnabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Button {
                advance()
            } label: {
                Text(buttonTitle)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isFinishing)

            if step > 0 {
                Button("Back") {
                    step -= 1
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.inkSecondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Theme.cream)
    }

    private var buttonTitle: String {
        switch step {
        case 0: return Copy.ideaButton
        case 1: return Copy.rulesButton
        default: return Copy.reminderButton
        }
    }

    // MARK: Actions

    private func advance() {
        focusedPillar = nil
        if step < 2 {
            step += 1
            return
        }
        finish()
    }

    private func finish() {
        guard !isFinishing else { return }
        isFinishing = true
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let hour = components.hour ?? UserSettings.defaultReminderHour
        let minute = components.minute ?? UserSettings.defaultReminderMinute
        let enabled = reminderEnabled
        let chosenRules = rules
        let target = cookieTarget

        Task {
            var allowed = false
            if enabled {
                allowed = await NotificationService.shared.requestAuthorization()
            }
            store.completeOnboarding(
                rules: chosenRules,
                reminderEnabled: enabled && allowed,
                hour: hour,
                minute: minute,
                cookieTarget: target)
            isFinishing = false
        }
    }
}

/// Prompt + text field for one pillar's rule.
private struct RuleCard: View {
    let pillar: Pillar
    @Binding var text: String
    var focus: FocusState<Pillar?>.Binding

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            LetterTile(letter: pillar.letter)
            VStack(alignment: .leading, spacing: 6) {
                Text(pillar.title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                TextField(pillar.defaultRule, text: $text, axis: .vertical)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink)
                    .focused(focus, equals: pillar)
                    .submitLabel(.done)
                    .lineLimit(1...3)
            }
        }
        .padding(16)
        .background(CardBackground())
        .onTapGesture { focus.wrappedValue = pillar }
    }
}
