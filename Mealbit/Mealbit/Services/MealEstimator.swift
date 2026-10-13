import UIKit

enum MealEstimateError: LocalizedError {
    case notFood
    case network
    case server

    var errorDescription: String? {
        switch self {
        case .notFood: "That doesn't look like food. Try another photo."
        case .network: "Check your connection and try again."
        case .server: "Couldn't estimate this photo. Try again, or enter it manually."
        }
    }

    var canRetry: Bool { self != .notFood }
}

/// Turns a meal photo into an estimated `MealDraft` with one request to the
/// Mealbit proxy, which calls Claude. The API key stays on the proxy.
enum MealEstimator {
    private static let endpoint = URL(string: "https://mealbit-proxy.mealbit.workers.dev/estimate")!

    private static let maxImageDimension: CGFloat = 1568

    static func estimate(from photo: UIImage) async throws -> MealDraft {
        guard let jpeg = resized(photo).jpegData(compressionQuality: 0.8) else {
            throw MealEstimateError.server
        }

        var request = URLRequest(url: endpoint, timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["image": jpeg.base64EncodedString()])

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw MealEstimateError.network
        }

        guard (response as? HTTPURLResponse)?.statusCode == 200,
              let estimate = try? JSONDecoder().decode(Estimate.self, from: data)
        else { throw MealEstimateError.server }

        guard estimate.isFood, !estimate.components.isEmpty else { throw MealEstimateError.notFood }
        return estimate.draft
    }

    /// Scales the photo down so its longest side is at most `maxImageDimension`.
    private static func resized(_ image: UIImage) -> UIImage {
        let longestSide = max(image.size.width, image.size.height)
        let scale = min(1, maxImageDimension / longestSide)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

/// The proxy's JSON response.
private struct Estimate: Decodable {
    struct Component: Decodable {
        let name: String
        let quantity: Double
        let unit: String
        let calories: Double
        let proteinG: Double
        let carbsG: Double
        let fatG: Double

        private enum CodingKeys: String, CodingKey {
            case name, quantity, unit, calories
            case proteinG = "protein_g", carbsG = "carbs_g", fatG = "fat_g"
        }
    }

    let isFood: Bool
    let mealName: String
    let components: [Component]
    let confidence: String
    let notes: String

    private enum CodingKeys: String, CodingKey {
        case isFood = "is_food", mealName = "meal_name", components, confidence, notes
    }

    var draft: MealDraft {
        MealDraft(
            name: mealName,
            category: .suggested(for: .now),
            components: components.map {
                MealComponent(
                    name: $0.name, quantity: $0.quantity, unit: $0.unit,
                    calories: $0.calories, protein: $0.proteinG, carbs: $0.carbsG, fat: $0.fatG
                )
            },
            estimateNote: notes.isEmpty ? nil : notes,
            isLowConfidence: confidence == "low"
        )
    }
}
