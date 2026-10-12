import Foundation

/// A meal being considered in the preview. Kept in memory only; it becomes a
/// saved `Meal` when the user taps Log.
struct MealDraft: Hashable {
    var name: String
    var category: MealCategory
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double

    func scaled(by portion: Double) -> MealDraft {
        MealDraft(
            name: name,
            category: category,
            calories: Int((Double(calories) * portion).rounded()),
            protein: protein * portion,
            carbs: carbs * portion,
            fat: fat * portion
        )
    }
}
