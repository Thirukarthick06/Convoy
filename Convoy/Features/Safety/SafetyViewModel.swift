import SwiftUI
import SwiftData
import CoreLocation

// MARK: - Safety View Model

@MainActor
@Observable
final class SafetyViewModel {
    var crashDetectionEnabled: Bool = true
    var autoBeaconEnabled: Bool = true
    var isCountdownActive: Bool = false
    var countdownRemaining: Int = 10
    var sosTransmitted: Bool = false
    
    func startSOSCountdown() {
        countdownRemaining = 10
        isCountdownActive = true
        sosTransmitted = false
        HapticManager.shared.emergencyAlert()
    }
    
    func cancelSOS() {
        isCountdownActive = false
        sosTransmitted = false
        SafetyService.shared.cancelSOS()
    }
    
    func transmitSOS(user: User?, coordinate: CLLocationCoordinate2D, context: ModelContext) {
        isCountdownActive = false
        sosTransmitted = true
        _ = SafetyService.shared.triggerSOS(user: user, coordinate: coordinate, context: context)
    }
}
