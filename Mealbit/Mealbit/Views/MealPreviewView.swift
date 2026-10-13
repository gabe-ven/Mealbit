import SwiftData
import SwiftUI

/// Shows how a meal would affect today's goals before it is logged, and lets the
/// user correct and adjust it in place.
struct MealPreviewView: View {
    /// Closes the whole add-meal flow after logging or discarding.
    let onFinish: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var todaysMeals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @State private var draft: MealDraft
    @State private var portion = 1.0
    @State private var editingComponent: MealComponent?

    private static let portions: [(label: String, value: Double)] = [
        ("½×", 0.5), ("1×", 1), ("1½×", 1.5), ("2×", 2),
    ]

    init(draft: MealDraft, onFinish: @escaping () -> Void) {
        _draft = State(initialValue: draft)
        self.onFinish = onFinish
        _todaysMeals = Query(filter: Meal.loggedToday())
    }

    /// The draft as it would be logged, with the overall portion applied.
    private var meal: MealDraft { draft.scaled(by: portion) }

    private var hasMultipleItems: Bool { draft.components.count > 1 }

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

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Meal name", text: $draft.name)
                        .font(.title3.bold())
                    Text("≈ \(meal.calories) kcal")
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                    Text("Protein ≈ \(grams(meal.protein)) · Carbs ≈ \(grams(meal.carbs)) · Fat ≈ \(grams(meal.fat))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                if draft.estimateNote != nil || draft.isLowConfidence {
                    estimateNote
                }

                Picker("Category", selection: $draft.category) {
                    ForEach(MealCategory.allCases) { category in
                        Text(category.displayName).tag(category)
                    }
                }

                if !hasMultipleItems, let only = meal.components.first {
                    Button("Correct Values") { editingComponent = only }
                }
            } footer: {
                Text(hasMultipleItems ? "Approximate values. Tap an item to correct it." : "Approximate values.")
            }

            Section("Portion") {
                Picker("Portion", selection: $portion) {
                    ForEach(Self.portions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.segmented)
            }

            if hasMultipleItems {
                Section("Items") {
                    ForEach($draft.components) { $component in
                        componentRow($component)
                    }
                }
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
                    .disabled(draft.components.allSatisfy { $0.scale == 0 })
            }
        }
        .sheet(item: $editingComponent) { component in
            ComponentEditView(component: component, onSave: replaceComponent)
        }
    }

    private var estimateNote: some View {
        Label {
            Text(draft.estimateNote ?? "Rough estimate. Check the items below.")
        } icon: {
            Image(systemName: draft.isLowConfidence ? "exclamationmark.triangle" : "info.circle")
        }
        .font(.footnote)
        .foregroundStyle(draft.isLowConfidence ? .orange : .secondary)
    }

    private func componentRow(_ component: Binding<MealComponent>) -> some View {
        var shown = component.wrappedValue
        shown.scale *= portion
        let isRemoved = shown.scale == 0

        return HStack {
            Button {
                editingComponent = shown
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(shown.name)
                        .foregroundStyle(.primary)
                    Text(isRemoved ? "Removed" : "\(amount(shown)) · ≈ \(Int(shown.adjustedCalories.rounded())) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.borderless)

            Stepper("Amount of \(shown.name)", value: component.scale, in: 0...4, step: 0.5)
                .labelsHidden()
        }
        .opacity(isRemoved ? 0.5 : 1)
    }

    /// Stores an edited item, undoing the overall portion so the values the user
    /// typed are exactly what they see.
    private func replaceComponent(_ edited: MealComponent) {
        guard let index = draft.components.firstIndex(where: { $0.id == edited.id }) else { return }
        var base = edited
        base.quantity /= portion
        base.calories /= portion
        base.protein /= portion
        base.carbs /= portion
        base.fat /= portion
        draft.components[index] = base
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

    private func amount(_ component: MealComponent) -> String {
        "\(component.adjustedQuantity.formatted(.number.precision(.fractionLength(0...2)))) \(component.unit)"
    }

    private func log() {
        var loggedMeal = meal
        loggedMeal.name = loggedMeal.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if loggedMeal.name.isEmpty { loggedMeal.name = "Meal" }
        modelContext.insert(Meal(draft: loggedMeal))
        onFinish()
    }
}

#Preview("Photo estimate") {
    NavigationStack {
        MealPreviewView(draft: .sampleEstimate, onFinish: {})
    }
    .modelContainer(Meal.previewContainer)
}

#Preview("Manual entry") {
    NavigationStack {
        MealPreviewView(
            draft: MealDraft(name: "Chicken Burrito Bowl", category: .lunch, calories: 720, protein: 45, carbs: 80, fat: 22),
            onFinish: {}
        )
    }
    .modelContainer(Meal.previewContainer)
}
