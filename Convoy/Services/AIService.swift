import Foundation
import CoreLocation

// MARK: - AI Generated Route Model

struct AIScenicRouteRecommendation: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let subtitle: String
    let curvinessScore: Double // 0.0 to 1.0 (twisties metric)
    let scenicScore: Double // 0.0 to 1.0
    let elevationGainMeters: Double
    let distanceKm: Double
    let estimatedDurationHours: Double
    let recommendedWaypoints: [String]
    let description: String
}

// MARK: - AI Service Protocol

@MainActor
protocol AIServiceProtocol: AnyObject {
    func generateTwistyRoute(
        startLocation: String,
        destination: String,
        curvinessTarget: Double,
        avoidHighways: Bool
    ) async throws -> AIScenicRouteRecommendation
    
    func generateRideNarrative(
        rideTitle: String,
        distanceKm: Double,
        riderCount: Int,
        maxSpeed: Double
    ) async -> String
}

// MARK: - AI Service Implementation

@MainActor
final class AIService: AIServiceProtocol {
    static let shared = AIService()
    
    init() {}
    
    func generateTwistyRoute(
        startLocation: String,
        destination: String,
        curvinessTarget: Double = 0.85,
        avoidHighways: Bool = true
    ) async throws -> AIScenicRouteRecommendation {
        // Simulated intelligence synthesis delay
        try await Task.sleep(nanoseconds: 350_000_000)
        
        return AIScenicRouteRecommendation(
            title: "Ghats & Canyon Pass",
            subtitle: "Optimized for maximum lean angles and switchbacks",
            curvinessScore: curvinessTarget,
            scenicScore: 0.94,
            elevationGainMeters: 1420.0,
            distanceKm: 248.0,
            estimatedDurationHours: 5.2,
            recommendedWaypoints: [
                "Old Mountain Ghat Switchbacks",
                "Pine Valley Viewpoint & Tea Stall",
                "Cascade River Bridge Crossing",
                "Highland Fuel & Pressure Station"
            ],
            description: "AI selected a scenic ridge-line alternative avoiding highway straightaways. Features 38 tight hairpin turns, smooth tarmac, and scenic valleys ideal for staggered pack riding."
        )
    }
    
    func generateRideNarrative(
        rideTitle: String,
        distanceKm: Double,
        riderCount: Int,
        maxSpeed: Double
    ) async -> String {
        return "An exhilarating \(String(format: "%.1f", distanceKm)) km expedition during '\(rideTitle)'. The pack of \(riderCount) machines demonstrated flawless discipline and formation dynamics, carving up mountain curves with a spirited top pace of \(Int(maxSpeed)) km/h."
    }
}
