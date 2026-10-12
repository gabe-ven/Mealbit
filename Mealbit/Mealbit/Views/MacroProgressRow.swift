import SwiftUI

struct MacroProgressRow: View {
    let name: String
    let consumed: Double
    let goal: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(consumed, format: .number.precision(.fractionLength(0))) / \(goal, format: .number.precision(.fractionLength(0))) g")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            ProgressView(value: min(consumed, goal), total: goal)
                .tint(color)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        MacroProgressRow(name: "Protein", consumed: 82, goal: 150, color: .blue)
        MacroProgressRow(name: "Carbs", consumed: 140, goal: 200, color: .orange)
        MacroProgressRow(name: "Fat", consumed: 70, goal: 65, color: .pink)
    }
}
