import SwiftUI

/// The same four toggles for a chosen day. Days older than two weeks are read-only.
struct DayCorrectionSheet: View {
    @Environment(HabitStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let day: RhythmDay
    let onToggle: (Pillar) -> Void

    private var dateLabel: String {
        day.date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Eyebrow(text: day.isToday ? Copy.todayEyebrow : dateLabel)
                    Text(day.isToday ? Copy.checkInHeadline : Copy.correctionHeadline)
                        .font(Theme.headline)
                        .foregroundStyle(Theme.ink)
                        .padding(.bottom, 8)

                    if !day.isEditable {
                        Text(Copy.readOnlyNote)
                            .font(.subheadline)
                            .foregroundStyle(Theme.inkSecondary)
                            .padding(.bottom, 8)
                    }

                    ForEach(Pillar.allCases) { pillar in
                        PillarCard(
                            pillar: pillar,
                            rule: store.rule(for: pillar),
                            isOn: store.isDone(pillar, on: day.date),
                            isEnabled: day.isEditable
                        ) {
                            onToggle(pillar)
                        }
                    }

                    summary
                        .padding(.top, 12)
                }
                .padding(20)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle(day.isToday ? Copy.todayEyebrow : dateLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .tint(Theme.terracotta)
    }

    private var summary: some View {
        let score = store.score(on: day.date)
        let text: String
        if score == Pillar.allCases.count {
            text = Copy.cookieEarnedSubtext
        } else {
            text = "\(score) of \(Pillar.allCases.count) kept. Partial days stay as evidence."
        }
        return Text(text)
            .font(.subheadline)
            .foregroundStyle(Theme.inkSecondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}
