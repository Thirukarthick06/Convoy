import SwiftUI
import SwiftData

// MARK: - Clubs View Model

@MainActor
@Observable
final class ClubsViewModel {
    var searchText: String = ""
    var selectedSegment: ClubSegment = .myClubs
    var showCreateClub: Bool = false
    
    enum ClubSegment: String, CaseIterable, Identifiable {
        case myClubs = "My Clubs"
        case explore = "Discover"
        
        var id: String { rawValue }
    }
    
    func filterClubs(_ clubs: [Club]) -> [Club] {
        clubs.filter { club in
            if !searchText.isEmpty {
                let matchesName = club.name.localizedCaseInsensitiveContains(searchText)
                let matchesCity = club.city.localizedCaseInsensitiveContains(searchText)
                if !matchesName && !matchesCity { return false }
            }
            return true
        }
    }
    
    func createClub(name: String, city: String, description: String, context: ModelContext) {
        guard !name.isEmpty else { return }
        let club = Club(
            name: name,
            clubDescription: description,
            city: city,
            memberCount: 1,
            totalRides: 0,
            totalDistanceKm: 0,
            isVerified: false
        )
        context.insert(club)
        try? context.save()
        HapticManager.shared.success()
    }
}
