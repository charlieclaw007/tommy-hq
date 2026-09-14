import SwiftUI

/// Letter tile, title, the user's rule, and a check circle. The whole card toggles.
struct PillarCard: View {
    let pillar: Pillar
    let rule: String
    let isOn: Bool
    let isEnabled: Bool
    let action: () -> Void

    init(pillar: Pillar, rule: String, isOn: Bool, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.pillar = pillar
        self.rule = rule
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                LetterTile(letter: pillar.letter)
                VStack(alignment: .leading, spacing: 4) {
                    Text(pillar.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    Text(rule)
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                CheckCircle(isOn: isOn)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(CardBackground(filled: isOn))
            .contentShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .animation(.snappy(duration: 0.25), value: isOn)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityLabel("\(pillar.title). \(rule)")
        .accessibilityValue(isOn ? "Kept" : "Not yet")
        .accessibilityHint(isEnabled ? "Double tap to toggle" : "Read only")
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

#Preview {
    VStack(spacing: 12) {
        PillarCard(pillar: .diet, rule: Pillar.diet.defaultRule, isOn: false) {}
        PillarCard(pillar: .gym, rule: Pillar.gym.defaultRule, isOn: true) {}
        PillarCard(pillar: .sleep, rule: Pillar.sleep.defaultRule, isOn: false, isEnabled: false) {}
    }
    .padding()
    .background(Theme.cream)
}
