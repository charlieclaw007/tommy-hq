import SwiftUI

/// Onboarding until it is complete, then Today.
struct RootView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()
            if store.settings.onboardingComplete {
                TodayView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: store.settings.onboardingComplete)
    }
}
