import SwiftUI
import UIKit

/// Mealbit's colors, each with a light and dark value.
enum Theme {
    /// The brand blue. Read from the asset so it stays blue inside views that change their tint.
    static let blue = Color("AccentColor")
    static let blueDeep = Color(light: 0x1B63DB, dark: 0x2A64C8)
    static let blueSoft = Color(light: 0xA9CBFF, dark: 0x3B5F99)

    static let background = Color(light: 0xF4F8FF, dark: 0x0B1424)
    static let card = Color(light: 0xFFFFFF, dark: 0x14213A)
    static let soft = Color(light: 0xE6F0FF, dark: 0x1C2D4D)
    static let plate = Color(light: 0xF7FAFF, dark: 0x182844)
    static let line = Color(light: 0xDCE6F5, dark: 0x24385A)
    static let ink = Color(light: 0x0F2547, dark: 0xEEF4FF)
    static let mute = Color(light: 0x5A6B88, dark: 0x9DB0CF)

    static let orange = Color(light: 0xFF9F1C, dark: 0xFFAA3B)
    static let orangeSoft = Color(light: 0xFFD9A3, dark: 0x6B4A1E)
    static let amber = Color(light: 0xFFB547, dark: 0xE6A23C)
    static let amberBackground = Color(light: 0xFFF4DF, dark: 0x3A2E17)
    static let fitBackground = Color(light: 0xE8F8EE, dark: 0x16352A)
    static let danger = Color(light: 0xD93D42, dark: 0xFF7A7E)
    /// Lip under a disabled primary button.
    static let disabledEdge = Color(light: 0xC5D3E8, dark: 0x1A2A45)

    /// Soft navy shadow used under cards.
    static let shadow = Color(light: 0x0F2547, dark: 0x000000).opacity(0.05)
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Font {
    /// The app's rounded type, used everywhere.
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Buttons

extension View {
    /// Duolingo-style "chunky" look: a solid face sitting on a darker lip.
    /// When pressed, the face sinks down onto the lip.
    func chunky<S: InsettableShape>(
        _ shape: S, face: Color, edge: Color, border: Color? = nil, depth: CGFloat = 4, isPressed: Bool = false
    ) -> some View {
        self
            .background { shape.fill(face) }
            .overlay {
                if let border { shape.strokeBorder(border, lineWidth: 2) }
            }
            .offset(y: isPressed ? depth : 0)
            .background { shape.fill(edge).offset(y: depth) }
            .padding(.bottom, depth)
    }
}

/// Any button drawn with the chunky face-and-lip look.
struct ChunkyButtonStyle<S: InsettableShape>: ButtonStyle {
    let shape: S
    let face: Color
    let edge: Color
    var border: Color? = nil
    var depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .chunky(shape, face: face, edge: edge, border: border, depth: depth, isPressed: configuration.isPressed)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// Full-width solid blue button.
struct PrimaryButtonStyle: ButtonStyle {
    var height: CGFloat = 58
    var fontSize: CGFloat = 19

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rounded(fontSize, .black))
            .foregroundStyle(isEnabled ? .white : Theme.mute)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .chunky(
                RoundedRectangle(cornerRadius: 20),
                face: isEnabled ? Theme.blue : Theme.line,
                edge: isEnabled ? Theme.blueDeep : Theme.disabledEdge,
                isPressed: configuration.isPressed
            )
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// Full-width white button with a light border and blue text.
struct SecondaryButtonStyle: ButtonStyle {
    var height: CGFloat = 52

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rounded(17, .heavy))
            .foregroundStyle(Theme.blue)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .chunky(
                RoundedRectangle(cornerRadius: 20),
                face: Theme.card, edge: Theme.line, border: Theme.line,
                isPressed: configuration.isPressed
            )
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// Plain bold text button, such as "Skip and use defaults".
struct TextButtonStyle: ButtonStyle {
    var color: Color = Theme.blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rounded(16, .heavy))
            .foregroundStyle(color)
            .frame(height: 46)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// Round white button, used for back and close.
struct CircleButton: View {
    let systemImage: String
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(Theme.ink)
                .frame(width: size, height: size)
        }
        .buttonStyle(ChunkyButtonStyle(shape: Circle(), face: Theme.card, edge: Theme.line, border: Theme.line, depth: 3))
    }
}

/// Round light blue +/– button.
struct StepButton: View {
    let systemImage: String
    var size: CGFloat = 52
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .heavy))
                .foregroundStyle(Theme.blue)
                .frame(width: size, height: size)
        }
        .buttonStyle(ChunkyButtonStyle(shape: Circle(), face: Theme.soft, edge: Theme.blueSoft, depth: 3))
    }
}

// MARK: - Cards

extension View {
    /// White card with a soft shadow under the card only, not its contents.
    func cardStyle(radius: CGFloat = 22) -> some View {
        background {
            RoundedRectangle(cornerRadius: radius)
                .fill(Theme.card)
                .shadow(color: Theme.shadow, radius: 7, y: 4)
        }
    }

