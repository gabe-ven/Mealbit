import Foundation

/// Storage keys, defaults, and allowed ranges for the user's daily goals.
/// The goals themselves are stored with `@AppStorage`.
enum NutritionGoals {
    static let caloriesKey = "calorieGoal"
    static let proteinKey = "proteinGoal"
    static let hasSetGoalsKey = "hasSetGoals"

    static let defaultCalories = 2000
    static let defaultProtein = 150

    static let calorieRange = 800...6000
    static let proteinRange = 10...400
}
