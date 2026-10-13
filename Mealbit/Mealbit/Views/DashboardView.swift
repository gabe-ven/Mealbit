import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var meals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @AppStorage(NutritionGoals.hasSetGoalsKey) private var hasSetGoals = false
    @State private var isCheckingMeal = false
    @State private var isEnteringManually = false
    /// Set when the photo flow hands off to manual entry; opened once that flow has closed.
    @State private var opensManualAfterCheck = false
    @State private var isEditingGoals = false
    @State private var editingMeal: Meal?
    /// The meal logged most recently, celebrated until the user does something else.
    @State private var justAdded: Meal?

    init() {
        _meals = Query(filter: Meal.loggedToday(), sort: \.date, order: .reverse)
    }

    private var caloriesEaten: Int { meals.reduce(0) { $0 + $1.calories } }
    private var proteinEaten: Double { meals.reduce(0) { $0 + $1.protein } }
    private var calorieFraction: Double { calorieGoal > 0 ? Double(caloriesEaten) / Double(calorieGoal) : 0 }
    private var proteinFraction: Double { proteinGoal > 0 ? proteinEaten / Double(proteinGoal) : 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    bitBlock
                    goalCard(
                        emoji: "🔥", title: "Calories", eaten: caloriesEaten.formatted(),
                        goal: "\(calorieGoal.formatted()) cal", fraction: calorieFraction
                    )
                    goalCard(
                        emoji: "💪", title: "Protein", eaten: Int(proteinEaten.rounded()).formatted(),
                        goal: "\(proteinGoal)g", fraction: proteinFraction
                    )
                    Button {
                        open { isCheckingMeal = true }
                    } label: {
                        Label("Check a Meal", systemImage: "camera.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 4)
                    Button {
                        open { isEnteringManually = true }
                    } label: {
                        Label("Log Manually", systemImage: "pencil")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    todaysMeals
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Theme.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Wordmark(size: 32)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        open { isEditingGoals = true }
                    } label: {
                        Image(systemName: "target")
                            .foregroundStyle(Theme.mute)
                    }
                    .accessibilityLabel("Daily Goals")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: meals.map(\.id)) { old, new in
                // A meal that wasn't there before was just logged.
                if new.count > old.count, let added = meals.first(where: { !old.contains($0.id) }) {
                    withAnimation(.spring(duration: 0.5, bounce: 0.4)) { justAdded = added }
                }
            }
            .fullScreenCover(isPresented: $isCheckingMeal, onDismiss: openManualIfRequested) {
                CheckMealView(onEnterManually: { opensManualAfterCheck = true })
            }
            .sheet(isPresented: $isEnteringManually) {
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

    private func openManualIfRequested() {
        guard opensManualAfterCheck else { return }
        opensManualAfterCheck = false
        isEnteringManually = true
    }

    /// Ends the "just added" celebration, then opens something.
    private func open(_ action: () -> Void) {
        justAdded = nil
        action()
    }

    // MARK: - Bit

    private var bitBlock: some View {
        VStack(spacing: 4) {
            SpeechBubble(text: bitMessage)
                .frame(maxWidth: 270)
                .id(bitMessage)
                .transition(.scale(scale: 0.4).combined(with: .opacity))
            BitView(
                mood: .forCalories(eaten: caloriesEaten, goal: calorieGoal),
                size: 150,
                sparkle: proteinFraction >= 0.5 && proteinFraction < 1
            )
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            if let justAdded {
                Text("+\(justAdded.calories.formatted()) cal")
                    .font(.rounded(15, .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        Capsule().fill(Theme.blue).shadow(color: Theme.blue.opacity(0.3), radius: 7, y: 6)
                    }
                    .offset(x: -14, y: 84)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .overlay(alignment: .topLeading) {
            if justAdded == nil && proteinFraction >= 1 {
                Text("💪 Protein goal hit")
                    .font(.rounded(12, .black))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule().fill(Theme.card).shadow(color: Theme.ink.opacity(0.08), radius: 6, y: 4)
                    }
                    .offset(x: 10, y: 96)
            }
        }
    }

    private var bitMessage: String {
        if justAdded != nil {
            let left = calorieGoal - caloriesEaten
            return left < 0 ? "Yum, added! Today is covered. 🎉" : "Yum, added! \(left.formatted()) cal left today. 🎉"
        }
        if calorieFraction <= 0 { return "Bit is hungry. Let’s check your first meal! 🍴" }
        if calorieFraction < 0.2 { return "Nice start! Bit is waking up. ☀️" }
        if proteinFraction >= 1 && calorieFraction < 0.7 { return "Protein goal hit! Bit is feeling strong. 💪" }
        if calorieFraction < 0.7 { return "Nice start! Bit is getting energized. 🎉" }
        if calorieFraction < 1 { return "Bit is full of energy. Almost there! ⚡" }
        return "Goal reached! Great tracking today. 🎉"
    }

    // MARK: - Cards

    private func goalCard(emoji: String, title: String, eaten: String, goal: String, fraction: Double) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Text(emoji).font(.system(size: 18))
                Text(title)
                    .font(.rounded(15, .heavy))
                    .foregroundStyle(Theme.ink)
                Spacer()
                (Text(eaten).font(.rounded(15, .black)).foregroundStyle(Theme.ink)
                    + Text(" / \(goal)").font(.rounded(15, .bold)).foregroundStyle(Theme.mute))
                    .monospacedDigit()
            }
            CapsuleBar(fraction: fraction)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .cardStyle()
        .accessibilityElement(children: .combine)
    }

    private var todaysMeals: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("🍴").font(.system(size: 17))
                Text("Today's Meals")
                    .font(.rounded(16, .black))
                    .foregroundStyle(Theme.ink)
            }
            .padding(.bottom, 6)

            if meals.isEmpty {
                VStack(spacing: 4) {
                    Text("🥣")
                        .font(.system(size: 30))
                        .grayscale(0.6)
                        .opacity(0.7)
                    Text("No meals yet")
                        .font(.rounded(14, .heavy))
                        .foregroundStyle(Theme.mute)
                    Text("Check your first meal to get started!")
                        .font(.rounded(12, .bold))
                        .foregroundStyle(Theme.mute)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.plate, in: .rect(cornerRadius: 16))
            } else {
                ForEach(meals) { meal in
                    Button {
                        open { editingMeal = meal }
                    } label: {
                        MealRow(meal: meal, isHighlighted: meal.id == justAdded?.id)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .cardStyle()
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
