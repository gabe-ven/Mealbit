import SwiftUI

struct CalorieSummaryCard: View {
    let consumed: Int
    let goal: Int

    private var remaining: Int { goal - consumed }
    private var isOverGoal: Bool { remaining < 0 }

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(consumed) / Double(goal), 1)
    }

    var body: some View {
        HStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(isOverGoal ? Color.orange : Color.green,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(abs(remaining))")
                        .font(.title2.bold())
                        .monospacedDigit()
                    Text(isOverGoal ? "over" : "left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 110, height: 110)

            VStack(alignment: .leading, spacing: 12) {
                summaryLine(title: "Eaten", value: consumed)
                summaryLine(title: "Goal", value: goal)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private func summaryLine(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value) kcal")
                .font(.headline)
                .monospacedDigit()
        }
    }
}

#Preview {
    List {
        CalorieSummaryCard(consumed: 1240, goal: 2000)
        CalorieSummaryCard(consumed: 2350, goal: 2000)
    }
}
