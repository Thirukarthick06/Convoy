import Foundation
import CoreLocation
import SwiftUI

// MARK: - Location Manager

/// Wraps Core Location for permission handling, current location, heading, and ride tracking.
/// Uses @Observable for SwiftUI integration.
@MainActor
@Observable
final class LocationManager: NSObject {
    
    // MARK: - Published State
    var currentLocation: CLLocationCoordinate2D?
    var currentSpeed: Double = 0 // km/h
    var currentHeading: Double = 0
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isTracking: Bool = false
    var locationError: String?
    
    // MARK: - Route Tracking
    var trackedCoordinates: [CLLocationCoordinate2D] = []
    var totalDistance: Double = 0 // km
    var startTime: Date?
    
    // MARK: - Private
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // meters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.activityType = .otherNavigation
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Permission
    
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var needsPermission: Bool {
        authorizationStatus == .notDetermined
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Tracking
    
    func startTracking() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        isTracking = true
        startTime = Date()
        trackedCoordinates = []
        totalDistance = 0
        lastLocation = nil
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        isTracking = false
    }
    
    func startBackgroundTracking() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        startTracking()
    }
    
    // MARK: - Computed
    
    var elapsedTime: TimeInterval {
        guard let startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    var averageSpeed: Double {
        guard elapsedTime > 0 else { return 0 }
        return totalDistance / (elapsedTime / 3600)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            currentLocation = location.coordinate
            currentSpeed = max(0, location.speed * 3.6) // m/s → km/h
            
            // Track distance
            if let lastLocation {
                let delta = location.distance(from: lastLocation) / 1000.0 // km
                if delta > 0.005 { // ignore tiny movements
                    totalDistance += delta
                    trackedCoordinates.append(location.coordinate)
                }
            } else {
                trackedCoordinates.append(location.coordinate)
            }
            
            lastLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            currentHeading = newHeading.trueHeading
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationError = "Location unavailable"
        }
    }
}
