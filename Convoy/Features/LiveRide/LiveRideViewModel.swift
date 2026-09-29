import SwiftUI
import CoreLocation
import SwiftData

// MARK: - Live Ride View Model

@MainActor
@Observable
final class LiveRideViewModel {
    let ride: Ride
    
    // Telemetry
    var currentSpeed: Double = 68.0
    var maxSpeed: Double = 94.0
    var distanceCovered: Double = 42.6
    var remainingDistance: Double = 185.4
    var leanAngle: Double = 18.0
    var elevationMeters: Double = 420.0
    
    // Safety & Formation State
    var activeBroadcast: String?
    var showBroadcastBanner: Bool = false
    var separatedRider: String?
    var isPaused: Bool = false
    
    // Alerts
    var alertLevel: GroupAlertLevel = .safe
    
    init(ride: Ride) {
        self.ride = ride
        self.remainingDistance = ride.distanceKm > 0 ? ride.distanceKm : 185.4
    }
    
    func simulateTelemetryTick() {
        guard !isPaused else { return }
        
        let speedDelta = Double.random(in: -3.0...3.0)
        currentSpeed = max(35.0, min(108.0, currentSpeed + speedDelta))
        if currentSpeed > maxSpeed { maxSpeed = currentSpeed }
        
        distanceCovered += 0.04
        remainingDistance = max(0, remainingDistance - 0.04)
        leanAngle = max(0, min(38, leanAngle + Double.random(in: -4.0...4.0)))
    }
    
    func broadcastSignal(_ message: String) {
        HapticManager.shared.heavyImpact()
        activeBroadcast = message
        showBroadcastBanner = true
    }
    
    func endRide(context: ModelContext) -> RideJournal {
        let journal = RideService.shared.finishRide(
            ride,
            distance: distanceCovered,
            duration: 3600 * 2.5,
            maxSpeed: maxSpeed,
            in: context
        )
        return journal
    }
}
