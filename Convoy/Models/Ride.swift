import Foundation
import SwiftData
import CoreLocation

// MARK: - Ride

@Model
final class Ride {
    @Attribute(.unique) var id: UUID
    var name: String
    var rideDescription: String
    var statusRaw: String
    var styleRaw: String
    var startStructureRaw: String
    var formationRaw: String = Formation.staggered.rawValue
    
    // Location
    var startLocationName: String
    var startLatitude: Double
    var startLongitude: Double
    var destinationName: String
    var destinationLatitude: Double
    var destinationLongitude: Double
    var meetingPointName: String?
    var meetingPointLatitude: Double?
    var meetingPointLongitude: Double?
    
    // Timing
    var scheduledDate: Date
    var startedAt: Date?
    var completedAt: Date?
    
    // Route info
    var estimatedDistanceKm: Double
    var estimatedDurationSeconds: Double
    var actualDistanceKm: Double?
    var actualDurationSeconds: Double?
    
    // Tracking
    var averageSpeedKmh: Double?
    var maxSpeedKmh: Double?
    var movingTimeSeconds: Double?
    
    // Organizer
    var organizerId: UUID
    var organizerName: String
    
    // Participants
    @Relationship(deleteRule: .cascade) var participants: [RideParticipant]
    @Relationship(deleteRule: .cascade) var waypoints: [Waypoint]
    @Relationship(deleteRule: .cascade) var ridePhotos: [RidePhoto]
    
    // Journal
    var journalId: UUID?
    
    var createdAt: Date
    
    var status: RideStatus {
        get { RideStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }
    
    var style: RideStyle {
        get { RideStyle(rawValue: styleRaw) ?? .destination }
        set { styleRaw = newValue.rawValue }
    }
    
    var startStructure: StartStructure {
        get { StartStructure(rawValue: startStructureRaw) ?? .together }
        set { startStructureRaw = newValue.rawValue }
    }
    
    var startCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
    }
    
    var destinationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
    }
    
    var meetingPointCoordinate: CLLocationCoordinate2D? {
        guard let lat = meetingPointLatitude, let lon = meetingPointLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var participantCount: Int { participants.count }
    
    var isUpcoming: Bool { status == .planned || status == .lobby }
    var isActive: Bool { status == .active || status == .starting || status == .paused }
    var isCompleted: Bool { status == .completed }
    
    var estimatedDuration: TimeInterval { estimatedDurationSeconds }
    var actualDuration: TimeInterval? { actualDurationSeconds }
    
    // Convenience aliases for views
    var title: String {
        get { name }
        set { name = newValue }
    }
    var endLocationName: String {
        get { destinationName }
        set { destinationName = newValue }
    }
    var distanceKm: Double {
        get { estimatedDistanceKm }
        set { estimatedDistanceKm = newValue }
    }
    var endLatitude: Double {
        get { destinationLatitude }
        set { destinationLatitude = newValue }
    }
    var endLongitude: Double {
        get { destinationLongitude }
        set { destinationLongitude = newValue }
    }
    var leaderRiderId: UUID? { organizerId }
    var ridingStyle: RidingStyle { .curvaceous }
    var formation: Formation {
        get { Formation(rawValue: formationRaw) ?? .staggered }
        set { formationRaw = newValue.rawValue }
    }
    var pace: Pace { .moderate }
    var isClubRide: Bool {
        get { startStructure == .separateConverge || name.localizedCaseInsensitiveContains("club") }
        set { }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        rideDescription: String = "",
        status: RideStatus = .planned,
        style: RideStyle = .destination,
        startStructure: StartStructure = .together,
        startLocationName: String = "",
        startCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        destinationName: String = "",
        destinationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        meetingPointName: String? = nil,
        meetingPointCoordinate: CLLocationCoordinate2D? = nil,
        scheduledDate: Date = Date(),
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        estimatedDistanceKm: Double = 0,
        estimatedDurationSeconds: Double = 0,
        organizerId: UUID = UUID(),
        organizerName: String = "",
        participants: [RideParticipant] = [],
        waypoints: [Waypoint] = [],
        ridePhotos: [RidePhoto] = []
    ) {
        self.id = id
        self.name = name
        self.rideDescription = rideDescription
        self.statusRaw = status.rawValue
        self.styleRaw = style.rawValue
        self.startStructureRaw = startStructure.rawValue
        self.startLocationName = startLocationName
        self.startLatitude = startCoordinate.latitude
        self.startLongitude = startCoordinate.longitude
        self.destinationName = destinationName
        self.destinationLatitude = destinationCoordinate.latitude
        self.destinationLongitude = destinationCoordinate.longitude
        self.meetingPointName = meetingPointName
        self.meetingPointLatitude = meetingPointCoordinate?.latitude
        self.meetingPointLongitude = meetingPointCoordinate?.longitude
        self.scheduledDate = scheduledDate
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.estimatedDistanceKm = estimatedDistanceKm
        self.estimatedDurationSeconds = estimatedDurationSeconds
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.participants = participants
        self.waypoints = waypoints
        self.ridePhotos = ridePhotos
        self.createdAt = Date()
    }
    
    convenience init(
        title: String,
        rideDescription: String = "",
        scheduledDate: Date = Date(),
        startLocationName: String = "",
        startLatitude: Double = 0,
        startLongitude: Double = 0,
        endLocationName: String = "",
        endLatitude: Double = 0,
        endLongitude: Double = 0,
        distanceKm: Double = 0,
        estimatedDurationSeconds: Double = 0,
        ridingStyle: RidingStyle = .curvaceous,
        formation: Formation = .staggered,
        pace: Pace = .moderate,
        organizerId: UUID = UUID(),
        organizerName: String = "",
        leaderRiderId: UUID? = nil,
        participants: [RideParticipant] = []
    ) {
        self.init(
            name: title,
            rideDescription: rideDescription,
            status: .planned,
            style: .destination,
            startStructure: .together,
            startLocationName: startLocationName,
            startCoordinate: CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude),
            destinationName: endLocationName,
            destinationCoordinate: CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude),
            scheduledDate: scheduledDate,
            estimatedDistanceKm: distanceKm,
            estimatedDurationSeconds: estimatedDurationSeconds,
            organizerId: organizerId,
            organizerName: organizerName,
            participants: participants
        )
        self.formation = formation
    }
}

