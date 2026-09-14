import Combine
import SwiftData
import SwiftUI

@main
struct CookieJarApp: App {
    @Environment(\.scenePhase) private var scenePhase

    private let container: ModelContainer
    @State private var store: HabitStore

    init() {
        FontRegistrar.registerBundledFonts()
        NotificationService.shared.installDelegate()

        let schema = Schema([DayLog.self, UserSettings.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create the local store: \(error)")
        }
        _store = State(initialValue: HabitStore(context: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.light)
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    store.refreshToday()
                    store.reload()
                    store.rescheduleReminders()
                }
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                    store.refreshToday()
                }
        }
        .modelContainer(container)
    }
}
