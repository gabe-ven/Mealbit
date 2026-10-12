import SwiftUI

struct MealRow: View {
    let meal: Meal

    private var macroSummary: String {
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0))
        return "P \(meal.protein.formatted(format))g · C \(meal.carbs.formatted(format))g · F \(meal.fat.formatted(format))g"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                Text(macroSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(meal.calories) kcal")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

#Preview {
    List {
        MealRow(meal: Meal.samples[1])
    }
}
