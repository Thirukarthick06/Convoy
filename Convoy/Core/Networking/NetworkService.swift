import Foundation
import CoreLocation

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case connectionLost
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid endpoint URL requested."
        case .invalidResponse:
            return "Received an unexpected server response."
        case .decodingError(let error):
            return "Failed to decode server response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server responded with error code \(code)."
        case .connectionLost:
            return "Network connection unavailable or lost."
        case .unauthorized:
            return "Authentication credentials invalid or expired."
        }
    }
}

// MARK: - Telemetry Packet

struct RiderTelemetryPacket: Codable {
    let riderId: UUID
    let coordinate: CoordinatePoint
    let speedKmh: Double
    let headingDegrees: Double
    let leanAngleDegrees: Double
    let timestamp: Date
    
    struct CoordinatePoint: Codable {
        let latitude: Double
        let longitude: Double
    }
}

// MARK: - Network Service Protocol

protocol NetworkServiceProtocol: Sendable {
    func broadcastTelemetry(_ telemetry: RiderTelemetryPacket) async throws
    func fetchPackLocations(rideId: UUID) async throws -> [RiderTelemetryPacket]
    func sendEmergencySOS(rideId: UUID, riderId: UUID, coordinate: CLLocationCoordinate2D, medicalDetails: String) async throws -> Bool
    func requestScenicRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, curviness: Double) async throws -> [CLLocationCoordinate2D]
}

// MARK: - Default Network Service Implementation

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func broadcastTelemetry(_ telemetry: RiderTelemetryPacket) async throws {
        // Production implementation connects to WebSocket or HTTP/3 endpoint
    }
    
    func fetchPackLocations(rideId: UUID) async throws -> [RiderTelemetryPacket] {
        return []
    }
    
    func sendEmergencySOS(rideId: UUID, riderId: UUID, coordinate: CLLocationCoordinate2D, medicalDetails: String) async throws -> Bool {
        return true
    }
    
    func requestScenicRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, curviness: Double) async throws -> [CLLocationCoordinate2D] {
        return [start, end]
    }
}
