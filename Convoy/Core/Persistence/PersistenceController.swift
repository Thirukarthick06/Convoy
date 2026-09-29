import Foundation
import SwiftData

// MARK: - Persistence Controller

/// Centralized SwiftData persistence manager providing live and in-memory test/preview containers.
@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    
    var mainContext: ModelContext {
        container.mainContext
    }
    
    init(inMemory: Bool = false) {
        let schema = Schema([
            User.self,
            Motorcycle.self,
            EmergencyContact.self,
            Friend.self,
            Club.self,
            Ride.self,
            RideParticipant.self,
            Waypoint.self,
            RidePhoto.self,
            RideJournal.self,
            ClubMember.self,
            SafetyEvent.self,
            Hazard.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to initialize Convoy ModelContainer: \(error.localizedDescription)")
        }
    }
    
    /// Dedicated preview container pre-seeded with sample data for SwiftUI canvas previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        DemoDataService.shared.populateIfNeeded(modelContext: controller.mainContext)
        return controller
    }()
}
