import Foundation
import SwiftData

enum MealCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack

    var id: Self { self }
    var displayName: String { rawValue.capitalized }

    static func suggested(for date: Date) -> MealCategory {
        switch Calendar.current.component(.hour, from: date) {
        case 4..<11: .breakfast
        case 11..<16: .lunch
        case 16..<21: .dinner
        default: .snack
        }
    }
}

@Model
final class Meal {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: MealCategory
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date

    /// Meals logged on the same calendar day as `day` (today by default).
    static func loggedToday(_ day: Date = .now) -> Predicate<Meal> {
        let startOfToday = Calendar.current.startOfDay(for: day)
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        return #Predicate<Meal> { $0.date >= startOfToday && $0.date < startOfTomorrow }
    }

    convenience init(draft: MealDraft) {
        self.init(
            name: draft.name,
            category: draft.category,
            calories: draft.calories,
            protein: draft.protein,
            carbs: draft.carbs,
            fat: draft.fat
        )
    }

    init(
        name: String,
        category: MealCategory,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
    }
}
