import Foundation
import SwiftData
import CoreLocation

// MARK: - Demo Data Service

/// Generates realistic demo data for simulator/presentation mode.
/// All demo data uses Indian geography consistent with the spec.
@MainActor
final class DemoDataService {
    
    static let shared = DemoDataService()
    private init() {}
    
    // MARK: - Demo Users
    
    /// The current signed-in user for demo mode
    func createCurrentUser() -> User {
        let user = User(
            name: "Kevin Mathews",
            username: "kevin.rides",
            email: "kevin@convoy.app",
            profileImageName: "kevin_avatar",
            ridingExperience: .experienced,
            bio: "Weekend warrior. Love coastal roads and mountain passes.",
            unitPreference: .metric,
            totalRides: 24,
            totalDistanceKm: 3420,
            totalRidingTimeSeconds: 108000,
            motorcycles: [],
            emergencyContacts: []
        )
        
        // Add motorcycles
        user.motorcycles = [
            Motorcycle(
                manufacturer: "Royal Enfield",
                model: "Himalayan 450",
                year: 2024,
                isPrimary: true
            ),
            Motorcycle(
                manufacturer: "KTM",
                model: "Duke 390",
                year: 2023
            )
        ]
        
        // Add emergency contacts
        user.emergencyContacts = [
            EmergencyContact(name: "Sarah Mathews", phoneNumber: "+91 98765 43210", relationship: "Spouse"),
            EmergencyContact(name: "Dr. Rajan", phoneNumber: "+91 98765 12345", relationship: "Doctor")
        ]
        
        return user
    }
    
    // MARK: - Demo Friends
    
    func createFriends() -> [Friend] {
        [
            Friend(name: "Arun Kumar", username: "arun.rides", motorcycleName: "Yamaha R15 V4", onlineStatus: .online),
            Friend(name: "Rahul Nair", username: "rahul.n", motorcycleName: "KTM Duke 250", onlineStatus: .riding),
            Friend(name: "Vishal Mehta", username: "vishal.m", motorcycleName: "RE Classic 350", onlineStatus: .offline),
            Friend(name: "Priya Sharma", username: "priya.s", motorcycleName: "Honda CB300R", onlineStatus: .online),
            Friend(name: "Akhil Raj", username: "akhil.raj", motorcycleName: "Bajaj Dominar 400", onlineStatus: .offline),
        ]
    }
    
    // MARK: - Demo Clubs
    
    func createClubs() -> [Club] {
        let coastRiders = Club(
            name: "Coast Riders Chennai",
            clubDescription: "Weekend rides along the East Coast Road and beyond. All experience levels welcome.",
            visibility: .publicClub,
            creatorName: "Kevin Mathews",
            memberCount: 28,
            members: [
                ClubMember(name: "Kevin Mathews", username: "kevin.rides", isAdmin: true),
                ClubMember(name: "Arun Kumar", username: "arun.rides"),
                ClubMember(name: "Rahul Nair", username: "rahul.n"),
                ClubMember(name: "Priya Sharma", username: "priya.s"),
            ]
        )
        
        let hillClimbers = Club(
            name: "Hill Climbers",
            clubDescription: "Mountain roads, ghats, and high-altitude rides. Experienced riders preferred.",
            visibility: .privateClub,
            creatorName: "Arun Kumar",
            memberCount: 15,
            members: [
                ClubMember(name: "Arun Kumar", username: "arun.rides", isAdmin: true),
                ClubMember(name: "Kevin Mathews", username: "kevin.rides"),
                ClubMember(name: "Vishal Mehta", username: "vishal.m"),
            ]
        )
        
        return [coastRiders, hillClimbers]
    }
    
    // MARK: - Demo Rides
    
    // Chennai area coordinates
    static let chennai = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
    static let mahabalipuram = CLLocationCoordinate2D(latitude: 12.6269, longitude: 80.1927)
    static let pondicherry = CLLocationCoordinate2D(latitude: 11.9416, longitude: 79.8083)
    static let yelagiri = CLLocationCoordinate2D(latitude: 12.5790, longitude: 78.6346)
    static let tambaram = CLLocationCoordinate2D(latitude: 12.9249, longitude: 80.1000)
    static let chengalpattu = CLLocationCoordinate2D(latitude: 12.6819, longitude: 79.9888)
    static let ecr_midpoint = CLLocationCoordinate2D(latitude: 12.8400, longitude: 80.2200)
    
