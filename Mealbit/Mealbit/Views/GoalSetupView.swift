import SwiftUI

/// First launch: a welcome page, then the two daily goals.
struct GoalSetupView: View {
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @AppStorage(NutritionGoals.hasSetGoalsKey) private var hasSetGoals = false

    @State private var isShowingGoals = false
    @State private var calories = NutritionGoals.defaultCalories
    @State private var protein = NutritionGoals.defaultProtein

    var body: some View {
        NavigationStack {
            welcomePage
                .navigationDestination(isPresented: $isShowingGoals) { goalsPage }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 22) {
            Spacer()
            BitView(mood: .happy, size: 240)
            Wordmark(size: 50)
                .padding(.top, 10)
            Text("Snap your meal. See how it fits your day.")
                .font(.rounded(28, .black))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            Spacer()
            Button("Get Started") { isShowingGoals = true }
                .buttonStyle(PrimaryButtonStyle(height: 62, fontSize: 21))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.soft)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var goalsPage: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {
                BitView(mood: .happy, size: 84)
                Text("Set your daily goals. You can change them anytime.")
                    .font(.rounded(16, .heavy))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .raised(UnevenRoundedRectangle(
                        topLeadingRadius: 20, bottomLeadingRadius: 6, bottomTrailingRadius: 20, topTrailingRadius: 20
                    ))
                    .padding(.bottom, 22)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)

            VStack(spacing: 14) {
                GoalStepperCard(
                    title: "Daily calories", icon: .calories, value: $calories, unit: "kcal",
                    range: NutritionGoals.calorieRange, step: 50
                )
                GoalStepperCard(
                    title: "Daily protein", icon: .protein, value: $protein, unit: "g",
                    range: NutritionGoals.proteinRange, step: 5
                )
            }
            .padding(.top, 18)

            Spacer()

            Button("Start Checking Meals") { save(calories: calories, protein: protein) }
                .buttonStyle(PrimaryButtonStyle(height: 62, fontSize: 21))
            Button("Skip and use defaults") {
                save(calories: NutritionGoals.defaultCalories, protein: NutritionGoals.defaultProtein)
            }
            .buttonStyle(TextButtonStyle())
            .padding(.top, 6)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(Theme.background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleButton(systemImage: "chevron.left") { isShowingGoals = false }
                    .accessibilityLabel("Back")
            }
        }
    }

    private func save(calories: Int, protein: Int) {
        calorieGoal = calories
        proteinGoal = protein
        hasSetGoals = true
    }
}

/// "Meal" in navy and "bit" in blue.
struct Wordmark: View {
    let size: CGFloat

    var body: some View {
        (Text("Meal").foregroundStyle(Theme.ink) + Text("bit").foregroundStyle(Theme.blue))
            .font(.rounded(size, .black))
            .tracking(-size * 0.02)
            .accessibilityLabel("Mealbit")
    }
}

#Preview {
    GoalSetupView()
}
