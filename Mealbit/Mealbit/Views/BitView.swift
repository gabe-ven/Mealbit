import SwiftUI

/// Bit, Mealbit's mascot. Its mood follows how much of today's calories are eaten.
struct BitView: View {
    enum Mood {
        case hungry, happy, energized, thinking, oops

        /// Under 20% of the calorie goal is hungry, under 70% happy, then energized.
        static func forCalories(eaten: Int, goal: Int) -> Mood {
            let fraction = goal > 0 ? Double(eaten) / Double(goal) : 0
            if fraction < 0.2 { return .hungry }
            if fraction < 0.7 { return .happy }
            return .energized
        }

        fileprivate var imageName: String {
            switch self {
            case .hungry: "BitHungry"
            case .happy: "BitHappy"
            case .energized: "BitEnergized"
            case .thinking: "BitThinking"
            case .oops: "BitOops"
            }
        }

        fileprivate var accessibilityLabel: String {
            switch self {
            case .hungry: "Bit, hungry"
            case .happy: "Bit, happy"
            case .energized: "Bit, energized"
            case .thinking: "Bit, thinking"
            case .oops: "Bit, surprised"
            }
        }
    }

    let mood: Mood
    var size: CGFloat = 160
    var sparkle = false
    var animates = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isAnimated: Bool { animates && !reduceMotion }

    var body: some View {
        Group {
            if isAnimated {
                image.phaseAnimator([false, true]) { content, phase in
                    idleMotion(content, phase: phase)
                } animation: { _ in
                    .easeInOut(duration: halfCycle)
                }
            } else {
                image
            }
        }
        .frame(width: size, height: size)
        .overlay(alignment: .topLeading) {
            if sparkle {
                Sparkle(size: max(5, size * 0.07), isAnimated: isAnimated)
                    .offset(x: size * 0.06, y: size * 0.16)
            }
        }
        .animation(.easeOut(duration: 0.4), value: mood)
        .accessibilityElement()
        .accessibilityLabel(mood.accessibilityLabel)
    }

    private var image: some View {
        Image(mood.imageName)
            .resizable()
            .scaledToFit()
    }

    /// Hungry floats, happy breathes, energized floats faster, thinking sways, oops holds still.
    private var halfCycle: Double {
        switch mood {
        case .hungry: 1.6
        case .happy: 1.8
        case .energized: 1.1
        case .thinking: 1.2
        case .oops: 1
        }
    }

    @ViewBuilder
    private func idleMotion(_ content: some View, phase: Bool) -> some View {
        switch mood {
        case .hungry, .energized:
            content.offset(y: phase ? -size * 0.04 : 0)
        case .happy:
            content.scaleEffect(x: phase ? 1.025 : 1, y: phase ? 0.975 : 1, anchor: .bottom)
        case .thinking:
            content.rotationEffect(.degrees(phase ? 3 : -3), anchor: .bottom)
        case .oops:
            content
        }
    }
}

/// Small orange diamond that twinkles next to Bit.
private struct Sparkle: View {
    let size: CGFloat
    let isAnimated: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.22)
            .fill(Color(light: 0xFFB020, dark: 0xFFB020))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
        if isAnimated {
            shape.phaseAnimator([false, true]) { content, phase in
                content.scaleEffect(phase ? 1 : 0.6).opacity(phase ? 1 : 0.4)
            } animation: { _ in .easeInOut(duration: 0.9) }
        } else {
            shape
        }
    }
}

/// White rounded speech bubble with a small tail, used next to Bit.
struct SpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.rounded(15, .bold))
            .foregroundStyle(Theme.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 20).fill(Theme.card)
                    Rectangle()
                        .fill(Theme.card)
                        .frame(width: 14, height: 14)
                        .rotationEffect(.degrees(45))
                        .offset(y: 6)
                }
                .compositingGroup()
                .shadow(color: Theme.ink.opacity(0.06), radius: 7, y: 4)
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpeechBubble(text: "Bit is hungry. Let’s check your first meal!")
        HStack {
            BitView(mood: .hungry, size: 90)
            BitView(mood: .happy, size: 90, sparkle: true)
            BitView(mood: .energized, size: 90)
        }
        HStack {
            BitView(mood: .thinking, size: 90)
            BitView(mood: .oops, size: 90)
        }
    }
    .padding()
    .background(Theme.background)
}
