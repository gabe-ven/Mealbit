import Foundation

/// One part of a meal, such as "Chicken breast, 6 oz". Nutrition values are for
/// `quantity`; `scale` is the user's adjustment in the preview (0 removes it).
struct MealComponent: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var scale = 1.0

    var adjustedQuantity: Double { quantity * scale }
    var adjustedCalories: Double { calories * scale }
    var adjustedProtein: Double { protein * scale }
    var adjustedCarbs: Double { carbs * scale }
    var adjustedFat: Double { fat * scale }
}

/// A meal being considered in the preview. Kept in memory only; it becomes a
/// saved `Meal` when the user taps Log.
struct MealDraft: Hashable {
    var name: String
    var category: MealCategory
    var components: [MealComponent]
    /// The estimate's portion assumptions, shown so the user can judge it.
    var estimateNote: String?
    var isLowConfidence = false

    var calories: Int { Int(components.reduce(0) { $0 + $1.adjustedCalories }.rounded()) }
    var protein: Double { components.reduce(0) { $0 + $1.adjustedProtein } }
    var carbs: Double { components.reduce(0) { $0 + $1.adjustedCarbs } }
    var fat: Double { components.reduce(0) { $0 + $1.adjustedFat } }

    /// A manually entered meal: one serving with the given totals.
    init(name: String, category: MealCategory, calories: Int, protein: Double, carbs: Double, fat: Double) {
        self.init(
            name: name,
            category: category,
            components: [
                MealComponent(
                    name: name, quantity: 1, unit: "serving",
                    calories: Double(calories), protein: protein, carbs: carbs, fat: fat
                ),
            ]
        )
    }

    init(name: String, category: MealCategory, components: [MealComponent], estimateNote: String? = nil, isLowConfidence: Bool = false) {
        self.name = name
        self.category = category
        self.components = components
        self.estimateNote = estimateNote
        self.isLowConfidence = isLowConfidence
    }

    /// The draft with every component's adjustment multiplied by `portion`.
    func scaled(by portion: Double) -> MealDraft {
        var copy = self
        for index in copy.components.indices {
            copy.components[index].scale *= portion
        }
        return copy
    }
}
