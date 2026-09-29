import SwiftUI

// MARK: - App Navigation Coordinator

/// Coordinates high-level application flows, modal sheet presentations, and deep links.
@MainActor
@Observable
final class AppCoordinator {
    var isShowingOnboarding: Bool = false
    var isShowingLiveRide: Bool = false
    var isShowingSOS: Bool = false
    var isShowingSafetyCenter: Bool = false
    var isShowingPlanRide: Bool = false
    var isShowingRideComplete: Bool = false
    
    // Active Ride reference for coordinator-driven flows
    var activeRideForPresentation: Ride?
    
    func presentLiveRide(for ride: Ride) {
        self.activeRideForPresentation = ride
        self.isShowingLiveRide = true
        HapticManager.shared.rideStarted()
    }
    
    func dismissLiveRide() {
        self.isShowingLiveRide = false
    }
    
    func triggerEmergencySOS() {
        self.isShowingSOS = true
        HapticManager.shared.emergencyAlert()
    }
    
    func presentPlanRide() {
        self.isShowingPlanRide = true
        HapticManager.shared.lightImpact()
    }
    
    func presentSafetyCenter() {
        self.isShowingSafetyCenter = true
        HapticManager.shared.lightImpact()
    }
    
    func completeRide(ride: Ride) {
        self.activeRideForPresentation = ride
        self.isShowingLiveRide = false
        self.isShowingRideComplete = true
        HapticManager.shared.rideComplete()
    }
}
