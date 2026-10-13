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

extension MealDraft {
    /// Shaped like a photo estimate, for previews until the AI call exists.
    static var sampleEstimate: MealDraft {
        MealDraft(
            name: "Chicken, Rice & Broccoli",
            category: .dinner,
            components: [
                MealComponent(name: "Grilled chicken breast", quantity: 6, unit: "oz", calories: 280, protein: 52, carbs: 0, fat: 6),
                MealComponent(name: "White rice", quantity: 1, unit: "cup", calories: 205, protein: 4, carbs: 45, fat: 0.5),
                MealComponent(name: "Steamed broccoli", quantity: 1.5, unit: "cups", calories: 45, protein: 4, carbs: 9, fat: 0.5),
                MealComponent(name: "Cooking oil", quantity: 1, unit: "tsp", calories: 40, protein: 0, carbs: 0, fat: 4.5),
            ],
            estimateNote: "Assumed about 6 oz chicken, 1 cup rice, and a little oil from cooking."
        )
    }
}
