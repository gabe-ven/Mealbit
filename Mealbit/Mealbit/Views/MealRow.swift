import SwiftUI

struct MealRow: View {
    let meal: Meal
    var isHighlighted = false

    var body: some View {
        HStack(spacing: 12) {
            Text(meal.category.emoji)
                .font(.system(size: 24))
                .frame(width: 52, height: 52)
                .background(Theme.soft, in: .rect(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(.rounded(14, .heavy))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Text(meal.date, format: .dateTime.hour().minute())
                    .font(.rounded(12, .bold))
                    .foregroundStyle(Theme.mute)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(meal.calories.formatted()) cal")
                    .font(.rounded(14, .black))
                    .foregroundStyle(Theme.ink)
                Text("\(Int(meal.protein.rounded()))g protein")
                    .font(.rounded(12, .bold))
                    .foregroundStyle(Theme.mute)
            }
            .monospacedDigit()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(isHighlighted ? Theme.soft : .clear, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isHighlighted ? Theme.blue : .clear, lineWidth: 2))
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

extension MealCategory {
    var emoji: String {
        switch self {
        case .breakfast: "🥣"
        case .lunch: "🌯"
        case .dinner: "🍽️"
        case .snack: "🍎"
        }
    }
}

#Preview {
    VStack {
        MealRow(meal: Meal.samples[1])
        MealRow(meal: Meal.samples[0], isHighlighted: true)
    }
    .padding()
}
