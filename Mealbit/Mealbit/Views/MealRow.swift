import SwiftUI

struct MealRow: View {
    let meal: Meal
    var isHighlighted = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(meal.name)
                    .font(.rounded(16, .bold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Text(meal.date, format: .dateTime.hour().minute())
                    .font(.rounded(13, .medium))
                    .foregroundStyle(Theme.mute)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(meal.calories.formatted()) cal")
                    .font(.rounded(16, .heavy))
                    .foregroundStyle(Theme.ink)
                Text("\(Int(meal.protein.rounded())) g protein")
                    .font(.rounded(13, .medium))
                    .foregroundStyle(Theme.mute)
            }
            .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(isHighlighted ? Theme.soft : .clear, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isHighlighted ? Theme.blue : .clear, lineWidth: 2))
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack {
        MealRow(meal: Meal.samples[1])
        MealRow(meal: Meal.samples[0], isHighlighted: true)
    }
    .padding()
}
