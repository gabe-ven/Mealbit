import Combine
import SwiftData
import SwiftUI

@main
struct MealbitApp: App {
    @Environment(\.scenePhase) private var scenePhase
    /// The start of the current day. Home only shows meals from this day, so it is
    /// refreshed at midnight and whenever the app returns to the foreground.
    @State private var today = Calendar.current.startOfDay(for: .now)

    var body: some Scene {
        WindowGroup {
            DashboardView(day: today)
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
                    refreshToday()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { refreshToday() }
                }
        }
        .modelContainer(for: Meal.self)
    }

    private func refreshToday() {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        if startOfDay != today { today = startOfDay }
    }
}
