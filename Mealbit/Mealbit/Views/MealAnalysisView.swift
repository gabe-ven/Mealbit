import SwiftData
import SwiftUI

/// A photo the user wants to check, presented as one item.
struct MealPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
}

/// Estimates the meal in `photo`, then shows its preview.
struct MealAnalysisView: View {
    let photo: UIImage
    let onFinish: () -> Void

    @State private var draft: MealDraft?
    @State private var errorMessage: String?

    var body: some View {
        if let draft {
            MealPreviewView(draft: draft, photo: photo, onFinish: onFinish)
        } else {
            VStack(spacing: 24) {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipShape(.rect(cornerRadius: 16))

                if let errorMessage {
                    ContentUnavailableView {
                        Label("Couldn't Estimate", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") { self.errorMessage = nil }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Estimating your meal…")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Checking Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onFinish)
                }
            }
            .task(id: errorMessage == nil) {
                guard errorMessage == nil else { return }
                await estimate()
            }
        }
    }

    private func estimate() async {
        do {
            draft = try await MealEstimator.estimate(from: photo)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Check your connection and try again."
        }
    }
}

#Preview {
    NavigationStack {
        MealAnalysisView(photo: UIImage(systemName: "fork.knife")!, onFinish: {})
    }
    .modelContainer(Meal.previewContainer)
}
