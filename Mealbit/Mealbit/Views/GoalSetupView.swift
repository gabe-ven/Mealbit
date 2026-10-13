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
                            step: 1,
                            title: "Daily\ncalories",
                            unit: "kcal",
                            range: NutritionGoals.calorieRange,
                            buttonTitle: "Continue",
                            text: $caloriesText
                        ) { path.append(.protein) }
                    case .protein:
                        GoalEntryPage(
                            step: 2,
                            title: "Daily\nprotein",
                            unit: "grams",
                            range: NutritionGoals.proteinRange,
                            buttonTitle: "Done",
                            text: $proteinText,
                            onContinue: save
                        )
                    }
                }
        }
        .tint(.white)
    }

    private var welcomePage: some View {
        OnboardingPage {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text("Mealbit")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(.white.opacity(0.7))
                Text("Know if it fits before you eat it.")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Set two daily goals. Then snap any meal to see how it fits.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Spacer()
            }
        } button: {
            OnboardingButton(title: "Get Started") { path.append(.calories) }
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

/// One goal page: a bold title and a very large number to type.
private struct GoalEntryPage: View {
    let step: Int
    let title: String
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
        OnboardingPage {
            VStack(alignment: .leading, spacing: 0) {
                StepIndicator(current: step, total: 2)
                    .padding(.top, 8)

                Text(title)
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.top, 32)

                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .padding(.top, 24)

                Text(unit)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.7))

                Text(isValid || text.isEmpty
                     ? "Between \(range.lowerBound) and \(range.upperBound)"
                     : "Enter a number between \(range.lowerBound) and \(range.upperBound)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(isValid || text.isEmpty ? 0.6 : 1))
                    .padding(.top, 16)

                Spacer()
            }
        } button: {
            OnboardingButton(title: buttonTitle, action: onContinue)
                .disabled(!isValid)
        }
        .onAppear { isFocused = true }
    }
}

/// Full-screen blue page with content on top and a button pinned at the bottom.
private struct OnboardingPage<Content: View, ButtonContent: View>: View {
    @ViewBuilder let content: Content
    @ViewBuilder let button: ButtonContent

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .background(Color.brand.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                button
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct OnboardingButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3.weight(.heavy))
                .foregroundStyle(Color.brand)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.white, in: .capsule)
                .opacity(isEnabled ? 1 : 0.5)
        }
    }
}

private struct StepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...total, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(index <= current ? 1 : 0.3))
                    .frame(width: 32, height: 6)
            }
        }
        .accessibilityLabel("Step \(current) of \(total)")
    }
}

#Preview {
    GoalSetupView()
}
