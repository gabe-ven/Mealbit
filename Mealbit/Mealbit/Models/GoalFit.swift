import Foundation

/// How a potential meal would change what's left of today's goals, plus a short
/// plain-language explanation. Pure calculation so it updates instantly.
struct GoalFit {
    let caloriesLeftBefore: Int
    let caloriesLeftAfter: Int
    let proteinLeftBefore: Double
    let proteinLeftAfter: Double
    let explanation: String
    /// Short verdict, such as "Great fit for today!".
    let verdict: String
    /// One line under the verdict.
    let verdictDetail: String

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
        let calorieSentence = Self.calorieSentence(leftBefore: caloriesLeftBefore, leftAfter: caloriesLeftAfter, meal: mealCalories)
        explanation = [
            calorieSentence,
            Self.proteinSentence(leftBefore: proteinLeftBefore, meal: mealProtein),
        ].joined(separator: " ")

        if caloriesLeftAfter < 0 {
            verdict = "A bit over today’s goal"
            verdictDetail = "\(calorieSentence) Good to know before you eat."
        } else {
            let usesMostOfToday = caloriesLeftBefore > 0 && Double(mealCalories) / Double(caloriesLeftBefore) >= 0.8
            verdict = usesMostOfToday ? "Fits, using most of today" : "Great fit for today!"
            verdictDetail = mealProtein >= 25
                ? "High protein choice that keeps you on track."
                : "Leaves room for the rest of your day."
        }
    }

    private static func calorieSentence(leftBefore: Int, leftAfter: Int, meal: Int) -> String {
        if leftBefore <= 0 {
            return "You've already reached today's calorie goal, so this would add about \(roundedCalories(meal)) kcal over it."
        }
        if leftAfter < 0 {
            return "This would put you about \(roundedCalories(-leftAfter)) kcal over today's goal."
        }
        let percent = roundedPercent(Double(meal) / Double(leftBefore))
        if percent < 5 { return "This uses only a small part of your remaining calories." }
        if percent >= 95 { return "This uses nearly all of your remaining calories." }
        return "This uses about \(percent)% of your remaining calories."
    }

    private static func proteinSentence(leftBefore: Double, meal: Double) -> String {
        if leftBefore <= 0 { return "You've already reached your protein goal today." }
        if meal < 1 { return "It adds almost no protein." }
        if meal >= leftBefore { return "It would complete your protein goal for today." }
        let percent = roundedPercent(meal / leftBefore)
        if percent < 5 { return "It adds a little protein." }
        return "It covers about \(percent)% of the protein you still need."
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
