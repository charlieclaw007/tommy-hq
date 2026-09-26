import SwiftUI

/// Small caps label in terracotta, wide tracking.
struct Eyebrow: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(.footnote, weight: .bold))
            .tracking(2.2)
            .foregroundStyle(Theme.terracotta)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Tan square with a serif letter, used on pillar cards.
struct LetterTile: View {
    let letter: String

    var body: some View {
        Text(letter)
            .font(Theme.tileLetter)
            .foregroundStyle(Theme.ink)
            .frame(width: 48, height: 48)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.tile))
            .accessibilityHidden(true)
    }
}

/// Circular toggle on the right of a pillar card.
struct CheckCircle: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(isOn ? Theme.amberDark : Theme.border, lineWidth: 2)
            if isOn {
                Circle().fill(Theme.amber)
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 34, height: 34)
        .animation(.snappy(duration: 0.25), value: isOn)
        .accessibilityHidden(true)
    }
}

/// Card chrome shared by pillar cards and the today cell.
struct CardBackground: View {
    var filled: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
            .fill(filled ? Theme.cardOn : Theme.card)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .stroke(Theme.border, lineWidth: 1))
    }
}

/// Primary terracotta button.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.terracotta.opacity(configuration.isPressed ? 0.85 : 1)))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(height: 1)
            .padding(.vertical, 28)
    }
}

/// Segmented choice of how many promises earn a cookie (2, 3, or all 4).
struct CookieTargetPicker: View {
    @Binding var selection: Int

    var body: some View {
        Picker(Copy.settingsTarget, selection: $selection) {
            ForEach(CookieTarget.options, id: \.self) { value in
                Text(CookieTarget.label(value)).tag(value)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel(Copy.settingsTarget)
    }
}
