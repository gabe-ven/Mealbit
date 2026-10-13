import SwiftUI

/// Corrects one item of a meal preview. Shows and returns the amounts as the
/// user currently sees them; the returned component has a scale of 1.
struct ComponentEditView: View {
    let onSave: (MealComponent) -> Void

    @Environment(\.dismiss) private var dismiss
    private let id: UUID
    @State private var name: String
    @State private var quantityText: String
    @State private var unit: String
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String

    init(component: MealComponent, onSave: @escaping (MealComponent) -> Void) {
        self.onSave = onSave
        let format = NumberInput.editingFormat
        id = component.id
        _name = State(initialValue: component.name)
        _quantityText = State(initialValue: component.adjustedQuantity.formatted(format))
        _unit = State(initialValue: component.unit)
        _caloriesText = State(initialValue: component.adjustedCalories.formatted(format.precision(.fractionLength(0))))
        _proteinText = State(initialValue: component.adjustedProtein.formatted(format))
        _carbsText = State(initialValue: component.adjustedCarbs.formatted(format))
        _fatText = State(initialValue: component.adjustedFat.formatted(format))
    }

    /// The entered values, or nil while any field is invalid.
    private var edited: MealComponent? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let quantity = NumberInput.nonNegative(quantityText), quantity > 0,
              let calories = NumberInput.nonNegative(caloriesText),
              let protein = NumberInput.nonNegative(proteinText),
              let carbs = NumberInput.nonNegative(carbsText),
              let fat = NumberInput.nonNegative(fatText)
        else { return nil }
        return MealComponent(
            id: id, name: trimmedName, quantity: quantity,
            unit: unit.trimmingCharacters(in: .whitespaces),
            calories: calories, protein: protein, carbs: carbs, fat: fat
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item name", text: $name)
                        .textInputAutocapitalization(.sentences)
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 80)
                        TextField("unit", text: $unit)
                            .textInputAutocapitalization(.never)
                            .frame(maxWidth: 70)
                    }
                }

                Section {
                    NumberField(title: "Calories", unit: "kcal", text: $caloriesText, keyboard: .numberPad)
                    NumberField(title: "Protein", unit: "g", text: $proteinText)
                    NumberField(title: "Carbs", unit: "g", text: $carbsText)
                    NumberField(title: "Fat", unit: "g", text: $fatText)
                } footer: {
                    Text("Enter values for the amount above.")
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        guard let edited else { return }
                        onSave(edited)
                        dismiss()
                    }
                    .disabled(edited == nil)
                }
            }
        }
    }
}

#Preview {
    ComponentEditView(component: MealDraft.sampleEstimate.components[0], onSave: { _ in })
}