    func createRides() -> [Ride] {
        let now = Date()
        let calendar = Calendar.current
        
        // Upcoming ride (planned)
        let upcomingDate = calendar.date(byAdding: .day, value: 2, to: now)!
        let upcomingRide = Ride(
            name: "Saturday Coastal Run",
            rideDescription: "Classic ECR run to Mahabalipuram. Breakfast at a beach shack.",
            status: .planned,
            style: .scenic,
            startStructure: .separateConverge,
            startLocationName: "Chennai",
            startCoordinate: Self.chennai,
            destinationName: "Mahabalipuram",
            destinationCoordinate: Self.mahabalipuram,
            meetingPointName: "ECR Toll Plaza",
            meetingPointCoordinate: Self.ecr_midpoint,
            scheduledDate: upcomingDate,
            estimatedDistanceKm: 58,
            estimatedDurationSeconds: 5400,
            organizerName: "Kevin Mathews",
            participants: [
                RideParticipant(name: "Kevin Mathews", username: "kevin.rides", role: .lead, riderStatus: .joined, invitationStatus: .accepted, startCoordinate: Self.chennai, startLocationName: "Chennai"),
                RideParticipant(name: "Arun Kumar", username: "arun.rides", role: .rider, riderStatus: .joined, invitationStatus: .accepted, startCoordinate: Self.tambaram, startLocationName: "Tambaram"),
                RideParticipant(name: "Rahul Nair", username: "rahul.n", role: .tail, riderStatus: .joined, invitationStatus: .accepted, startCoordinate: Self.chengalpattu, startLocationName: "Chengalpattu"),
                RideParticipant(name: "Priya Sharma", username: "priya.s", role: .rider, invitationStatus: .pending),
                RideParticipant(name: "Vishal Mehta", username: "vishal.m", role: .rider, riderStatus: .joined, invitationStatus: .accepted),
            ]
        )
        
        // Active ride (for demo simulation)
        let activeRide = Ride(
            name: "Pondicherry Express",
            rideDescription: "Full day ride to Pondicherry via ECR.",
            status: .active,
            style: .destination,
            startStructure: .together,
            startLocationName: "Chennai",
            startCoordinate: Self.chennai,
            destinationName: "Pondicherry",
            destinationCoordinate: Self.pondicherry,
            scheduledDate: now,
            startedAt: calendar.date(byAdding: .hour, value: -1, to: now),
            estimatedDistanceKm: 162,
            estimatedDurationSeconds: 14400,
            organizerName: "Kevin Mathews",
            participants: createActiveRideParticipants()
        )
        activeRide.actualDistanceKm = 48
        activeRide.averageSpeedKmh = 52
        activeRide.maxSpeedKmh = 89
        
        // Completed ride (yesterday)
        let yesterdayDate = calendar.date(byAdding: .day, value: -3, to: now)!
        let completedRide = Ride(
            name: "Yelagiri Hill Climb",
            rideDescription: "Mountain roads to Yelagiri. 14 hairpin bends.",
            status: .completed,
            style: .curvy,
            startStructure: .together,
            startLocationName: "Chennai",
            startCoordinate: Self.chennai,
            destinationName: "Yelagiri Hills",
            destinationCoordinate: Self.yelagiri,
            scheduledDate: yesterdayDate,
            startedAt: yesterdayDate,
            estimatedDistanceKm: 228,
            estimatedDurationSeconds: 18000,
            organizerName: "Arun Kumar",
            participants: [
                RideParticipant(name: "Arun Kumar", username: "arun.rides", role: .lead, riderStatus: .finished, invitationStatus: .accepted),
                RideParticipant(name: "Kevin Mathews", username: "kevin.rides", role: .rider, riderStatus: .finished, invitationStatus: .accepted),
                RideParticipant(name: "Vishal Mehta", username: "vishal.m", role: .tail, riderStatus: .finished, invitationStatus: .accepted),
            ]
        )
        completedRide.completedAt = calendar.date(byAdding: .hour, value: 5, to: yesterdayDate)
        completedRide.actualDistanceKm = 234
        completedRide.actualDurationSeconds = 19200
        completedRide.averageSpeedKmh = 44
        completedRide.maxSpeedKmh = 78
        completedRide.movingTimeSeconds = 16800
        
        return [upcomingRide, activeRide, completedRide]
    }
    
