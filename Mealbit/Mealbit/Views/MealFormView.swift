import SwiftData
import SwiftUI

/// Adds a new meal, or edits `meal` when one is passed in.
struct MealFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let meal: Meal?

    @State private var name: String
    @State private var category: MealCategory
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String

    init(meal: Meal? = nil) {
        self.meal = meal
        let gramsFormat = FloatingPointFormatStyle<Double>.number.grouping(.never)
        _name = State(initialValue: meal?.name ?? "")
        _category = State(initialValue: meal?.category ?? .suggested(for: .now))
        _caloriesText = State(initialValue: meal.map { String($0.calories) } ?? "")
        _proteinText = State(initialValue: meal?.protein.formatted(gramsFormat) ?? "")
        _carbsText = State(initialValue: meal?.carbs.formatted(gramsFormat) ?? "")
        _fatText = State(initialValue: meal?.fat.formatted(gramsFormat) ?? "")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var calories: Int? {
        guard let value = try? Int(caloriesText, format: .number), value >= 0 else { return nil }
        return value
    }

    /// Blank means 0 g; anything else must be a non-negative number.
    private func grams(from text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return 0 }
        guard let value = try? Double(trimmed, format: .number), value >= 0 else { return nil }
        return value
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
            && calories != nil
            && grams(from: proteinText) != nil
            && grams(from: carbsText) != nil
            && grams(from: fatText) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Meal name", text: $name)
                        .textInputAutocapitalization(.words)
                    Picker("Category", selection: $category) {
                        ForEach(MealCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }

                Section {
                    numberField("Calories", unit: "kcal", text: $caloriesText, keyboard: .numberPad)
                } footer: {
                    if !caloriesText.isEmpty && calories == nil {
                        Text("Enter calories as a whole number.")
                            .foregroundStyle(.red)
                    }
                }

                Section("Macros") {
                    numberField("Protein", unit: "g", text: $proteinText, keyboard: .decimalPad)
                    numberField("Carbs", unit: "g", text: $carbsText, keyboard: .decimalPad)
                    numberField("Fat", unit: "g", text: $fatText, keyboard: .decimalPad)
                }
            }
            .navigationTitle(meal == nil ? "Add Meal" : "Edit Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private func numberField(
        _ title: String,
        unit: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            Text(unit)
                .foregroundStyle(.secondary)
        }
    }

    private func save() {
        guard canSave, let calories else { return }
        let protein = grams(from: proteinText) ?? 0
        let carbs = grams(from: carbsText) ?? 0
        let fat = grams(from: fatText) ?? 0

        if let meal {
            meal.name = trimmedName
            meal.category = category
            meal.calories = calories
            meal.protein = protein
            meal.carbs = carbs
            meal.fat = fat
        } else {
            modelContext.insert(Meal(
                name: trimmedName,
                category: category,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat
            ))
        }
        dismiss()
    }
}

#Preview("Add") {
    MealFormView()
        .modelContainer(for: Meal.self, inMemory: true)
}

#Preview("Edit") {
    let container = Meal.previewContainer
    let meal = try! container.mainContext.fetch(FetchDescriptor<Meal>()).first!
    MealFormView(meal: meal)
        .modelContainer(container)
}
