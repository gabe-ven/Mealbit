import SwiftData
import SwiftUI

/// A photo the user wants to check.
struct MealPhoto: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage

    static func == (lhs: MealPhoto, rhs: MealPhoto) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Estimates the meal in `photo`, then shows its result.
struct MealAnalysisView: View {
    let photo: UIImage
    /// Closes the whole check: after logging, discarding, or cancelling.
    let onFinish: () -> Void
    let onRetakePhoto: () -> Void
    let onEnterManually: () -> Void

    @State private var draft: MealDraft?
    @State private var error: MealEstimateError?

    var body: some View {
        if let draft {
            MealPreviewView(draft: draft, photo: photo, onFinish: onFinish)
        } else {
            analyzing
        }
    }

    private var analyzing: some View {
        VStack(spacing: 0) {
            ScanningPhoto(photo: photo, isScanning: error == nil)

            BitView(mood: error == nil ? .thinking : .oops, size: 116)
                .padding(6)
                .background(Theme.background, in: .circle)
                .padding(.top, -58)

            VStack(spacing: 8) {
                Text(error == nil ? "Bit is taking a look…" : "Couldn't Estimate")
                    .font(.rounded(28, .black))
                    .foregroundStyle(Theme.ink)
                Text(error?.localizedDescription
                     ?? "Estimating calories and protein from your photo. This takes a few seconds.")
                    .font(.rounded(16, .bold))
                    .foregroundStyle(Theme.mute)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .padding(.top, 8)

            Spacer()

            if let error {
                errorActions(for: error)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Theme.background)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: onFinish)
                    .font(.rounded(16, .heavy))
                    .foregroundStyle(Theme.ink)
            }
        }
        .task(id: error == nil) {
            guard error == nil else { return }
            await estimate()
        }
    }

    @ViewBuilder
    private func errorActions(for error: MealEstimateError) -> some View {
        switch error {
        case .notFood:
            Button("Take Another Photo", action: onRetakePhoto)
                .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
        case .network, .server:
            Button("Try Again") { self.error = nil }
                .buttonStyle(PrimaryButtonStyle(height: 60, fontSize: 20))
        }
        if error != .network {
            Button("Enter it manually", action: onEnterManually)
                .buttonStyle(TextButtonStyle())
                .padding(.top, 6)
        }
    }

    private func estimate() async {
        do {
            draft = try await MealEstimator.estimate(from: photo)
        } catch let estimateError as MealEstimateError {
            withAnimation { error = estimateError }
        } catch {
            // Cancelled because the screen closed.
        }
    }
}

/// The meal photo with a light band sweeping down while it's being analyzed.
private struct ScanningPhoto: View {
    let photo: UIImage
    let isScanning: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bandAtBottom = false

    var body: some View {
        FilledImage(image: Image(uiImage: photo), height: 290)
            .saturation(isScanning ? 1 : 0.3)
            .brightness(isScanning ? 0 : -0.05)
            .overlay {
                if isScanning && !reduceMotion {
                    GeometryReader { proxy in
                        LinearGradient(
                            colors: [.clear, Theme.blue.opacity(0.38), .white.opacity(0.9)],
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: proxy.size.height * 0.3)
                        .offset(y: bandAtBottom ? proxy.size.height : -proxy.size.height * 0.3)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                            bandAtBottom = true
                        }
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 30))
            .shadow(color: Theme.ink.opacity(0.12), radius: 15, y: 10)
            .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack {
        MealAnalysisView(photo: UIImage(named: "SampleMeal")!, onFinish: {}, onRetakePhoto: {}, onEnterManually: {})
    }
    .modelContainer(Meal.previewContainer)
}
