import Foundation
import CoreLocation

// MARK: - Ride Weather Condition

struct RideWeatherCondition: Sendable {
    let temperatureCelsius: Int
    let conditionName: String
    let iconName: String
    let precipitationProbability: Int // percentage
    let windSpeedKmh: Int
    let roadCondition: RoadCondition
    let isFavorableForRiding: Bool
    
    enum RoadCondition: String, Sendable {
        case dry = "Dry & Optimal Grip"
        case damp = "Damp / Slick"
        case wet = "Wet / Reduced Traction"
        case gravel = "Loose Gravel"
    }
}

// MARK: - Weather Service Protocol

@MainActor
protocol WeatherServiceProtocol: AnyObject {
    func fetchRideWeather(coordinate: CLLocationCoordinate2D) async throws -> RideWeatherCondition
}

// MARK: - Weather Service Implementation

@MainActor
final class WeatherService: WeatherServiceProtocol {
    static let shared = WeatherService()
    
    init() {}
    
    func fetchRideWeather(coordinate: CLLocationCoordinate2D) async throws -> RideWeatherCondition {
        // Simulated network response delay
        try await Task.sleep(nanoseconds: 100_000_000)
        
        return RideWeatherCondition(
            temperatureCelsius: 24,
            conditionName: "Clear Skies",
            iconName: "sun.max.fill",
            precipitationProbability: 5,
            windSpeedKmh: 14,
            roadCondition: .dry,
            isFavorableForRiding: true
        )
    }
}