// MARK: - Ride Participant

@Model
final class RideParticipant {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var name: String
    var username: String
    var profileImageName: String?
    var motorcycleName: String?
    
    var roleRaw: String
    var statusRaw: String
    var invitationStatusRaw: String
    
    // Live position
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentSpeedKmh: Double?
    var currentHeading: Double?
    var lastUpdated: Date?
    
    // Start location (for separate starts)
    var startLatitude: Double?
    var startLongitude: Double?
    var startLocationName: String?
    
    var distanceFromGroupKm: Double?
    
    var role: RiderRole {
        get { RiderRole(rawValue: roleRaw) ?? .rider }
        set { roleRaw = newValue.rawValue }
    }
    
    var riderStatus: RiderStatus {
        get { RiderStatus(rawValue: statusRaw) ?? .invited }
        set { statusRaw = newValue.rawValue }
    }
    
    var invitationStatus: InvitationStatus {
        get { InvitationStatus(rawValue: invitationStatusRaw) ?? .pending }
        set { invitationStatusRaw = newValue.rawValue }
    }
    
    var currentCoordinate: CLLocationCoordinate2D? {
        guard let lat = currentLatitude, let lon = currentLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var startCoordinate: CLLocationCoordinate2D? {
        guard let lat = startLatitude, let lon = startLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var isLead: Bool { role == .lead }
    var isTail: Bool { role == .tail }
    var isOrganizer: Bool { role == .organizer }
    
    // Convenience aliases
    var riderName: String { name }
    var riderId: UUID { userId }
    var status: RiderStatus {
        get { riderStatus }
        set { riderStatus = newValue }
    }
    var formationPosition: Int {
        if isLead { return 1 }
        if isTail { return 99 }
        return 2
    }
    var motorcycleModel: String? { motorcycleName }
    
    init(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        name: String,
        username: String = "",
        profileImageName: String? = nil,
        motorcycleName: String? = nil,
        role: RiderRole = .rider,
        riderStatus: RiderStatus = .invited,
        invitationStatus: InvitationStatus = .pending,
        startCoordinate: CLLocationCoordinate2D? = nil,
        startLocationName: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.username = username
        self.profileImageName = profileImageName
        self.motorcycleName = motorcycleName
        self.roleRaw = role.rawValue
        self.statusRaw = riderStatus.rawValue
        self.invitationStatusRaw = invitationStatus.rawValue
        self.startLatitude = startCoordinate?.latitude
        self.startLongitude = startCoordinate?.longitude
        self.startLocationName = startLocationName
    }
    
    convenience init(
        riderId: UUID,
        riderName: String,
        role: RiderRole = .rider,
        status: RiderStatus = .joined,
        formationPosition: Int = 1,
        motorcycleModel: String? = nil
    ) {
        self.init(
            userId: riderId,
            name: riderName,
            motorcycleName: motorcycleModel,
            role: role,
            riderStatus: status,
            invitationStatus: .accepted
        )
    }
}

// MARK: - Waypoint

@Model
final class Waypoint {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var order: Int
    var isStop: Bool
    var isMeetingPoint: Bool
    var notes: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var waypointType: WaypointType {
        if isMeetingPoint { return .meetingPoint }
        if isStop { return .stop }
        return .viewpoint
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        coordinate: CLLocationCoordinate2D,
        order: Int = 0,
        isStop: Bool = false,
        isMeetingPoint: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.order = order
        self.isStop = isStop
        self.isMeetingPoint = isMeetingPoint
        self.notes = notes
    }
    
    convenience init(
        name: String,
        latitude: Double,
        longitude: Double,
        order: Int,
        waypointType: WaypointType,
        notes: String = ""
    ) {
        self.init(
            name: name,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            order: order,
            isStop: waypointType == .stop || waypointType == .food || waypointType == .fuel,
            isMeetingPoint: waypointType == .meetingPoint,
            notes: notes
        )
    }
}

// MARK: - Ride Photo

@Model
final class RidePhoto {
    @Attribute(.unique) var id: UUID
    var imageName: String
    var caption: String
    var latitude: Double?
    var longitude: Double?
    var takenAt: Date
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    init(
        id: UUID = UUID(),
        imageName: String,
        caption: String = "",
        coordinate: CLLocationCoordinate2D? = nil,
        takenAt: Date = Date()
    ) {
        self.id = id
        self.imageName = imageName
        self.caption = caption
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
        self.takenAt = takenAt
    }
}
