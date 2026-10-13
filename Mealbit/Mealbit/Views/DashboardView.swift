import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @AppStorage(NutritionGoals.hasSetGoalsKey) private var hasSetGoals = false
    @State private var isCheckingMeal = false
    @State private var isEditingGoals = false
    @State private var editingMeal: Meal?
    @State private var isPreviewingSample = false

    init() {
        _meals = Query(filter: Meal.loggedToday(), sort: \.date)
    }

    private var caloriesEaten: Int { meals.reduce(0) { $0 + $1.calories } }
    private var proteinEaten: Double { meals.reduce(0) { $0 + $1.protein } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    RemainingCard(
                        caloriesEaten: caloriesEaten,
                        calorieGoal: calorieGoal,
                        proteinEaten: proteinEaten,
                        proteinGoal: proteinGoal
                    )
                }

                Section("Eaten Today") {
                    if meals.isEmpty {
                        Text("Check a meal before you eat it to see how it fits your day.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(meals) { meal in
                            Button {
                                editingMeal = meal
                            } label: {
                                MealRow(meal: meal)
                            }
                            .tint(.primary)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(meals[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .safeAreaInset(edge: .bottom) {
                checkMealButton
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Daily Goals", systemImage: "target") {
                        isEditingGoals = true
                    }
                }
                #if DEBUG
                // Temporary way to reach the photo-estimate preview until the camera flow exists.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sample") {
                        isPreviewingSample = true
                    }
                }
                #endif
            }
            .sheet(isPresented: $isPreviewingSample) {
                NavigationStack {
                    MealPreviewView(draft: .sampleEstimate, onFinish: { isPreviewingSample = false })
                }
            }
            .sheet(isPresented: $isCheckingMeal) {
                // Manual entry until the camera flow exists.
                MealFormView()
            }
            .sheet(item: $editingMeal) { meal in
                MealFormView(meal: meal)
            }
            .sheet(isPresented: $isEditingGoals) {
                GoalsView()
            }
            .fullScreenCover(isPresented: .constant(!hasSetGoals)) {
                GoalSetupView()
            }
        }
    }

    private var checkMealButton: some View {
        Button {
            isCheckingMeal = true
        } label: {
            Label("Check a Meal", systemImage: "camera.fill")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
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
