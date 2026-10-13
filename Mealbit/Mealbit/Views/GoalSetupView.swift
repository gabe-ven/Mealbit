import SwiftUI

/// First-launch flow that asks for the daily goals one page at a time.
struct GoalSetupView: View {
    private enum Step {
        case calories, protein
    }

    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @AppStorage(NutritionGoals.hasSetGoalsKey) private var hasSetGoals = false

    @State private var path: [Step] = []
    @State private var caloriesText = String(NutritionGoals.defaultCalories)
    @State private var proteinText = String(NutritionGoals.defaultProtein)

    var body: some View {
        NavigationStack(path: $path) {
            welcomePage
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .calories:
                        GoalEntryPage(
                            title: "Calories",
                            message: "How many calories do you want to eat each day?",
                            unit: "kcal",
                            range: NutritionGoals.calorieRange,
                            buttonTitle: "Continue",
                            text: $caloriesText
                        ) { path.append(.protein) }
                    case .protein:
                        GoalEntryPage(
                            title: "Protein",
                            message: "How many grams of protein do you want each day?",
                            unit: "g",
                            range: NutritionGoals.proteinRange,
                            buttonTitle: "Done",
                            text: $proteinText,
                            onContinue: save
                        )
                    }
                }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "target")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Daily Goals")
                .font(.largeTitle.bold())
            Text("Mealbit uses your daily goals to show how a meal would fit your day before you eat it.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
        .safeAreaInset(edge: .bottom) {
            ContinueButton(title: "Get Started") { path.append(.calories) }
        }
    }

    private func save() {
        guard let calories = GoalEntryPage.validNumber(caloriesText, in: NutritionGoals.calorieRange),
              let protein = GoalEntryPage.validNumber(proteinText, in: NutritionGoals.proteinRange)
        else { return }
        calorieGoal = calories
        proteinGoal = protein
        hasSetGoals = true
    }
}

/// One full page with a large number entry for a single goal.
private struct GoalEntryPage: View {
    let title: String
    let message: String
    let unit: String
    let range: ClosedRange<Int>
    let buttonTitle: String
    @Binding var text: String
    let onContinue: () -> Void

    @FocusState private var isFocused: Bool

    static func validNumber(_ text: String, in range: ClosedRange<Int>) -> Int? {
        guard let value = try? Int(text, format: .number), range.contains(value) else { return nil }
        return value
    }

    private var isValid: Bool { Self.validNumber(text, in: range) != nil }

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.largeTitle.bold())
            Text(message)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .fixedSize()
                Text(unit)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 32)

            Text("Between \(range.lowerBound) and \(range.upperBound) \(unit)")
                .font(.footnote)
                .foregroundStyle(!text.isEmpty && !isValid ? .red : .secondary)

            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 24)
        .safeAreaInset(edge: .bottom) {
            ContinueButton(title: buttonTitle, action: onContinue)
                .disabled(!isValid)
        }
        .onAppear { isFocused = true }
    }
}

private struct ContinueButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

#Preview {
    GoalSetupView()
}
