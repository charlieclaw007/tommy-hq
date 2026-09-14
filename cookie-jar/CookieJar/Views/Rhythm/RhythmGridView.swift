import SwiftUI

/// Two rows of seven days, oldest first, ending on today (bottom-right).
struct RhythmGridView: View {
    let days: [RhythmDay]
    let onSelect: (RhythmDay) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: Copy.rhythmEyebrow)
            HStack(alignment: .firstTextBaseline) {
                Text(Copy.rhythmHeadline)
                    .font(Theme.headline)
                    .foregroundStyle(Theme.ink)
                Spacer()
                HStack(spacing: 6) {
                    DayDot(state: .cookie)
                    Text(Copy.rhythmLegend)
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
                .accessibilityElement(children: .combine)
            }
            .padding(.bottom, 8)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days) { day in
                    DayCell(day: day)
                        .onTapGesture {
                            HapticService.tap()
                            onSelect(day)
                        }
                }
            }

            Text(Copy.rhythmHelper)
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        }
    }
}

/// Weekday initial, day number, state dot. Today gets an outlined card.
struct DayCell: View {
    let day: RhythmDay

    var body: some View {
        VStack(spacing: 10) {
            Text(day.weekdayInitial)
                .font(.caption.weight(.semibold))
                .tracking(1)
                .foregroundStyle(Theme.inkSecondary)
            Text("\(day.dayNumber)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .monospacedDigit()
            DayDot(state: day.state)
                .animation(.snappy(duration: 0.25), value: day.state)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            if day.isToday {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Theme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.ink, lineWidth: 1.5))
                    .shadow(color: Theme.ink.opacity(0.85), radius: 0, x: 2.5, y: 2.5)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityText: String {
        let state: String
        switch day.state {
        case .cookie: state = "cookie earned"
        case .partial(let score): state = "\(score) of 4 kept"
        case .empty: state = "no check-in"
        }
        return "\(day.isToday ? "Today, " : "")\(day.weekdayInitial) \(day.dayNumber), \(state)"
    }
}

/// The state dot: filled amber for a cookie, a thin ring with a small
/// centre for a partial day, a faint ring when empty.
struct DayDot: View {
    let state: DayState

    var body: some View {
        ZStack {
            switch state {
            case .cookie:
                Circle().fill(Theme.amber)
                Circle().stroke(Theme.amberDark, lineWidth: 1.5)
            case .partial(let score):
                Circle().stroke(Theme.amber, lineWidth: 1.5)
                Circle()
                    .fill(Theme.amber.opacity(0.9))
                    .frame(width: 2 + CGFloat(score) * 1.6, height: 2 + CGFloat(score) * 1.6)
            case .empty:
                Circle().stroke(Theme.border, lineWidth: 1.5)
            }
        }
        .frame(width: 13, height: 13)
        .accessibilityHidden(true)
    }
}
