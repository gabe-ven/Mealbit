import Foundation

/// How a potential meal would change what's left of today's goals, plus a short
/// plain-language explanation built from those numbers. Pure calculation so it
/// updates instantly as the portion changes.
struct GoalFit {
    let caloriesLeftBefore: Int
    let caloriesLeftAfter: Int
    let proteinLeftBefore: Double
    let proteinLeftAfter: Double
    /// What this meal does to today's calories, such as "Fits with 210 cal to spare".
    let headline: String
    /// What it does for protein, or how to make it fit.
    let detail: String

    var exceedsCalorieGoal: Bool { caloriesLeftAfter < 0 }

    init(
        calorieGoal: Int,
        proteinGoal: Int,
        eatenCalories: Int,
        eatenProtein: Double,
        mealCalories: Int,
        mealProtein: Double
    ) {
        caloriesLeftBefore = calorieGoal - eatenCalories
        caloriesLeftAfter = caloriesLeftBefore - mealCalories
        proteinLeftBefore = Double(proteinGoal) - eatenProtein
        proteinLeftAfter = proteinLeftBefore - mealProtein
        headline = Self.headline(leftBefore: caloriesLeftBefore, leftAfter: caloriesLeftAfter, meal: mealCalories)

        let proteinLine = Self.proteinLine(leftBefore: proteinLeftBefore, meal: mealProtein)
        if caloriesLeftAfter < 0, caloriesLeftBefore > 0, mealCalories / 2 <= caloriesLeftBefore {
            detail = "A smaller portion would keep you under. \(proteinLine)"
        } else {
            detail = proteinLine
        }
    }

    private static func headline(leftBefore: Int, leftAfter: Int, meal: Int) -> String {
        if leftBefore <= 0 {
            return "You’ve already hit today’s calories"
        }
        if leftAfter < 0 {
            return "Puts you about \(roundedCalories(-leftAfter)) cal over"
        }
        if Double(meal) / Double(leftBefore) >= 0.8 {
            return "Fits, but uses most of today"
        }
        return "Fits with \(leftAfter.formatted()) cal to spare"
    }

    private static func proteinLine(leftBefore: Double, meal: Double) -> String {
        let mealGrams = Int(meal.rounded())
        if leftBefore <= 0 {
            return "Your protein goal is already met today."
        }
        let neededGrams = Int(leftBefore.rounded())
        if meal >= leftBefore {
            return "Its \(mealGrams) g of protein completes today’s goal."
        }
        if meal < 5 {
            return "Low in protein. You still need \(neededGrams) g today."
        }
        let percent = roundedPercent(meal / leftBefore)
        return "Adds \(mealGrams) g protein, about \(percent)% of the \(neededGrams) g you still need."
    }

    /// Rounds to the nearest 10 kcal, matching the approximate nature of the numbers.
    private static func roundedCalories(_ calories: Int) -> Int {
        max(10, Int((Double(calories) / 10).rounded()) * 10)
    }

    /// Rounds a fraction to the nearest 5 percent.
    private static func roundedPercent(_ fraction: Double) -> Int {
        Int((fraction * 100 / 5).rounded()) * 5
    }
}
