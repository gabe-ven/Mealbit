import SwiftUI

/// Edits the daily goals from Home. Changes apply right away.
struct GoalsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SheetHeader(title: "Daily Goals") { dismiss() }
                GoalStepperCard(
                    title: "🔥 Daily calories", dot: Theme.blue, value: $calorieGoal, unit: "kcal",
                    range: NutritionGoals.calorieRange, step: 50
                )
                GoalStepperCard(
                    title: "💪 Daily protein", dot: Theme.orange, value: $proteinGoal, unit: "g",
                    range: NutritionGoals.proteinRange, step: 5
                )
                Text("Changes apply right away.")
                    .font(.rounded(13, .bold))
                    .foregroundStyle(Theme.mute)
                Button("Done") { dismiss() }
                    .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }
}

#Preview {
    Text("Home")
        .sheet(isPresented: .constant(true)) { GoalsView() }
}
