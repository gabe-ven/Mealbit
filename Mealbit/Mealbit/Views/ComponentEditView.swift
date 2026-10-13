import SwiftUI

/// "Fix this item": corrects one item of a meal. Shows and returns the amounts as
/// the user currently sees them; the returned item has a scale of 1.
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
        ScrollView {
            VStack(spacing: 12) {
                SheetHeader(title: "Fix this item") { dismiss() }
                InputField(label: "Item", text: $name, placeholder: "e.g. Chicken Burrito Bowl")
                HStack(spacing: 12) {
                    InputField(label: "Amount", text: $quantityText, keyboard: .decimalPad)
                    InputField(label: "Unit", text: $unit)
                }
                HStack(spacing: 12) {
                    InputField(
                        label: "Calories (kcal)", text: $caloriesText, keyboard: .numberPad,
                        border: Theme.blueSoft, fontSize: 22
                    )
                    InputField(
                        label: "Protein (g)", text: $proteinText, keyboard: .decimalPad,
                        border: Theme.orangeSoft, fontSize: 22
                    )
                }
                HStack(spacing: 12) {
                    InputField(label: "Carbs (g)", text: $carbsText, placeholder: "Optional", keyboard: .decimalPad)
                    InputField(label: "Fat (g)", text: $fatText, placeholder: "Optional", keyboard: .decimalPad)
                }
                Button("Save") {
                    guard let edited else { return }
                    onSave(edited)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
                .disabled(edited == nil)
                .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }
}

#Preview {
    Text("Edit Meal")
        .sheet(isPresented: .constant(true)) {
            ComponentEditView(component: MealDraft.sampleEstimate.components[0], onSave: { _ in })
        }
}
