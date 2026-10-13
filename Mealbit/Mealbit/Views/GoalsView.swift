import SwiftUI

struct GoalsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein

    @State private var caloriesText = ""
    @State private var proteinText = ""

    private var calories: Int? { validNumber(caloriesText, in: NutritionGoals.calorieRange) }
    private var protein: Int? { validNumber(proteinText, in: NutritionGoals.proteinRange) }

    private func validNumber(_ text: String, in range: ClosedRange<Int>) -> Int? {
        guard let value = try? Int(text, format: .number), range.contains(value) else { return nil }
        return value
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    goalField("Calories", unit: "kcal", text: $caloriesText)
                    goalField("Protein", unit: "g", text: $proteinText)
                } footer: {
                    if !caloriesText.isEmpty && calories == nil {
                        rangeHint("Calories", NutritionGoals.calorieRange, unit: "kcal")
                    } else if !proteinText.isEmpty && protein == nil {
                        rangeHint("Protein", NutritionGoals.proteinRange, unit: "g")
                    } else {
                        Text("You can change these any time.")
                    }
                }
            }
            .navigationTitle("Daily Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(calories == nil || protein == nil)
                }
            }
            .onAppear {
                caloriesText = String(calorieGoal)
                proteinText = String(proteinGoal)
            }
        }
    }

    private func goalField(_ title: String, unit: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField(title, text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            Text(unit)
                .foregroundStyle(.secondary)
        }
    }

    private func rangeHint(_ name: String, _ range: ClosedRange<Int>, unit: String) -> some View {
        Text("\(name) goal must be between \(range.lowerBound) and \(range.upperBound) \(unit).")
            .foregroundStyle(.red)
    }

    private func save() {
        guard let calories, let protein else { return }
        calorieGoal = calories
        proteinGoal = protein
        dismiss()
    }
}

#Preview {
    GoalsView()
}
