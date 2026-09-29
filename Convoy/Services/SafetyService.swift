import Foundation
import SwiftData
import CoreLocation

// MARK: - Safety Service Protocol

@MainActor
protocol SafetyServiceProtocol: AnyObject {
    var isMonitoringActive: Bool { get }
    var hasActiveSOS: Bool { get }
    
    func startMonitoring()
    func stopMonitoring()
    func triggerSOS(user: User?, coordinate: CLLocationCoordinate2D, context: ModelContext) -> SafetyEvent
    func cancelSOS()
    func reportHazard(type: HazardType, coordinate: CLLocationCoordinate2D, description: String, context: ModelContext) -> Hazard
}

// MARK: - Safety Service Implementation

@MainActor
@Observable
final class SafetyService: SafetyServiceProtocol {
    static let shared = SafetyService()
    
    var isMonitoringActive: Bool = true
    var hasActiveSOS: Bool = false
    var activeSafetyEvent: SafetyEvent?
    
    init() {}
    
    func startMonitoring() {
        isMonitoringActive = true
    }
    
    func stopMonitoring() {
        isMonitoringActive = false
    }
    
    @discardableResult
    func triggerSOS(user: User?, coordinate: CLLocationCoordinate2D, context: ModelContext) -> SafetyEvent {
        hasActiveSOS = true
        HapticManager.shared.emergencyAlert()
        
        let event = SafetyEvent(
            eventType: .sos,
            userId: user?.id ?? UUID(),
            userName: user?.name ?? "Rider",
            coordinate: coordinate,
            message: "Emergency SOS triggered by rider \(user?.name ?? "Unknown"). Exact coordinates broadcast to Convoy pack & emergency contacts."
        )
        
        activeSafetyEvent = event
        context.insert(event)
        try? context.save()
        
        return event
    }
    
    func cancelSOS() {
        hasActiveSOS = false
        activeSafetyEvent = nil
        HapticManager.shared.lightImpact()
    }
    
    @discardableResult
    func reportHazard(type: HazardType, coordinate: CLLocationCoordinate2D, description: String, context: ModelContext) -> Hazard {
        let hazard = Hazard(
            hazardType: type,
            coordinate: coordinate,
            note: description
        )
        
        context.insert(hazard)
        try? context.save()
        HapticManager.shared.packAlert()
        
        return hazard
    }
}
