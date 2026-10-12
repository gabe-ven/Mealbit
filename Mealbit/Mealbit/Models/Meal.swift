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
