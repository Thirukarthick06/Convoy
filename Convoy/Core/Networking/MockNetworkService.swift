import Foundation
import CoreLocation

// MARK: - Mock Network Service

/// Mock networking service providing realistic simulation data for demo mode and offline testing.
final class MockNetworkService: NetworkServiceProtocol {
    static let shared = MockNetworkService()
    
    private let simulatedPackMembers: [RiderTelemetryPacket]
    
    init() {
        simulatedPackMembers = [
            RiderTelemetryPacket(
                riderId: UUID(),
                coordinate: .init(latitude: 12.9730, longitude: 77.5960),
                speedKmh: 72.0,
                headingDegrees: 45.0,
                leanAngleDegrees: 14.0,
                timestamp: Date()
            ),
            RiderTelemetryPacket(
                riderId: UUID(),
                coordinate: .init(latitude: 12.9690, longitude: 77.5920),
                speedKmh: 68.0,
                headingDegrees: 45.0,
                leanAngleDegrees: 18.0,
                timestamp: Date()
            )
        ]
    }
    
    func broadcastTelemetry(_ telemetry: RiderTelemetryPacket) async throws {
        // Simulated local broadcast
        try await Task.sleep(nanoseconds: 50_000_000)
    }
    
    func fetchPackLocations(rideId: UUID) async throws -> [RiderTelemetryPacket] {
        try await Task.sleep(nanoseconds: 100_000_000)
        return simulatedPackMembers
    }
    
    func sendEmergencySOS(rideId: UUID, riderId: UUID, coordinate: CLLocationCoordinate2D, medicalDetails: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
        return true
    }
    
    func requestScenicRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, curviness: Double) async throws -> [CLLocationCoordinate2D] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Generate simulated scenic serpentine waypoints between start and end
        var routeCoordinates: [CLLocationCoordinate2D] = [start]
        let steps = 10
        for i in 1..<steps {
            let ratio = Double(i) / Double(steps)
            let lat = start.latitude + (end.latitude - start.latitude) * ratio
            let lon = start.longitude + (end.longitude - start.longitude) * ratio
            
            // Add curve deviation based on curviness
            let curveDeviation = sin(ratio * .pi * 3) * (0.04 * curviness)
            routeCoordinates.append(CLLocationCoordinate2D(latitude: lat + curveDeviation, longitude: lon - curveDeviation))
        }
        routeCoordinates.append(end)
        return routeCoordinates
    }
}
