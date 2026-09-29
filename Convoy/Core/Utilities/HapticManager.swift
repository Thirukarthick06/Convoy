import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager

/// Centralized haptic engine. Provides contextual feedback for ride events,
/// safety alerts, and UI confirmations.
@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Standard Feedback
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Convoy-Specific Haptics
    
    /// Ride started — strong, satisfying confirmation
    func rideStarted() {
        impact(.heavy)
    }
    
    /// Rider joined the group
    func riderJoined() {
        impact(.medium)
    }
    
    /// Regroup alert — attention-getting
    func regroupAlert() {
        notification(.warning)
    }
    
    /// Route deviation detected
    func routeDeviation() {
        notification(.warning)
    }
    
    /// SOS activation — unmistakable
    func sosActivated() {
        notification(.error)
    }
    
    /// Ride complete — celebratory
    func rideComplete() {
        notification(.success)
    }
    
    /// Journal generated
    func journalReady() {
        notification(.success)
    }
    
    /// Button confirmation (subtle)
    func buttonTap() {
        impact(.light)
    }
    
    /// Tab switch
    func tabSwitch() {
        selection()
    }
    
    func tabSelection() {
        selection()
    }
    
    func lightImpact() {
        impact(.light)
    }
    
    func heavyImpact() {
        impact(.heavy)
    }
    
    func success() {
        notification(.success)
    }
    
    func emergencyAlert() {
        notification(.error)
    }
    
    func rideCreated() {
        notification(.success)
    }
    
    func packAlert() {
        notification(.warning)
    }
}