    private func createActiveRideParticipants() -> [RideParticipant] {
        // Simulated positions along ECR towards Pondicherry
        let leadPos = CLLocationCoordinate2D(latitude: 12.7800, longitude: 80.2100)
        let groupPos = CLLocationCoordinate2D(latitude: 12.7950, longitude: 80.2150)
        let behindPos = CLLocationCoordinate2D(latitude: 12.8200, longitude: 80.2200)
        let tailPos = CLLocationCoordinate2D(latitude: 12.8400, longitude: 80.2250)
        
        let lead = RideParticipant(name: "Kevin Mathews", username: "kevin.rides", role: .lead, riderStatus: .moving, invitationStatus: .accepted)
        lead.currentLatitude = leadPos.latitude
        lead.currentLongitude = leadPos.longitude
        lead.currentSpeedKmh = 62
        lead.currentHeading = 195
        lead.lastUpdated = Date()
        
        let rider1 = RideParticipant(name: "Arun Kumar", username: "arun.rides", role: .rider, riderStatus: .moving, invitationStatus: .accepted, startCoordinate: nil, startLocationName: nil)
        rider1.currentLatitude = groupPos.latitude
        rider1.currentLongitude = groupPos.longitude
        rider1.currentSpeedKmh = 58
        rider1.lastUpdated = Date()
        
        let rider2 = RideParticipant(name: "Priya Sharma", username: "priya.s", motorcycleName: "Honda CB300R", role: .rider, riderStatus: .moving, invitationStatus: .accepted)
        rider2.currentLatitude = groupPos.latitude + 0.002
        rider2.currentLongitude = groupPos.longitude + 0.001
        rider2.currentSpeedKmh = 55
        rider2.lastUpdated = Date()
        
        let rider3 = RideParticipant(name: "Rahul Nair", username: "rahul.n", motorcycleName: "KTM Duke 250", role: .rider, riderStatus: .stopped, invitationStatus: .accepted)
        rider3.currentLatitude = behindPos.latitude
        rider3.currentLongitude = behindPos.longitude
        rider3.currentSpeedKmh = 0
        rider3.lastUpdated = Date().addingTimeInterval(-120)
        rider3.distanceFromGroupKm = 1.8
        
        let tail = RideParticipant(name: "Vishal Mehta", username: "vishal.m", motorcycleName: "RE Classic 350", role: .tail, riderStatus: .moving, invitationStatus: .accepted)
        tail.currentLatitude = tailPos.latitude
        tail.currentLongitude = tailPos.longitude
        tail.currentSpeedKmh = 45
        tail.lastUpdated = Date()
        
        return [lead, rider1, rider2, rider3, tail]
    }
    
    // MARK: - Demo Journal
    
    func createJournal(for ride: Ride) -> RideJournal {
        RideJournal(
            rideId: ride.id,
            title: "The Yelagiri Hill Climb",
            summary: "Three riders conquered the 14 hairpin bends to Yelagiri Hills on a perfect riding day.",
            narrative: """
            The morning started early at Chennai, with three riders gathering at the Poonamallee bypass at 6 AM. \
            The air was cool and the roads empty — perfect conditions for the 228 km ride ahead.

            The first stretch along NH48 was smooth highway cruising. The group maintained a steady 70 km/h, \
            with Arun leading the way. By 8 AM, they'd covered the first 100 km and stopped at a roadside \
            chai stall near Vellore for a quick break.

            The real adventure began at the base of Yelagiri Hills. The 14 hairpin bends tested everyone's \
            cornering skills. Kevin's Himalayan handled the steep gradients effortlessly, while Vishal's \
            Classic 350 added a beautiful exhaust note echoing through the mountains.

            At the summit, the view was worth every kilometer. The group spent an hour at the viewpoint \
            before heading to a local restaurant for a well-earned biryani lunch.
            """,
            highlights: [
                "14 hairpin bends conquered",
                "Perfect weather throughout",
                "Sunrise chai stop at Vellore",
                "Summit viewpoint photo session"
            ],
            distanceKm: 234,
            durationSeconds: 19200,
            averageSpeedKmh: 44,
            maxSpeedKmh: 78,
            riderCount: 3,
            stopCount: 4
        )
    }
    
    // MARK: - Populate Database
    
    func populateIfNeeded(modelContext: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<User>()
        let existingUsers = (try? modelContext.fetch(descriptor)) ?? []
        
        guard existingUsers.isEmpty else { return }
        
        // Insert user
        let user = createCurrentUser()
        modelContext.insert(user)
        
        // Insert friends
        for friend in createFriends() {
            modelContext.insert(friend)
        }
        
        // Insert clubs
        for club in createClubs() {
            modelContext.insert(club)
        }
        
        // Insert rides
        for ride in createRides() {
            modelContext.insert(ride)
        }
        
        try? modelContext.save()
    }
}
