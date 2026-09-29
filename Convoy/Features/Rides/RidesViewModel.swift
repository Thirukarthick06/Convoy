import SwiftUI
import SwiftData

// MARK: - Rides View Model

@MainActor
@Observable
final class RidesViewModel {
    var searchText: String = ""
    var selectedFilter: RideSegment = .upcoming
    var isShowingFilterSheet: Bool = false
    
    enum RideSegment: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
        case active = "Live & Active"
        case completed = "Past Rides"
        
        var id: String { rawValue }
    }
    
    func filteredRides(from allRides: [Ride]) -> [Ride] {
        allRides.filter { ride in
            // Search text match
            if !searchText.isEmpty {
                let matchesTitle = ride.title.localizedCaseInsensitiveContains(searchText)
                let matchesStart = ride.startLocationName.localizedCaseInsensitiveContains(searchText)
                let matchesEnd = ride.endLocationName.localizedCaseInsensitiveContains(searchText)
                if !matchesTitle && !matchesStart && !matchesEnd { return false }
            }
            
            // Segment filter
            switch selectedFilter {
            case .upcoming:
                return ride.status == .scheduled || ride.status == .lobby
            case .active:
                return ride.status == .active || ride.status == .paused
            case .completed:
                return ride.status == .completed
            }
        }
    }
    
    func joinRide(_ ride: Ride, user: User, role: RiderRole = .rider, context: ModelContext) {
        try? RideService.shared.joinRide(ride, user: user, role: role, in: context)
    }
    
    func leaveRide(_ ride: Ride, user: User, context: ModelContext) {
        try? RideService.shared.leaveRide(ride, user: user, in: context)
    }
}
