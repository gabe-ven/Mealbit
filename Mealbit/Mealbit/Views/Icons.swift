import SwiftUI

/// Every icon in Mealbit. All are solid, filled glyphs: SF Symbols' filled
/// variants, plus a custom flexed arm because SF Symbols has none.
enum AppIcon {
    case calories, protein, meals
    case camera, pencil, photo, goals, sparkles, info
    case home, progress, profile

    var color: Color {
        switch self {
        case .calories: Theme.calories
        case .protein: Theme.protein
        case .meals: Theme.meals
        default: Theme.blue
        }
    }

    /// The SF Symbol for this icon, or nil when it is custom-drawn.
    fileprivate var symbol: String? {
        switch self {
        case .calories: "flame.fill"
        case .protein: nil
        case .meals: "fork.knife"
        case .camera: "camera.fill"
        case .pencil: "pencil"
        case .photo: "photo.fill"
        case .goals: "target"
        case .sparkles: "sparkles"
        case .info: "info.circle.fill"
        case .home: "house.fill"
        case .progress: "chart.bar.fill"
        case .profile: "person.fill"
        }
    }
}

/// A single filled icon at a consistent visual size.
struct Icon: View {
    let icon: AppIcon
    var size: CGFloat = 22
    /// Overrides the icon's own color, e.g. white on a blue button.
    var color: Color?

    init(_ icon: AppIcon, size: CGFloat = 22, color: Color? = nil) {
        self.icon = icon
        self.size = size
        self.color = color
    }

    var body: some View {
        Group {
            if let symbol = icon.symbol {
                Image(systemName: symbol)
                    .font(.system(size: size, weight: .bold))
            } else {
                FlexedArm()
                    .frame(width: size * 1.1, height: size * 1.1)
            }
        }
        .foregroundStyle(color ?? icon.color)
        .frame(width: size * 1.25, height: size * 1.25)
        .accessibilityHidden(true)
    }
}

/// Filled flexed arm, from Material Design Icons' "arm-flex" (Apache 2.0),
/// drawn on a 24×24 grid.
private struct FlexedArm: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 3, y: 18.34))
        path.addCurve(to: CGPoint(x: 7, y: 3), control1: CGPoint(x: 3, y: 18.34), control2: CGPoint(x: 4, y: 7.09))
        path.addLine(to: CGPoint(x: 12, y: 4))
        path.addLine(to: CGPoint(x: 11, y: 7.09))
        path.addLine(to: CGPoint(x: 9, y: 7.09))
        path.addLine(to: CGPoint(x: 9, y: 14.25))
        path.addLine(to: CGPoint(x: 10, y: 14.25))
        path.addCurve(to: CGPoint(x: 18.64, y: 11.18), control1: CGPoint(x: 12, y: 11.18), control2: CGPoint(x: 16.14, y: 10.06))
        path.addCurve(to: CGPoint(x: 18.64, y: 19.36), control1: CGPoint(x: 21.94, y: 12.71), control2: CGPoint(x: 21.64, y: 17.32))
        path.addCurve(to: CGPoint(x: 3, y: 18.34), control1: CGPoint(x: 16.24, y: 21), control2: CGPoint(x: 9, y: 22.43))
        path.closeSubpath()
        let scale = min(rect.width, rect.height) / 24
        return path.applying(CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            Icon(.calories)
            Icon(.protein)
            Icon(.meals)
            Icon(.goals)
        }
        HStack {
            Icon(.camera)
            Icon(.pencil)
            Icon(.photo)
            Icon(.sparkles)
            Icon(.home)
            Icon(.progress)
            Icon(.profile)
        }
    }
    .padding()
}
