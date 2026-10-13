import SwiftData
import SwiftUI

/// "Meal Result": how a meal would affect today's goals before it is logged.
/// Nothing is saved until the user taps Add to Today.
struct MealPreviewView: View {
    /// Closes the whole check flow after logging.
    let onFinish: () -> Void
    /// The photo the estimate came from; nil for a manually entered meal.
    let photo: UIImage?

    @Environment(\.modelContext) private var modelContext
    @Query private var todaysMeals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @State private var draft: MealDraft
    @State private var portion = 1.0
    @State private var isEditing = false
    @State private var showsAllIngredients = false

    init(draft: MealDraft, photo: UIImage? = nil, onFinish: @escaping () -> Void) {
        _draft = State(initialValue: draft)
        self.photo = photo
        self.onFinish = onFinish
        _todaysMeals = Query(filter: Meal.loggedToday())
    }

    /// The draft as it would be logged, with the overall portion applied.
    private var meal: MealDraft { draft.scaled(by: portion) }

    private var eatenCalories: Int { todaysMeals.reduce(0) { $0 + $1.calories } }
    private var eatenProtein: Double { todaysMeals.reduce(0) { $0 + $1.protein } }

    private var fit: GoalFit {
        GoalFit(
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            eatenCalories: eatenCalories,
            eatenProtein: eatenProtein,
            mealCalories: meal.calories,
            mealProtein: meal.protein
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                titleBlock
                bitCard
                dayCard
                disclaimer
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            actionBar
        }
        .navigationTitle("Meal Result")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditing) {
            AdjustMealView(draft: $draft, portion: $portion)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var header: some View {
        if let photo {
            FilledImage(image: Image(uiImage: photo), height: 150)
                .clipShape(.rect(cornerRadius: 22))
                .overlay(alignment: .topTrailing) {
                    chip("Estimate", icon: .sparkles, foreground: .white, background: Theme.ink.opacity(0.7))
                        .environment(\.colorScheme, .light)
                        .padding(10)
                }
                .accessibilityHidden(true)
        } else {
            Icon(.meals, size: 36)
                .frame(maxWidth: .infinity)
                .frame(height: 84)
                .background(Theme.soft, in: .rect(cornerRadius: 22))
                .overlay(alignment: .topTrailing) {
                    chip("Entered by you", icon: .pencil, foreground: Theme.blue, background: Theme.card)
                        .padding(10)
                }
                .accessibilityHidden(true)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(draft.name.isEmpty ? "Meal" : draft.name)
                .font(.rounded(22, .heavy))
                .foregroundStyle(Theme.ink)

            if photo != nil {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredients)
                        .font(.rounded(14, .medium))
                        .foregroundStyle(Theme.mute)
                        .lineLimit(showsAllIngredients ? nil : 2)
                    if ingredients.count > 70 {
                        Button(showsAllIngredients ? "Less" : "More") {
                            withAnimation(.snappy) { showsAllIngredients.toggle() }
                        }
                        .font(.rounded(13, .bold))
                        .foregroundStyle(Theme.blue)
                    }
                }
            }

            HStack(spacing: 18) {
                estimate(.calories, value: "≈\(meal.calories.formatted())", unit: "cal")
                estimate(.protein, value: "≈\(Int(meal.protein.rounded())) g", unit: "protein")
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 4)
    }

    private func estimate(_ icon: AppIcon, value: String, unit: String) -> some View {
        HStack(spacing: 4) {
            Icon(icon, size: 18)
            Text(value)
                .font(.rounded(20, .heavy))
                .foregroundStyle(Theme.ink)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(unit)
                .font(.rounded(15, .medium))
                .foregroundStyle(Theme.mute)
        }
        .accessibilityElement(children: .combine)
    }

