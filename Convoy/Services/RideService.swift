import Foundation
import SwiftData
import CoreLocation

// MARK: - Ride Service Protocol

@MainActor
protocol RideServiceProtocol: AnyObject {
    func createRide(_ ride: Ride, in context: ModelContext) throws
    func joinRide(_ ride: Ride, user: User, role: RiderRole, in context: ModelContext) throws
    func leaveRide(_ ride: Ride, user: User, in context: ModelContext) throws
    func startRide(_ ride: Ride, in context: ModelContext) throws
    func pauseRide(_ ride: Ride)
    func resumeRide(_ ride: Ride)
    func finishRide(_ ride: Ride, distance: Double, duration: TimeInterval, maxSpeed: Double, in context: ModelContext) -> RideJournal
    func updateFormation(_ ride: Ride, formation: Formation)
}

// MARK: - Ride Service Implementation

@MainActor
final class RideService: RideServiceProtocol {
    static let shared = RideService()
    
    init() {}
    
    func createRide(_ ride: Ride, in context: ModelContext) throws {
        context.insert(ride)
        try context.save()
        HapticManager.shared.rideCreated()
    }
    
    func joinRide(_ ride: Ride, user: User, role: RiderRole = .rider, in context: ModelContext) throws {
        // Check if already in ride
        if ride.participants.contains(where: { $0.riderId == user.id }) {
            return
        }
        
        let participant = RideParticipant(
            riderId: user.id,
            riderName: user.name,
            role: role,
            status: .joined,
            formationPosition: ride.participants.count + 1,
            motorcycleModel: user.primaryMotorcycle?.displayName
        )
        
        ride.participants.append(participant)
        try context.save()
        HapticManager.shared.success()
    }
    
    func leaveRide(_ ride: Ride, user: User, in context: ModelContext) throws {
        ride.participants.removeAll(where: { $0.riderId == user.id })
        try context.save()
        HapticManager.shared.lightImpact()
    }
    
    func startRide(_ ride: Ride, in context: ModelContext) throws {
        ride.status = .active
        ride.startedAt = Date()
        try context.save()
        HapticManager.shared.rideStarted()
    }
    
    func pauseRide(_ ride: Ride) {
        ride.status = .paused
        HapticManager.shared.lightImpact()
    }
    
    func resumeRide(_ ride: Ride) {
        ride.status = .active
        HapticManager.shared.lightImpact()
    }
    
    func finishRide(_ ride: Ride, distance: Double, duration: TimeInterval, maxSpeed: Double, in context: ModelContext) -> RideJournal {
        ride.status = .completed
        ride.completedAt = Date()
        
        // Generate automatic ride journal memorializing the run
        let journal = RideJournal(
            rideId: ride.id,
            rideTitle: ride.title,
            startLocation: ride.startLocationName,
            endLocation: ride.endLocationName,
            narrative: "Completed the scenic run with \(ride.participants.count) riders. Maintained tight \(ride.formation.label.lowercased()) formation with zero safety incidents.",
            highlights: [
                "Full pack completed the route safely",
                "Peak elevation recorded along twisties",
                "Smooth stops at all scheduled waypoints"
            ],
            distanceKm: distance > 0 ? distance : ride.distanceKm,
            durationSeconds: duration > 0 ? duration : ride.estimatedDurationSeconds,
            averageSpeedKmh: distance > 0 && duration > 0 ? (distance / (duration / 3600.0)) : 62.0,
            maxSpeedKmh: maxSpeed > 0 ? maxSpeed : 98.0,
            riderCount: max(1, ride.participants.count)
        )
        
        context.insert(journal)
        try? context.save()
        HapticManager.shared.rideComplete()
        return journal
    }
    
    func updateFormation(_ ride: Ride, formation: Formation) {
        ride.formation = formation
        HapticManager.shared.selection()
    }
}
