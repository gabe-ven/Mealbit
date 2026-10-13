import SwiftUI

/// "Edit Meal" sheet over the result: name, overall portion, and each item.
/// Everything is recalculated on the device; the AI is never asked again.
struct AdjustMealView: View {
    @Binding var draft: MealDraft
    @Binding var portion: Double

    @Environment(\.dismiss) private var dismiss
    @State private var fixingItem: MealComponent?

    private static let portions: [(label: String, value: Double)] = [
        ("½×", 0.5), ("1×", 1), ("1½×", 1.5), ("2×", 2),
    ]

    private var meal: MealDraft { draft.scaled(by: portion) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SheetHeader(title: "Edit Meal") { dismiss() }
                InputField(label: "Meal name", text: $draft.name, placeholder: "e.g. Chicken Burrito Bowl")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Portion")
                        .font(.rounded(13, .heavy))
                        .foregroundStyle(Theme.mute)
                    SegmentPicker(options: Self.portions, selection: $portion)
                }

                itemsCard

                Text("Now ≈ \(meal.calories.formatted()) kcal · ≈ \(Int(meal.protein.rounded())) g protein")
                    .font(.rounded(13, .bold))
                    .foregroundStyle(Theme.mute)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)

                Button("Done") { dismiss() }
                    .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
        .sheet(item: $fixingItem) { item in
            ComponentEditView(component: item, onSave: replaceComponent)
        }
    }

    private var itemsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("What Bit found")
                    .font(.rounded(15, .black))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("Tap an item to fix it")
                    .font(.rounded(12, .heavy))
                    .foregroundStyle(Theme.mute)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            ForEach($draft.components) { $component in
                Divider().overlay(Theme.line)
                itemRow($component)
            }
        }
        .cardStyle(radius: 20)
    }

    private func itemRow(_ component: Binding<MealComponent>) -> some View {
        var shown = component.wrappedValue
        shown.scale *= portion
        let isRemoved = shown.scale == 0

        return HStack(spacing: 8) {
            Button {
                fixingItem = shown
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(shown.name)
                            .font(.rounded(15, .heavy))
                            .foregroundStyle(Theme.ink)
                        if shown.isEdited {
                            Text("Edited")
                                .font(.rounded(11, .black))
                                .foregroundStyle(Theme.blue)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Theme.soft, in: .capsule)
                        }
                    }
                    Text(isRemoved ? "Removed" : "\(amount(shown)) · ≈ \(Int(shown.adjustedCalories.rounded())) kcal")
                        .font(.rounded(13, .bold))
                        .foregroundStyle(Theme.mute)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            stepButton("minus", label: "Less \(shown.name)", enabled: component.wrappedValue.scale > 0) {
                component.wrappedValue.scale = max(0, component.wrappedValue.scale - 0.5)
            }
            stepButton("plus", label: "More \(shown.name)", enabled: component.wrappedValue.scale < 4) {
                component.wrappedValue.scale = min(4, component.wrappedValue.scale + 0.5)
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .padding(.vertical, 9)
        .opacity(isRemoved ? 0.45 : 1)
    }

    private func stepButton(_ symbol: String, label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Theme.blue)
                .frame(width: 40, height: 40)
                .background(Theme.soft, in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
        .accessibilityLabel(label)
    }

    private func amount(_ component: MealComponent) -> String {
        "\(component.adjustedQuantity.formatted(.number.precision(.fractionLength(0...2)))) \(component.unit)"
    }

    /// Stores an edited item, undoing the overall portion so the values the user
    /// typed are exactly what they see.
    private func replaceComponent(_ edited: MealComponent) {
        guard let index = draft.components.firstIndex(where: { $0.id == edited.id }) else { return }
        var base = edited
        base.quantity /= portion
        base.calories /= portion
        base.protein /= portion
        base.carbs /= portion
        base.fat /= portion
        base.isEdited = true
        draft.components[index] = base
        if draft.components.count == 1 {
            draft.name = base.name
        }
    }
}

#Preview {
    Text("Result")
        .sheet(isPresented: .constant(true)) {
            AdjustMealView(draft: .constant(.sampleEstimate), portion: .constant(1))
        }
}
