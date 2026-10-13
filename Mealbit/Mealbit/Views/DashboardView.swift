import PhotosUI
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @AppStorage(NutritionGoals.caloriesKey) private var calorieGoal = NutritionGoals.defaultCalories
    @AppStorage(NutritionGoals.proteinKey) private var proteinGoal = NutritionGoals.defaultProtein
    @AppStorage(NutritionGoals.hasSetGoalsKey) private var hasSetGoals = false
    @State private var isShowingCamera = false
    @State private var isShowingLibrary = false
    @State private var isEnteringManually = false
    @State private var isEditingGoals = false
    @State private var editingMeal: Meal?
    @State private var libraryItem: PhotosPickerItem?
    /// Taken in the camera; checked once the camera has closed.
    @State private var capturedPhoto: UIImage?
    @State private var checkingPhoto: MealPhoto?

    init() {
        _meals = Query(filter: Meal.loggedToday(), sort: \.date)
    }

    private var caloriesEaten: Int { meals.reduce(0) { $0 + $1.calories } }
    private var proteinEaten: Double { meals.reduce(0) { $0 + $1.protein } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    RemainingCard(
                        caloriesEaten: caloriesEaten,
                        calorieGoal: calorieGoal,
                        proteinEaten: proteinEaten,
                        proteinGoal: proteinGoal
                    )
                }

                Section("Eaten Today") {
                    if meals.isEmpty {
                        Text("Check a meal before you eat it to see how it fits your day.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(meals) { meal in
                            Button {
                                editingMeal = meal
                            } label: {
                                MealRow(meal: meal)
                            }
                            .tint(.primary)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(meals[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .safeAreaInset(edge: .bottom) {
                checkMealButtons
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Daily Goals", systemImage: "target") {
                        isEditingGoals = true
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingCamera, onDismiss: checkCapturedPhoto) {
                CameraPicker { capturedPhoto = $0 }
                    .ignoresSafeArea()
            }
            .photosPicker(isPresented: $isShowingLibrary, selection: $libraryItem, matching: .images)
            .onChange(of: libraryItem) {
                Task { await checkLibraryPhoto() }
            }
            .sheet(item: $checkingPhoto) { photo in
                NavigationStack {
                    MealAnalysisView(photo: photo.image, onFinish: { checkingPhoto = nil })
                }
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $isEnteringManually) {
                MealFormView()
            }
            .sheet(item: $editingMeal) { meal in
                MealFormView(meal: meal)
            }
            .sheet(isPresented: $isEditingGoals) {
                GoalsView()
            }
            .fullScreenCover(isPresented: .constant(!hasSetGoals)) {
                GoalSetupView()
            }
        }
    }

    private var checkMealButtons: some View {
        VStack(spacing: 12) {
            Button {
                if CameraPicker.isAvailable {
                    isShowingCamera = true
                } else {
                    isShowingLibrary = true
                }
            } label: {
                Label("Check a Meal", systemImage: "camera.fill")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 32) {
                Button("Choose Photo") { isShowingLibrary = true }
                Button("Enter Manually") { isEnteringManually = true }
            }
            .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func checkCapturedPhoto() {
        guard let capturedPhoto else { return }
        checkingPhoto = MealPhoto(image: capturedPhoto)
        self.capturedPhoto = nil
    }

    private func checkLibraryPhoto() async {
        guard let libraryItem else { return }
        self.libraryItem = nil
        guard let data = try? await libraryItem.loadTransferable(type: Data.self),
              let image = UIImage(data: data)
        else { return }
        checkingPhoto = MealPhoto(image: image)
    }
}

#Preview("With meals") {
    DashboardView()
        .modelContainer(Meal.previewContainer)
}

#Preview("Empty") {
    DashboardView()
        .modelContainer(for: Meal.self, inMemory: true)
}