    /// The flat "raised" look: the shape sits on a 2pt line-colored edge.
    func raised<S: Shape>(_ shape: S, fill: Color = Theme.card) -> some View {
        background {
            ZStack {
                shape.fill(Theme.line).offset(y: 2)
                shape.fill(fill)
            }
        }
    }
}

// MARK: - Photos

/// A photo that fills a fixed-height box at the available width, cropped to fit.
struct FilledImage: View {
    let image: Image
    let height: CGFloat

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                image
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }
}

// MARK: - Progress bars

/// 12pt capsule bar filled to `fraction`.
struct CapsuleBar: View {
    let fraction: Double
    var height: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(Theme.soft)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Theme.blue)
                        .frame(width: proxy.size.width * min(max(fraction, 0), 1))
                }
        }
        .frame(height: height)
        .animation(.spring(duration: 0.9), value: fraction)
    }
}

/// Bar split into already eaten, this meal, and (for calories) the part over the goal.
struct StackedBar: View {
    let goal: Double
    let eaten: Double
    let meal: Double
    /// Whether the part past the goal is drawn in amber.
    let showsOver: Bool

    private var total: Double { eaten + meal }
    private var scale: Double { max(goal, total, 1) }

    var body: some View {
        let eatenIn = min(eaten, goal)
        let mealIn = showsOver ? max(0, min(total, goal) - eaten) : meal
        let over = showsOver ? max(0, total - eatenIn - mealIn) : 0

        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.soft)
                HStack(spacing: 0) {
                    Rectangle().fill(Theme.blue).frame(width: width * eatenIn / scale)
                    Rectangle().fill(Theme.blueSoft).frame(width: width * mealIn / scale)
                    Rectangle().fill(Theme.amber).frame(width: width * over / scale)
                }
                .clipShape(.capsule)
                if total > goal {
                    Rectangle()
                        .fill(Theme.ink)
                        .frame(width: 3)
                        .offset(x: width * goal / scale - 1.5)
                }
            }
        }
        .frame(height: 12)
        .animation(.spring(duration: 0.6), value: meal)
    }
}

// MARK: - Forms

/// Labeled rounded text field used in sheets.
struct InputField: View {
    let label: String
    @Binding var text: String
    var placeholder = ""
    var keyboard: UIKeyboardType = .default
    var border: Color = Theme.line
    var fontSize: CGFloat = 17

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.rounded(13, .heavy))
                .foregroundStyle(Theme.mute)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .font(.rounded(fontSize, .heavy))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Theme.card, in: .rect(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 2))
        }
    }
}

/// Title row and close button at the top of a sheet.
struct SheetHeader: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.rounded(26, .black))
                .foregroundStyle(Theme.ink)
            Spacer()
            CircleButton(systemImage: "xmark", size: 40, action: onClose)
        }
        .padding(.top, 20)
    }
}

/// A daily goal with minus and plus buttons.
struct GoalStepperCard: View {
    let title: String
    let dot: Color
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let step: Int

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Circle().fill(dot).frame(width: 10, height: 10)
                Text(title)
                    .font(.rounded(15, .heavy))
                    .foregroundStyle(Theme.mute)
                Spacer()
            }
            HStack {
                stepButton("minus", enabled: value > range.lowerBound) { value = max(range.lowerBound, value - step) }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(value.formatted())
                        .font(.rounded(46, .black))
                        .monospacedDigit()
                        .foregroundStyle(Theme.ink)
                        .contentTransition(.numericText(value: Double(value)))
                    Text(unit)
                        .font(.rounded(18, .heavy))
                        .foregroundStyle(Theme.mute)
                }
                Spacer()
                stepButton("plus", enabled: value < range.upperBound) { value = min(range.upperBound, value + step) }
            }
            Text("\(range.lowerBound.formatted()) to \(range.upperBound.formatted()) \(unit)")
                .font(.rounded(13, .bold))
                .foregroundStyle(Theme.mute)
        }
        .padding(16)
        .raised(RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(value) \(unit)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = min(range.upperBound, value + step)
            case .decrement: value = max(range.lowerBound, value - step)
            @unknown default: break
            }
        }
    }

    private func stepButton(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        StepButton(systemImage: symbol) {
            withAnimation(.snappy) { action() }
        }
        .buttonRepeatBehavior(.enabled)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }
}

/// Equal-width segmented choice, such as the portion picker.
struct SegmentPicker<Value: Hashable>: View {
    let options: [(label: String, value: Value)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.value) { option in
                let isSelected = option.value == selection
                Button {
                    selection = option.value
                } label: {
                    Text(option.label)
                        .font(.rounded(17, .black))
                        .foregroundStyle(isSelected ? .white : Theme.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(ChunkyButtonStyle(
                    shape: RoundedRectangle(cornerRadius: 14),
                    face: isSelected ? Theme.blue : Theme.card,
                    edge: isSelected ? Theme.blueDeep : Theme.line,
                    border: isSelected ? nil : Theme.line,
                    depth: 3
                ))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}
