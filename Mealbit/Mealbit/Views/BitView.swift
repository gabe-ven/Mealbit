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
                // Computed from the clock each frame rather than animated, so Bit
                // appears in place instead of drifting there as the screen lays out.
                TimelineView(.animation) { context in
                    idleMotion(image, amount: Self.wave(at: context.date, halfCycle: halfCycle))
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

    /// Smoothly goes 0 → 1 → 0, taking `halfCycle` seconds each way.
    fileprivate static func wave(at date: Date, halfCycle: Double) -> Double {
        let time = date.timeIntervalSinceReferenceDate
        return (1 - cos(time * .pi / halfCycle)) / 2
    }

    /// `amount` runs from 0 (rest) to 1 (fully moved).
    @ViewBuilder
    private func idleMotion(_ content: some View, amount: Double) -> some View {
        switch mood {
        case .hungry, .energized:
            content.offset(y: -size * 0.04 * amount)
        case .happy:
            content.scaleEffect(x: 1 + 0.025 * amount, y: 1 - 0.025 * amount, anchor: .bottom)
        case .thinking:
            content.rotationEffect(.degrees(-3 + 6 * amount), anchor: .bottom)
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
            TimelineView(.animation) { context in
                let amount = BitView.wave(at: context.date, halfCycle: 0.9)
                shape.scaleEffect(0.6 + 0.4 * amount).opacity(0.4 + 0.6 * amount)
            }
        } else {
            shape
        }
    }
}

#Preview {
    VStack(spacing: 20) {
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
