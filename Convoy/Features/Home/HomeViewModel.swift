import SwiftUI
import SwiftData

// MARK: - Home View Model

@MainActor
@Observable
final class HomeViewModel {
    var searchText: String = ""
    var selectedFilter: RideFilter = .all
    var isRefreshing: Bool = false
    var weatherCondition: RideWeatherCondition?
    
    enum RideFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case upcoming = "Upcoming"
        case club = "Clubs"
        case open = "Open Pack"
        
        var id: String { rawValue }
    }
    
    func refreshWeather() async {
        isRefreshing = true
        weatherCondition = try? await WeatherService.shared.fetchRideWeather(
            coordinate: .init(latitude: 12.9716, longitude: 77.5946)
        )
        isRefreshing = false
    }
    
    func filterRides(_ rides: [Ride]) -> [Ride] {
        rides.filter { ride in
            if !searchText.isEmpty {
                let matchesTitle = ride.title.localizedCaseInsensitiveContains(searchText)
                let matchesStart = ride.startLocationName.localizedCaseInsensitiveContains(searchText)
                let matchesEnd = ride.endLocationName.localizedCaseInsensitiveContains(searchText)
                if !matchesTitle && !matchesStart && !matchesEnd { return false }
            }
            
            switch selectedFilter {
            case .all:
                return true
            case .upcoming:
                return ride.status == .scheduled || ride.status == .lobby
            case .club:
                return ride.isClubRide
            case .open:
                return !ride.isClubRide
            }
        }
    }
}
