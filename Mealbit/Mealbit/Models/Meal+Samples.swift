import Foundation
import SwiftData

extension Meal {
    static var samples: [Meal] {
        [
            Meal(name: "Oatmeal with Berries", category: .breakfast, calories: 350, protein: 12, carbs: 60, fat: 7),
            Meal(name: "Chicken Burrito Bowl", category: .lunch, calories: 720, protein: 45, carbs: 80, fat: 22),
            Meal(name: "Greek Yogurt", category: .snack, calories: 150, protein: 15, carbs: 8, fat: 4),
        ]
    }

    @MainActor
    static var previewContainer: ModelContainer {
        let container = try! ModelContainer(
            for: Meal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        for meal in samples {
            container.mainContext.insert(meal)
        }
        return container
    }
}
