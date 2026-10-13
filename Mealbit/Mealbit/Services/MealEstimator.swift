import UIKit

/// Turns a meal photo into an estimated `MealDraft`.
///
/// Placeholder until the backend proxy exists: it waits briefly and returns the
/// sample estimate so the photo-to-preview flow can be tested end to end.
enum MealEstimator {
    static func estimate(from photo: UIImage) async throws -> MealDraft {
        try await Task.sleep(for: .seconds(1.5))
        return .sampleEstimate
    }
}
