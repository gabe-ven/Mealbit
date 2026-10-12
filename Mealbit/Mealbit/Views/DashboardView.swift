import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @State private var isAddingMeal = false
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
                    CalorieSummaryCard(consumed: caloriesEaten, goal: NutritionGoals.calories)
                }

                Section("Macros") {
                    MacroProgressRow(name: "Protein", consumed: proteinEaten, goal: NutritionGoals.protein, color: .blue)
                    MacroProgressRow(name: "Carbs", consumed: carbsEaten, goal: NutritionGoals.carbs, color: .orange)
                    MacroProgressRow(name: "Fat", consumed: fatEaten, goal: NutritionGoals.fat, color: .pink)
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
