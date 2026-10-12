import SwiftData
import SwiftUI

@main
struct MealbitApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(for: Meal.self)
    }
}
