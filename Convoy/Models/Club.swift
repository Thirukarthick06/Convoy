import Foundation
import SwiftData
import CoreLocation

// MARK: - Club

@Model
final class Club {
    @Attribute(.unique) var id: UUID
    var name: String
    var clubDescription: String
    var coverImageName: String?
    var visibilityRaw: String
    var inviteCode: String
    
    var creatorId: UUID
    var creatorName: String
    
    var memberCount: Int
    var city: String
    var totalRides: Int
    var totalDistanceKm: Double
    var isVerified: Bool
    
    @Relationship(deleteRule: .cascade) var members: [ClubMember]
    
    var createdAt: Date
    
    var visibility: ClubVisibility {
        get { ClubVisibility(rawValue: visibilityRaw) ?? .publicClub }
        set { visibilityRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        clubDescription: String = "",
        city: String = "Chennai",
        coverImageName: String? = nil,
        visibility: ClubVisibility = .publicClub,
        inviteCode: String = "",
        creatorId: UUID = UUID(),
        creatorName: String = "",
        memberCount: Int = 1,
        totalRides: Int = 12,
        totalDistanceKm: Double = 1420.0,
        isVerified: Bool = true,
        members: [ClubMember] = []
    ) {
        self.id = id
        self.name = name
        self.clubDescription = clubDescription
        self.city = city
        self.coverImageName = coverImageName
        self.visibilityRaw = visibility.rawValue
        self.inviteCode = inviteCode.isEmpty ? String(UUID().uuidString.prefix(8)).uppercased() : inviteCode
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.memberCount = memberCount
        self.totalRides = totalRides
        self.totalDistanceKm = totalDistanceKm
        self.isVerified = isVerified
        self.members = members
        self.createdAt = Date()
    }
}

// MARK: - Club Member

@Model
final class ClubMember {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var name: String
    var username: String
    var profileImageName: String?
    var isAdmin: Bool
    var joinedAt: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        name: String,
        username: String = "",
        profileImageName: String? = nil,
        isAdmin: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.username = username
        self.profileImageName = profileImageName
        self.isAdmin = isAdmin
        self.joinedAt = Date()
    }
}

// MARK: - Ride Journal

@Model
final class RideJournal {
    @Attribute(.unique) var id: UUID
    var rideId: UUID
    var title: String
    var summary: String
    var narrative: String
    var highlights: [String]
    var coverImageName: String?
    
    // Ride statistics snapshot
    var distanceKm: Double
    var durationSeconds: Double
    var averageSpeedKmh: Double
    var maxSpeedKmh: Double
    var riderCount: Int
    var stopCount: Int
    
    var routeMapImageName: String?
    var createdAt: Date
    var isEdited: Bool
    
    var startLocation: String
    var endLocation: String
    
    var rideTitle: String {
        get { title }
        set { title = newValue }
    }
    
    var date: Date {
        get { createdAt }
        set { createdAt = newValue }
    }
    
    var duration: TimeInterval { durationSeconds }
    
    init(
        id: UUID = UUID(),
        rideId: UUID,
        title: String,
        summary: String = "",
        narrative: String = "",
        highlights: [String] = [],
        coverImageName: String? = nil,
        distanceKm: Double = 0,
        durationSeconds: Double = 0,
        averageSpeedKmh: Double = 0,
        maxSpeedKmh: Double = 0,
        riderCount: Int = 0,
        stopCount: Int = 0,
        routeMapImageName: String? = nil,
        startLocation: String = "",
        endLocation: String = ""
    ) {
        self.id = id
        self.rideId = rideId
        self.title = title
        self.summary = summary
        self.narrative = narrative
        self.highlights = highlights
        self.coverImageName = coverImageName
        self.distanceKm = distanceKm
        self.durationSeconds = durationSeconds
        self.averageSpeedKmh = averageSpeedKmh
        self.maxSpeedKmh = maxSpeedKmh
        self.riderCount = riderCount
        self.stopCount = stopCount
        self.routeMapImageName = routeMapImageName
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.createdAt = Date()
        self.isEdited = false
    }
    
    convenience init(
        rideId: UUID,
        rideTitle: String,
        date: Date = Date(),
        startLocation: String = "",
        endLocation: String = "",
        narrative: String = "",
        highlights: [String] = [],
        distanceKm: Double = 0,
        durationSeconds: Double = 0,
        averageSpeedKmh: Double = 0,
        maxSpeedKmh: Double = 0,
        riderCount: Int = 1,
        stopCount: Int = 0
    ) {
        self.init(
            rideId: rideId,
            title: rideTitle,
            summary: narrative,
            narrative: narrative,
            highlights: highlights,
            distanceKm: distanceKm,
            durationSeconds: durationSeconds,
            averageSpeedKmh: averageSpeedKmh,
            maxSpeedKmh: maxSpeedKmh,
            riderCount: riderCount,
            stopCount: stopCount,
            startLocation: startLocation,
            endLocation: endLocation
        )
        self.createdAt = date
    }
}

// MARK: - Safety Event

@Model
final class SafetyEvent {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var rideId: UUID?
    var userId: UUID
    var userName: String
    var latitude: Double
    var longitude: Double
    var message: String
    var isResolved: Bool
    var occurredAt: Date
    var resolvedAt: Date?
    
    var eventType: SafetyEventType {
        get { SafetyEventType(rawValue: typeRaw) ?? .sos }
        set { typeRaw = newValue.rawValue }
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(
        id: UUID = UUID(),
        eventType: SafetyEventType,
        rideId: UUID? = nil,
        userId: UUID,
        userName: String,
        coordinate: CLLocationCoordinate2D,
        message: String = ""
    ) {
        self.id = id
        self.typeRaw = eventType.rawValue
        self.rideId = rideId
        self.userId = userId
        self.userName = userName
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.message = message
        self.isResolved = false
        self.occurredAt = Date()
    }
}

// MARK: - Hazard

@Model
final class Hazard {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var latitude: Double
    var longitude: Double
    var reportedBy: String
    var note: String
    var isActive: Bool
    var reportedAt: Date
    var expiresAt: Date?
    
    var hazardType: HazardType {
        get { HazardType(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(
        id: UUID = UUID(),
        hazardType: HazardType,
        coordinate: CLLocationCoordinate2D,
        reportedBy: String = "",
        note: String = ""
    ) {
        self.id = id
        self.typeRaw = hazardType.rawValue
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.reportedBy = reportedBy
        self.note = note
        self.isActive = true
        self.reportedAt = Date()
        self.expiresAt = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
    }
    
    convenience init(
        hazardType: HazardType,
        latitude: Double,
        longitude: Double,
        hazardDescription: String
    ) {
        self.init(
            hazardType: hazardType,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            note: hazardDescription
        )
    }
}
