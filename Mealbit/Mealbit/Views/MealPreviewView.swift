import SwiftData
import SwiftUI

/// Shows how a meal would affect today's goals before it is logged.
struct MealPreviewView: View {
    let draft: MealDraft
    /// Closes the whole add-meal flow after logging or discarding.
    let onFinish: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var todaysMeals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @State private var portion = 1.0

    private static let portions: [(label: String, value: Double)] = [
        ("½×", 0.5), ("1×", 1), ("1½×", 1.5), ("2×", 2),
    ]

    init(draft: MealDraft, onFinish: @escaping () -> Void) {
        self.draft = draft
        self.onFinish = onFinish
        _todaysMeals = Query(filter: Meal.loggedToday())
    }

    private var meal: MealDraft { draft.scaled(by: portion) }

    private var fit: GoalFit {
        GoalFit(
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            eatenCalories: todaysMeals.reduce(0) { $0 + $1.calories },
            eatenProtein: todaysMeals.reduce(0) { $0 + $1.protein },
            mealCalories: meal.calories,
            mealProtein: meal.protein
        )
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meal.name)
                        .font(.title3.bold())
                    Text("≈ \(meal.calories) kcal")
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                    Text("Protein ≈ \(grams(meal.protein)) · Carbs ≈ \(grams(meal.carbs)) · Fat ≈ \(grams(meal.fat))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } footer: {
                Text("Approximate values. Go back to edit them.")
            }

            Section("How it fits today") {
                Text(fit.explanation)
                impactRow(
                    "Calories",
                    before: "\(fit.caloriesLeftBefore.formatted()) left",
                    after: caloriesLeftText(fit.caloriesLeftAfter),
                    isWarning: fit.exceedsCalorieGoal
                )
                impactRow(
                    "Protein",
                    before: proteinLeftText(fit.proteinLeftBefore),
                    after: proteinLeftText(fit.proteinLeftAfter),
                    isWarning: false
                )
            }

            Section("Portion") {
                Picker("Portion", selection: $portion) {
                    ForEach(Self.portions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button("Discard", role: .destructive, action: onFinish)
            }
        }
        .navigationTitle("Meal Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Log", action: log)
            }
        }
    }

    private func impactRow(_ title: String, before: String, after: String, isWarning: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(before)
                .foregroundStyle(.secondary)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(after)
                .fontWeight(.semibold)
                .foregroundStyle(isWarning ? .orange : .primary)
        }
        .monospacedDigit()
    }

    private func caloriesLeftText(_ caloriesLeft: Int) -> String {
        caloriesLeft < 0 ? "\((-caloriesLeft).formatted()) over" : "\(caloriesLeft.formatted()) left"
    }

    private func proteinLeftText(_ proteinLeft: Double) -> String {
        proteinLeft <= 0 ? "Goal met" : "\(grams(proteinLeft)) to go"
    }

    private func grams(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(0)))) g"
    }

    private func log() {
        modelContext.insert(Meal(draft: meal))
        onFinish()
    }
}

#Preview {
    NavigationStack {
        MealPreviewView(
            draft: MealDraft(name: "Chicken Burrito Bowl", category: .lunch, calories: 720, protein: 45, carbs: 80, fat: 22),
            onFinish: {}
        )
    }
    .modelContainer(Meal.previewContainer)
}
