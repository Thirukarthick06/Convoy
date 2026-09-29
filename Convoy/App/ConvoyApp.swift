import SwiftUI
import SwiftData

// MARK: - Convoy App

@main
struct ConvoyApp: App {
    @State private var appState = AppState()
    
    // SwiftData container with all domain models
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                User.self,
                Motorcycle.self,
                EmergencyContact.self,
                Friend.self,
                Club.self,
                ClubMember.self,
                Ride.self,
                RideParticipant.self,
                Waypoint.self,
                RidePhoto.self,
                RideJournal.self,
                SafetyEvent.self,
                Hazard.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
            
            // Seed sample data for preview and demo testing
            DemoDataService.shared.populateIfNeeded(modelContext: container.mainContext)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root View

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding && users.isEmpty {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            if let user = users.first {
                appState.currentUser = user
                appState.isAuthenticated = true
                appState.hasCompletedOnboarding = true
            }
        }
    }
}
