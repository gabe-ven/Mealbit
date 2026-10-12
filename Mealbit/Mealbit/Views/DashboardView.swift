import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @AppStorage(NutritionGoals.hasSetGoalsKey) private var hasSetGoals = false
    @State private var isAddingMeal = false
    @State private var isEditingGoals = false
    @State private var editingMeal: Meal?

    init() {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        _meals = Query(
            filter: #Predicate<Meal> { $0.date >= startOfToday && $0.date < startOfTomorrow },
            sort: \.date
        )
    }

    private var caloriesEaten: Int { meals.reduce(0) { $0 + $1.calories } }
    private var proteinEaten: Double { meals.reduce(0) { $0 + $1.protein } }
    private var carbsEaten: Double { meals.reduce(0) { $0 + $1.carbs } }
    private var fatEaten: Double { meals.reduce(0) { $0 + $1.fat } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CalorieSummaryCard(consumed: caloriesEaten, goal: calorieGoal)
                }

                Section {
                    MacroProgressRow(name: "Protein", consumed: proteinEaten, goal: Double(proteinGoal), color: .blue)
                    gramsRow("Carbs", carbsEaten)
                    gramsRow("Fat", fatEaten)
                }

                if meals.isEmpty {
                    Section("Today's Meals") {
                        Text("No meals logged yet. Tap + to add one.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(MealCategory.allCases) { category in
                        let categoryMeals = meals.filter { $0.category == category }
                        if !categoryMeals.isEmpty {
                            Section(category.displayName) {
                                ForEach(categoryMeals) { meal in
                                    Button {
                                        editingMeal = meal
                                    } label: {
                                        MealRow(meal: meal)
                                    }
                                    .tint(.primary)
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        modelContext.delete(categoryMeals[index])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Daily Goals", systemImage: "target") {
                        isEditingGoals = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Meal", systemImage: "plus") {
                        isAddingMeal = true
                    }
                }
            }
            .sheet(isPresented: $isAddingMeal) {
                MealFormView()
            }
            .sheet(item: $editingMeal) { meal in
                MealFormView(meal: meal)
            }
            .sheet(isPresented: $isEditingGoals) {
                GoalsView()
            }
            .onAppear {
                if !hasSetGoals {
                    isEditingGoals = true
                }
            }
        }
    }

    private func gramsRow(_ name: String, _ grams: Double) -> some View {
        LabeledContent(name) {
            Text("\(grams, format: .number.precision(.fractionLength(0))) g")
                .monospacedDigit()
        }
    }
}

#Preview("With meals") {
    DashboardView()
        .modelContainer(Meal.previewContainer)
}

#Preview("Empty") {
    DashboardView()
        .modelContainer(for: Meal.self, inMemory: true)
}
