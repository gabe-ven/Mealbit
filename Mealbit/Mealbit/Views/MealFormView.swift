import SwiftData
import SwiftUI

/// "Log Manually" for a new meal, which leads to its result, or "Edit meal" for a
/// logged one when `meal` is passed in.
struct MealFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let meal: Meal?
    @State private var previewDraft: MealDraft?
    @State private var showsCarbsAndFat: Bool

    @State private var name: String
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String

    init(meal: Meal? = nil) {
        self.meal = meal
        let gramsFormat = FloatingPointFormatStyle<Double>.number.grouping(.never).precision(.fractionLength(0...1))
        _showsCarbsAndFat = State(initialValue: meal != nil)
        _name = State(initialValue: meal?.name ?? "")
        _caloriesText = State(initialValue: meal.map { String($0.calories) } ?? "")
        _proteinText = State(initialValue: meal?.protein.formatted(gramsFormat) ?? "")
        _carbsText = State(initialValue: meal?.carbs.formatted(gramsFormat) ?? "")
        _fatText = State(initialValue: meal?.fat.formatted(gramsFormat) ?? "")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The entered values, or nil while calories are missing or any field is invalid.
    private var draft: MealDraft? {
        guard let calories = try? Int(caloriesText, format: .number), calories >= 0,
              let protein = NumberInput.nonNegative(proteinText),
              let carbs = NumberInput.nonNegative(carbsText),
              let fat = NumberInput.nonNegative(fatText)
        else { return nil }
        return MealDraft(
            name: trimmedName.isEmpty ? "Meal" : trimmedName,
            category: meal?.category ?? .suggested(for: .now),
            calories: calories, protein: protein, carbs: carbs, fat: fat
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    SheetHeader(title: meal == nil ? "Log Manually" : "Edit meal") { dismiss() }
                    InputField(label: "Meal name", text: $name, placeholder: "e.g. Chicken Burrito Bowl")
                        .textInputAutocapitalization(.words)
                    HStack(spacing: 12) {
                        InputField(
                            label: "Calories (kcal)", text: $caloriesText, placeholder: "0",
                            keyboard: .numberPad, border: Theme.blueSoft, fontSize: 22
                        )
                        InputField(
                            label: "Protein (g)", text: $proteinText, placeholder: "0",
                            keyboard: .decimalPad, border: Theme.orangeSoft, fontSize: 22
                        )
                    }
                    if showsCarbsAndFat {
                        HStack(spacing: 12) {
                            InputField(label: "Carbs (g)", text: $carbsText, placeholder: "Optional", keyboard: .decimalPad)
                            InputField(label: "Fat (g)", text: $fatText, placeholder: "Optional", keyboard: .decimalPad)
                        }
                    } else {
                        Button("+ Add carbs and fat") { showsCarbsAndFat = true }
                            .buttonStyle(TextButtonStyle())
                    }

                    if meal == nil {
                        Button("See How It Fits") { previewDraft = draft }
                            .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
                            .disabled(draft == nil)
                            .padding(.top, 6)
                    } else {
                        Button("Save", action: saveEdits)
                            .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
                            .disabled(draft == nil)
                            .padding(.top, 6)
                        Button("Remove from today", action: remove)
                            .buttonStyle(TextButtonStyle(color: Theme.danger))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $previewDraft) { draft in
                MealPreviewView(draft: draft, onFinish: { dismiss() })
                    .toolbar(.visible, for: .navigationBar)
            }
        }
        .tint(Theme.ink)
        .presentationDragIndicator(.visible)
    }

    private func saveEdits() {
        guard let meal, let draft else { return }
        meal.name = draft.name
        meal.calories = draft.calories
        meal.protein = draft.protein
        meal.carbs = draft.carbs
        meal.fat = draft.fat
        dismiss()
    }

    private func remove() {
        guard let meal else { return }
        modelContext.delete(meal)
        dismiss()
    }
}

#Preview("Log Manually") {
    MealFormView()
        .modelContainer(for: Meal.self, inMemory: true)
}

#Preview("Edit meal") {
    let container = Meal.previewContainer
    let meal = try! container.mainContext.fetch(FetchDescriptor<Meal>()).first!
    MealFormView(meal: meal)
        .modelContainer(container)
}
