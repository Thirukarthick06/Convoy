import Foundation
import CoreLocation

// MARK: - Rider Distance Info

struct RiderProximityInfo: Identifiable, Sendable {
    let id: UUID
    let name: String
    let role: RiderRole
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double
    let speedKmh: Double
    let isSeparated: Bool
}

// MARK: - Location Sharing Service Protocol

@MainActor
protocol LocationSharingServiceProtocol: AnyObject {
    var isSharingActive: Bool { get }
    var currentAlertLevel: GroupAlertLevel { get }
    
    func startSharing(for rideId: UUID)
    func stopSharing()
    func updateCurrentLocation(_ coordinate: CLLocationCoordinate2D, speed: Double)
    func checkPackSeparation(userCoord: CLLocationCoordinate2D, packCoords: [(UUID, String, RiderRole, CLLocationCoordinate2D)]) -> [RiderProximityInfo]
}

// MARK: - Location Sharing Service Implementation

@MainActor
@Observable
final class LocationSharingService: LocationSharingServiceProtocol {
    static let shared = LocationSharingService()
    
    var isSharingActive: Bool = false
    var currentAlertLevel: GroupAlertLevel = .safe
    var proximityList: [RiderProximityInfo] = []
    
    // Separation threshold in meters
    private let separationWarningDistanceMeters: Double = 800.0
    private let separationCriticalDistanceMeters: Double = 2000.0
    
    init() {}
    
    func startSharing(for rideId: UUID) {
        isSharingActive = true
        currentAlertLevel = .safe
    }
    
    func stopSharing() {
        isSharingActive = false
        currentAlertLevel = .safe
        proximityList = []
    }
    
    func updateCurrentLocation(_ coordinate: CLLocationCoordinate2D, speed: Double) {
        guard isSharingActive else { return }
        // Broadcast local coordinate to pack mesh
    }
    
    func checkPackSeparation(
        userCoord: CLLocationCoordinate2D,
        packCoords: [(UUID, String, RiderRole, CLLocationCoordinate2D)]
    ) -> [RiderProximityInfo] {
        let userLocation = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        var results: [RiderProximityInfo] = []
        var maxDistance: Double = 0
        
        for (id, name, role, coord) in packCoords {
            let riderLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = userLocation.distance(from: riderLoc)
            let isSeparated = distance > separationWarningDistanceMeters
            
            if distance > maxDistance {
                maxDistance = distance
            }
            
            results.append(RiderProximityInfo(
                id: id,
                name: name,
                role: role,
                coordinate: coord,
                distanceMeters: distance,
                speedKmh: 65.0,
                isSeparated: isSeparated
            ))
        }
        
        if maxDistance > separationCriticalDistanceMeters {
            currentAlertLevel = .actionNeeded
            HapticManager.shared.emergencyAlert()
        } else if maxDistance > separationWarningDistanceMeters {
            currentAlertLevel = .watch
            HapticManager.shared.packAlert()
        } else {
            currentAlertLevel = .safe
        }
        
        self.proximityList = results
        return results
    }
}
