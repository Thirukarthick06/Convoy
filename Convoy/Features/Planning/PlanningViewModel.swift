import SwiftUI
import SwiftData

// MARK: - Planning View Model

@MainActor
@Observable
final class PlanningViewModel {
    var title: String = ""
    var rideDescription: String = ""
    var scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
    var startLocation: String = "Bangalore (MG Road)"
    var endLocation: String = "Coorg (Madikeri)"
    var distanceKm: Double = 248.0
    var estimatedHours: Double = 5.5
    
    var ridingStyle: RidingStyle = .curvaceous
    var formation: Formation = .staggered
    var pace: Pace = .moderate
    var selectedClub: Club?
    
    var isGeneratingAIRoute: Bool = false
    
    func applyAIRoute(_ recommendation: AIScenicRouteRecommendation) {
        self.title = recommendation.title
        self.rideDescription = recommendation.description
        self.distanceKm = recommendation.distanceKm
        self.estimatedHours = recommendation.estimatedDurationHours
        self.ridingStyle = .curvaceous
        HapticManager.shared.success()
    }
    
    func saveRide(currentUser: User, context: ModelContext) -> Ride {
        let ride = Ride(
            title: title.isEmpty ? "Weekend Mountain Ride" : title,
            rideDescription: rideDescription,
            scheduledDate: scheduledDate,
            startLocationName: startLocation,
            startLatitude: 12.9716,
            startLongitude: 77.5946,
            endLocationName: endLocation,
            endLatitude: 12.4244,
            endLongitude: 75.7382,
            distanceKm: distanceKm,
            estimatedDurationSeconds: estimatedHours * 3600,
            ridingStyle: ridingStyle,
            formation: formation,
            pace: pace,
            organizerId: currentUser.id,
            organizerName: currentUser.name,
            leaderRiderId: currentUser.id,
            participants: [
                RideParticipant(
                    riderId: currentUser.id,
                    riderName: currentUser.name,
                    role: .lead,
                    status: .joined,
                    formationPosition: 1,
                    motorcycleModel: currentUser.primaryMotorcycle?.displayName
                )
            ]
        )
        
        try? RideService.shared.createRide(ride, in: context)
        return ride
    }
}
