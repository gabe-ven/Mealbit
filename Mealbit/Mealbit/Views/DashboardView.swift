import SwiftData
import SwiftUI

/// Home: how today is going, the way to check the next meal, and what's been logged.
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

    /// `day` is passed in so the list moves on to the new day at midnight.
    init(day: Date = .now) {
        _meals = Query(filter: Meal.loggedToday(day), sort: \.date, order: .reverse)
    }

    private var caloriesEaten: Int { meals.reduce(0) { $0 + $1.calories } }
    private var proteinEaten: Double { meals.reduce(0) { $0 + $1.protein } }
    private var calorieFraction: Double { calorieGoal > 0 ? Double(caloriesEaten) / Double(calorieGoal) : 0 }
    private var proteinFraction: Double { proteinGoal > 0 ? proteinEaten / Double(proteinGoal) : 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    hero
                    HStack(spacing: 12) {
                        ringTile(.calories, eaten: caloriesEaten.formatted(), goal: calorieGoal.formatted(),
                                 label: "Calories", fraction: calorieFraction)
                        ringTile(.protein, eaten: Int(proteinEaten.rounded()).formatted(), goal: "\(proteinGoal)g",
                                 label: "Protein", fraction: proteinFraction)
                    }
                    VStack(spacing: 2) {
                        Button {
                            open { isCheckingMeal = true }
                        } label: {
                            Label { Text("Check a Meal") } icon: { Icon(.camera, size: 20, color: .white) }
                        }
                        .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
                        Button {
                            open { isEnteringManually = true }
                        } label: {
                            Label { Text("Log Manually") } icon: { Icon(.pencil, size: 15) }
                        }
                        .buttonStyle(TextButtonStyle())
                    }
                    mealsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Theme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Wordmark(size: 30)
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        open { isEditingGoals = true }
                    } label: {
                        Icon(.goals, size: 20)
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

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 6) {
            BitView(
                mood: .forCalories(eaten: caloriesEaten, goal: calorieGoal),
                size: 150,
                sparkle: proteinFraction >= 0.5 && proteinFraction < 1
            )
            .frame(maxWidth: .infinity)
            .background(alignment: .bottom) { HillBackdrop() }

            Text(title)
                .font(.rounded(28, .black))
                .foregroundStyle(Theme.ink)
                .padding(.top, 6)
            Text(subtitle)
                .font(.rounded(16, .bold))
                .foregroundStyle(Theme.ink.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }

    private var title: String {
        if justAdded != nil { return "Yum, added!" }
        switch Calendar.current.component(.hour, from: .now) {
        case 4..<12: return "Good morning!"
        case 12..<17: return "Good afternoon!"
        default: return "Good evening!"
        }
    }

    private var subtitle: String {
        if meals.isEmpty { return "Let’s log your first meal today." }
        let caloriesLeft = calorieGoal - caloriesEaten
        if caloriesLeft < 0 { return "You’re \((-caloriesLeft).formatted()) cal over today’s goal." }
        if proteinFraction >= 1 { return "\(caloriesLeft.formatted()) cal left, and your protein goal is hit." }
        return "You have \(caloriesLeft.formatted()) cal left today."
    }

    // MARK: - Progress

    private func ringTile(_ icon: AppIcon, eaten: String, goal: String, label: String, fraction: Double) -> some View {
        ZStack {
            ProgressRing(fraction: fraction, color: icon.color, lineWidth: 9)
            VStack(spacing: 2) {
                Icon(icon, size: 24)
                (Text(eaten).font(.rounded(17, .black)).foregroundStyle(Theme.ink)
                    + Text(" / \(goal)").font(.rounded(15, .bold)).foregroundStyle(Theme.ink.opacity(0.8)))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.rounded(13, .bold))
                    .foregroundStyle(Theme.mute)
            }
            .padding(.horizontal, 18)
        }
        .frame(width: 140, height: 140)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle(radius: 24)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Today's meals

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today’s Meals")
                    .font(.rounded(19, .black))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(meals.count == 1 ? "1 meal" : "\(meals.count) meals")
                    .font(.rounded(14, .bold))
                    .foregroundStyle(Theme.mute)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)

            Group {
                if meals.isEmpty {
                    Button {
                        open { isCheckingMeal = true }
                    } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("No meals yet")
                                    .font(.rounded(15, .heavy))
                                    .foregroundStyle(Theme.ink)
                                Text("Your meals will show up here!")
                                    .font(.rounded(13, .bold))
                                    .foregroundStyle(Theme.mute)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Theme.mute)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack(spacing: 2) {
                        ForEach(meals) { meal in
                            Button {
                                open { editingMeal = meal }
                            } label: {
                                MealRow(meal: meal, isHighlighted: meal.id == justAdded?.id)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)
                }
            }
            .cardStyle(radius: 20)
        }
    }
}

/// Soft hill and clouds behind Bit.
private struct HillBackdrop: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            cloud.scaleEffect(0.9).offset(x: -150, y: -34)
            cloud.offset(x: 150, y: -50)
            Ellipse()
                .fill(Theme.soft)
                .frame(width: 560, height: 170)
                .offset(y: 100)
        }
        .frame(height: 120)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var cloud: some View {
        ZStack(alignment: .bottom) {
            Circle().frame(width: 54, height: 54).offset(x: -26)
            Circle().frame(width: 72, height: 72).offset(y: -10)
            Circle().frame(width: 50, height: 50).offset(x: 30)
        }
        .foregroundStyle(Theme.soft.opacity(0.8))
    }
}

/// A circular track that fills clockwise from the top.
struct ProgressRing: View {
    let fraction: Double
    var color: Color = Theme.blue
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.soft, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(fraction, 0.001), 1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(lineWidth / 2)
        .animation(.spring(duration: 0.9), value: fraction)
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
