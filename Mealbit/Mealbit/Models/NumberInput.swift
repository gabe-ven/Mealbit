import Foundation

/// Parses user-entered numbers for nutrition forms.
enum NumberInput {
    /// Blank means 0; anything else must be a non-negative number.
    static func nonNegative(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return 0 }
        guard let value = try? Double(trimmed, format: .number), value >= 0 else { return nil }
        return value
    }

    static let editingFormat = FloatingPointFormatStyle<Double>.number.grouping(.never).precision(.fractionLength(0...1))
}
