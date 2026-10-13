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
            VStack(spacing: 10) {
                header
                titleBlock
                HStack(spacing: 10) {
                    statTile(emoji: "🔥", value: "≈\(meal.calories.formatted())", label: "calories")
                    statTile(emoji: "💪", value: "≈\(Int(meal.protein.rounded()))g", label: "protein")
                }
                verdictCard
                fitCard
                Text(footnote)
                    .font(.rounded(12, .bold))
                    .foregroundStyle(Theme.mute)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                Button("Add to Today", action: log)
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(draft.components.allSatisfy { $0.scale == 0 })
                    .padding(.top, 4)
                Button {
                    isEditing = true
                } label: {
                    Label("Edit Meal", systemImage: "pencil")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .background(Theme.background)
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
            FilledImage(image: Image(uiImage: photo), height: 138)
                .clipShape(.rect(cornerRadius: 24))
                .overlay(alignment: .topTrailing) {
                    chip("✨ Estimate", foreground: .white, background: Theme.ink.opacity(0.7))
                        .environment(\.colorScheme, .light)
                        .padding(10)
                }
                .accessibilityHidden(true)
        } else {
            Text("🍽️")
                .font(.system(size: 46))
                .frame(maxWidth: .infinity)
                .frame(height: 110)
                .background(Theme.soft, in: .rect(cornerRadius: 24))
                .overlay(alignment: .topTrailing) {
                    chip("Entered by you", foreground: Theme.blue, background: Theme.card)
                        .padding(10)
                }
                .accessibilityHidden(true)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(draft.name.isEmpty ? "Meal" : draft.name)
                .font(.rounded(21, .black))
                .foregroundStyle(Theme.ink)
            Text(ingredients)
                .font(.rounded(14, .semibold))
                .foregroundStyle(Theme.mute)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private func statTile(emoji: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Text(emoji).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.rounded(24, .black))
                    .foregroundStyle(Theme.ink)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(label)
                    .font(.rounded(13, .bold))
                    .foregroundStyle(Theme.mute)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .cardStyle(radius: 20)
        .accessibilityElement(children: .combine)
    }

    private var verdictCard: some View {
        HStack(spacing: 8) {
            BitView(mood: .happy, size: 78, animates: false)
            VStack(alignment: .leading, spacing: 2) {
                Text(fit.verdict)
                    .font(.rounded(17, .black))
                    .foregroundStyle(Theme.ink)
                Text(fit.verdictDetail)
                    .font(.rounded(13, .bold))
                    .foregroundStyle(Theme.mute)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .padding(.vertical, 10)
        .background(fit.exceedsCalorieGoal ? Theme.amberBackground : Theme.fitBackground, in: .rect(cornerRadius: 22))
        .accessibilityElement(children: .combine)
    }

    private var fitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How it fits your day")
                .font(.rounded(15, .black))
                .foregroundStyle(Theme.ink)
            fitRow(
                emoji: "🔥", title: "Calories",
                total: (eatenCalories + meal.calories).formatted(), goal: "\(calorieGoal.formatted()) cal"
            )
            StackedBar(goal: Double(calorieGoal), eaten: Double(eatenCalories), meal: Double(meal.calories), showsOver: true)
            fitRow(
                emoji: "💪", title: "Protein",
                total: Int((eatenProtein + meal.protein).rounded()).formatted(), goal: "\(proteinGoal)g"
            )
            StackedBar(goal: Double(proteinGoal), eaten: eatenProtein, meal: meal.protein, showsOver: false)
            HStack(spacing: 14) {
                legend(Theme.blue, "Already eaten")
                legend(Theme.blueSoft, "This meal")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .cardStyle()
    }

    private func fitRow(emoji: String, title: String, total: String, goal: String) -> some View {
        HStack(spacing: 8) {
            Text(emoji).font(.system(size: 16))
            Text(title)
                .font(.rounded(15, .heavy))
                .foregroundStyle(Theme.ink)
            Spacer()
            (Text(total).font(.rounded(15, .black)).foregroundStyle(Theme.ink)
                + Text(" / \(goal)").font(.rounded(15, .bold)).foregroundStyle(Theme.mute))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
                .font(.rounded(12, .bold))
                .foregroundStyle(Theme.mute)
        }
    }

    private func chip(_ text: String, foreground: Color, background: Color) -> some View {
        Text(text)
            .font(.rounded(12, .heavy))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: .capsule)
    }

    // MARK: - Text

    /// Included item names, such as "Grilled chicken breast, white rice".
    private var ingredients: String {
        if photo == nil { return "Entered manually" }
        let names = draft.components.filter { $0.scale > 0 }.map { $0.name.lowercased() }
        let joined = names.joined(separator: ", ")
        return joined.prefix(1).uppercased() + joined.dropFirst()
    }

    private var footnote: String {
        if draft.isLowConfidence {
            return "ⓘ Bit wasn't sure about this photo. Check the items in Edit Meal before adding it."
        }
        let source = photo == nil ? "Based on what you entered" : "Estimated from your photo"
        let edits = draft.components.contains(where: \.isEdited) ? ", with your edits" : ""
        return "ⓘ \(source)\(edits). Tap Edit Meal to adjust the portion or items."
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