    private var bitCard: some View {
        HStack(spacing: 10) {
            BitView(mood: fit.exceedsCalorieGoal ? .oops : .happy, size: 64, animates: false)
            VStack(alignment: .leading, spacing: 3) {
                Text(fit.headline)
                    .font(.rounded(16, .heavy))
                    .foregroundStyle(Theme.ink)
                Text(fit.detail)
                    .font(.rounded(13, .medium))
                    .foregroundStyle(Theme.ink.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 8)
        .padding(.trailing, 14)
        .padding(.vertical, 10)
        .background(fit.exceedsCalorieGoal ? Theme.amberBackground : Theme.fitBackground, in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }

    private var dayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your day if you add this meal")
                .font(.rounded(15, .heavy))
                .foregroundStyle(Theme.ink)
            dayRow(
                icon: .calories, title: "Calories",
                total: (eatenCalories + meal.calories).formatted(), goal: "\(calorieGoal.formatted()) cal"
            )
            StackedBar(goal: Double(calorieGoal), eaten: Double(eatenCalories), meal: Double(meal.calories), showsOver: true)
            dayRow(
                icon: .protein, title: "Protein",
                total: Int((eatenProtein + meal.protein).rounded()).formatted(), goal: "\(proteinGoal) g"
            )
                .padding(.top, 4)
            StackedBar(goal: Double(proteinGoal), eaten: eatenProtein, meal: meal.protein, showsOver: false)
            HStack(spacing: 14) {
                legend(Theme.blue, "Already eaten")
                legend(Theme.blueSoft, "This meal")
                if fit.exceedsCalorieGoal {
                    legend(Theme.amber, "Over goal")
                }
            }
            .padding(.top, 2)
        }
        .padding(16)
        .cardStyle(radius: 20)
    }

    private func dayRow(icon: AppIcon, title: String, total: String, goal: String) -> some View {
        HStack(spacing: 6) {
            Icon(icon, size: 15)
            Text(title)
                .font(.rounded(14, .semibold))
                .foregroundStyle(Theme.ink)
            Spacer()
            (Text(total).font(.rounded(15, .heavy)).foregroundStyle(Theme.ink)
                + Text(" / \(goal)").font(.rounded(14, .medium)).foregroundStyle(Theme.mute))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label)
                .font(.rounded(12, .medium))
                .foregroundStyle(Theme.mute)
        }
    }

    private var disclaimer: some View {
        Label { Text(disclaimerText) } icon: {
            Icon(.info, size: 12, color: draft.isLowConfidence ? Theme.amber : Theme.mute)
        }
        .font(.rounded(12, .medium))
        .foregroundStyle(Theme.mute)
        .padding(.horizontal, 4)
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            Button {
                isEditing = true
            } label: {
                Label { Text("Edit") } icon: { Icon(.pencil, size: 16) }
                    .padding(.horizontal, 18)
            }
            .buttonStyle(SecondaryButtonStyle(height: 56))
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityLabel("Edit Meal")

            Button("Add to Today", action: log)
                .buttonStyle(PrimaryButtonStyle(height: 56))
                .disabled(draft.components.allSatisfy { $0.scale == 0 })
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background {
            Theme.background
                .shadow(color: Theme.ink.opacity(0.06), radius: 8, y: -4)
                .ignoresSafeArea()
        }
    }

    private func chip(_ text: String, icon: AppIcon, foreground: Color, background: Color) -> some View {
        Label { Text(text) } icon: { Icon(icon, size: 11, color: foreground) }
            .labelStyle(.titleAndIcon)
            .font(.rounded(12, .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: .capsule)
    }

    // MARK: - Text

    /// Included item names, such as "Grilled chicken breast, white rice".
    private var ingredients: String {
        let names = draft.components.filter { $0.scale > 0 }.map { $0.name.lowercased() }
        let joined = names.joined(separator: ", ")
        return joined.prefix(1).uppercased() + joined.dropFirst()
    }

    private var disclaimerText: String {
        if draft.isLowConfidence {
            return "Bit wasn't sure about this photo. Check the items with Edit."
        }
        if photo == nil { return "Based on what you entered." }
        let edits = draft.components.contains(where: \.isEdited) ? ", with your edits" : ""
        return "Estimated from your photo\(edits). Values are approximate."
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
        MealPreviewView(draft: .sampleEstimate, photo: UIImage(named: "SampleMeal"), onFinish: {})
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
