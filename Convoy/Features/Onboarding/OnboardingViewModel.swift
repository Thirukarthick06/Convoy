import SwiftUI
import SwiftData

// MARK: - Onboarding View Model

@MainActor
@Observable
final class OnboardingViewModel {
    var currentStep: Int = 0
    var name: String = ""
    var username: String = ""
    var email: String = ""
    var experience: RidingExperience = .intermediate
    var bikeManufacturer: String = ""
    var bikeModel: String = ""
    var bikeYear: Int = 2024
    
    var isFormValid: Bool {
        switch currentStep {
        case 0:
            return true // Welcome splash
        case 1:
            return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !email.trimmingCharacters(in: .whitespaces).isEmpty
        case 2:
            return true // Experience selector
        case 3:
            return !bikeManufacturer.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !bikeModel.trimmingCharacters(in: .whitespaces).isEmpty
        default:
            return true
        }
    }
    
    func completeOnboarding(appState: AppState, context: ModelContext) {
        let user = User(
            name: name.isEmpty ? "Convoy Rider" : name,
            username: username.isEmpty ? (name.lowercased().replacingOccurrences(of: " ", with: ".")) : username,
            email: email.isEmpty ? "rider@convoy.app" : email,
            ridingExperience: experience
        )
        
        if !bikeManufacturer.isEmpty && !bikeModel.isEmpty {
            let primaryBike = Motorcycle(
                name: "\(bikeManufacturer) \(bikeModel)",
                manufacturer: bikeManufacturer,
                model: bikeModel,
                year: bikeYear,
                isPrimary: true
            )
            user.motorcycles.append(primaryBike)
        }
        
        context.insert(user)
        try? context.save()
        
        appState.currentUser = user
        appState.isAuthenticated = true
        appState.hasCompletedOnboarding = true
        HapticManager.shared.success()
    }
}
