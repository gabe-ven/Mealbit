import PhotosUI
import SwiftData
import SwiftUI

/// "Check a Meal": take or choose a photo, then estimate it and show the result.
struct CheckMealView: View {
    /// Called when the user would rather type the meal in; the flow closes first.
    let onEnterManually: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var path: [MealPhoto] = []
    @State private var isShowingCamera = false
    @State private var isShowingLibrary = false
    @State private var libraryItem: PhotosPickerItem?
    /// Taken in the camera; checked once the camera has closed.
    @State private var capturedPhoto: UIImage?

    var body: some View {
        NavigationStack(path: $path) {
            pickPage
                .navigationDestination(for: MealPhoto.self) { photo in
                    MealAnalysisView(
                        photo: photo.image,
                        onFinish: { dismiss() },
                        onRetakePhoto: { path.removeAll() },
                        onEnterManually: {
                            dismiss()
                            onEnterManually()
                        }
                    )
                }
        }
        .tint(Theme.ink)
        .fullScreenCover(isPresented: $isShowingCamera, onDismiss: checkCapturedPhoto) {
            CameraPicker { capturedPhoto = $0 }
                .ignoresSafeArea()
        }
        .photosPicker(isPresented: $isShowingLibrary, selection: $libraryItem, matching: .images)
        .onChange(of: libraryItem) {
            Task { await checkLibraryPhoto() }
        }
    }

    private var pickPage: some View {
        VStack(spacing: 0) {
            Text("Take or upload a meal photo")
                .font(.rounded(19, .black))
                .foregroundStyle(Theme.ink)
            Text("Snap a photo of your meal and Mealbit will estimate the calories and protein.")
                .font(.rounded(15, .semibold))
                .foregroundStyle(Theme.mute)
                .multilineTextAlignment(.center)
                .padding(.top, 6)

            FilledImage(image: Image("SampleMeal"), height: 318)
                .clipShape(.rect(cornerRadius: 24))
                .overlay(FrameCorners().padding(16))
                .padding(6)
                .background(Theme.card, in: .rect(cornerRadius: 30))
                .shadow(color: Theme.ink.opacity(0.08), radius: 10, y: 6)
                .padding(.top, 22)
                .accessibilityHidden(true)

            Button {
                isShowingCamera = CameraPicker.isAvailable
                isShowingLibrary = !CameraPicker.isAvailable
            } label: {
                Label("Use Camera", systemImage: "camera.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 28)

            Button {
                isShowingLibrary = true
            } label: {
                Label("Choose Photo", systemImage: "photo")
            }
            .buttonStyle(SecondaryButtonStyle(height: 56))
            .padding(.top, 12)

            Spacer(minLength: 16)

            Text("✨ Works with any meal")
                .font(.rounded(14, .heavy))
                .foregroundStyle(Theme.ink)
            Text("Bowls, sandwiches, snacks, and more!")
                .font(.rounded(13, .semibold))
                .foregroundStyle(Theme.mute)
                .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Theme.background)
        .navigationTitle("Check a Meal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back", systemImage: "chevron.left") { dismiss() }
                    .fontWeight(.bold)
            }
        }
    }

    private func checkCapturedPhoto() {
        guard let capturedPhoto else { return }
        path.append(MealPhoto(image: capturedPhoto))
        self.capturedPhoto = nil
    }

    private func checkLibraryPhoto() async {
        guard let libraryItem else { return }
        self.libraryItem = nil
        guard let data = try? await libraryItem.loadTransferable(type: Data.self),
              let image = UIImage(data: data)
        else { return }
        path.append(MealPhoto(image: image))
    }
}

/// Four white corner brackets, like a camera framing guide.
private struct FrameCorners: View {
    var body: some View {
        ZStack {
            corner(0, .topLeading)
            corner(90, .topTrailing)
            corner(180, .bottomTrailing)
            corner(270, .bottomLeading)
        }
    }

    private func corner(_ degrees: Double, _ alignment: Alignment) -> some View {
        CornerShape()
            .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 28, height: 28)
            .rotationEffect(.degrees(degrees))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

/// The top-left bracket; rotated for the other corners.
private struct CornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: 10))
        path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        return path
    }
}

#Preview {
    CheckMealView(onEnterManually: {})
        .modelContainer(Meal.previewContainer)
}
