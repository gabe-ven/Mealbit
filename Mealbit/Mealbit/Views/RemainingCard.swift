import SwiftUI

/// Large "left today" numbers for the two daily goals.
struct RemainingCard: View {
    let caloriesEaten: Int
    let calorieGoal: Int
    let proteinEaten: Double
    let proteinGoal: Int

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            GoalColumn(
                left: Double(calorieGoal - caloriesEaten),
                eaten: Double(caloriesEaten),
                goal: Double(calorieGoal),
                unit: "kcal",
                color: .green,
                overIsWarning: true
            )
            GoalColumn(
                left: Double(proteinGoal) - proteinEaten,
                eaten: proteinEaten,
                goal: Double(proteinGoal),
                unit: "g protein",
                color: .blue,
                overIsWarning: false
            )
        }
        .padding(.vertical, 8)
    }
}

private struct GoalColumn: View {
    let left: Double
    let eaten: Double
    let goal: Double
    let unit: String
    let color: Color
    let overIsWarning: Bool

    private var isOver: Bool { left < 0 }
    private var showsWarning: Bool { isOver && overIsWarning }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(abs(left), format: .number.precision(.fractionLength(0)))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(showsWarning ? .orange : .primary)
            Text("\(unit) \(isOver ? "over" : "left")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ProgressView(value: min(eaten, goal), total: max(goal, 1))
                .tint(showsWarning ? .orange : color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        RemainingCard(caloriesEaten: 550, calorieGoal: 2000, proteinEaten: 58, proteinGoal: 150)
        RemainingCard(caloriesEaten: 2200, calorieGoal: 2000, proteinEaten: 160, proteinGoal: 150)
    }
}
