import SwiftUI
import SwiftData
import CoreLocation

// MARK: - App State

/// Global application state — drives authentication, active ride, and top-level coordination.
@MainActor
@Observable
final class AppState {
    
    // MARK: - Authentication
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false
    var currentUser: User?
    
    // MARK: - Navigation
    var selectedTab: ConvoyTab = .home
    var isShowingLiveRide: Bool = false
    
    // MARK: - Active Ride
    var activeRide: Ride?
    var activeRideParticipants: [RideParticipant] = []
    var groupAlertLevel: GroupAlertLevel = .safe
    
    // MARK: - Location
    var currentLocation: CLLocationCoordinate2D?
    var currentSpeed: Double = 0
    var currentHeading: Double = 0
    
    // MARK: - Demo Mode
    var isDemoMode: Bool = true
    var isSimulationRunning: Bool = false
    
    // MARK: - Sheets
    var isShowingPlanRide: Bool = false
    var isShowingJoinRide: Bool = false
    var isShowingSOS: Bool = false
    var isShowingSafetyCenter: Bool = false
    var isShowingSettings: Bool = false
    
    // MARK: - Computed
    
    var isRiding: Bool { activeRide?.isActive ?? false }
    
    var greeting: String {
        Date().greeting
    }
    
    // MARK: - Actions
    
    func startRide(_ ride: Ride) {
        ride.status = .active
        ride.startedAt = Date()
        activeRide = ride
        isShowingLiveRide = true
        HapticManager.shared.rideStarted()
    }
    
    func endRide() {
        if let ride = activeRide {
            ride.status = .completed
            ride.completedAt = Date()
        }
        isShowingLiveRide = false
        HapticManager.shared.rideComplete()
    }
    
    func pauseRide() {
        activeRide?.status = .paused
    }
    
    func resumeRide() {
        activeRide?.status = .active
    }
    
    func enterLobby(_ ride: Ride) {
        ride.status = .lobby
        activeRide = ride
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        activeRide = nil
        isShowingLiveRide = false
        selectedTab = .home
    }
}
