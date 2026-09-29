import SwiftUI
import CoreLocation

// MARK: - Ride Lifecycle

/// The state machine for a ride's lifecycle.
enum RideStatus: String, Codable, CaseIterable {
    case planned
    case lobby
    case starting
    case active
    case paused
    case completed
    case cancelled
    
    // Compatibility alias
    static let scheduled = RideStatus.planned
    
    var label: String {
        switch self {
        case .planned: return "Planned"
        case .lobby: return "Lobby"
        case .starting: return "Starting"
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var icon: String {
        switch self {
        case .planned: return "calendar"
        case .lobby: return "person.3.fill"
        case .starting: return "flag.checkered"
        case .active: return "location.fill"
        case .paused: return "pause.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .planned: return .convoyTextSecondaryFallback
        case .lobby: return .convoyWarningFallback
        case .starting, .active: return .convoySuccessFallback
        case .paused: return .convoyWarningFallback
        case .completed: return .convoyAccentFallback
        case .cancelled: return .convoySafetyFallback
        }
    }
}

// MARK: - Rider Status

/// Individual rider status during a ride.
enum RiderStatus: String, Codable, CaseIterable {
    case invited
    case joined
    case ready
    case moving
    case stopped
    case paused
    case offRoute
    case separated
    case disconnected
    case finished
    
    var label: String {
        switch self {
        case .invited: return "Invited"
        case .joined: return "Joined"
        case .ready: return "Ready"
        case .moving: return "Moving"
        case .stopped: return "Stopped"
        case .paused: return "Paused"
        case .offRoute: return "Off Route"
        case .separated: return "Separated"
        case .disconnected: return "Disconnected"
        case .finished: return "Finished"
        }
    }
    
    var icon: String {
        switch self {
        case .invited: return "envelope.fill"
        case .joined: return "checkmark.circle.fill"
        case .ready: return "figure.stand"
        case .moving: return "figure.outdoor.cycle"
        case .stopped: return "stop.circle.fill"
        case .paused: return "pause.circle.fill"
        case .offRoute: return "arrow.triangle.turn.up.right.diamond.fill"
        case .separated: return "exclamationmark.triangle.fill"
        case .disconnected: return "wifi.slash"
        case .finished: return "flag.checkered"
        }
    }
    
    var color: Color {
        switch self {
        case .invited: return .convoyTextSecondaryFallback
        case .joined, .ready: return .convoyAccentFallback
        case .moving: return .convoySuccessFallback
        case .stopped, .paused: return .convoyWarningFallback
        case .offRoute, .separated: return .convoySafetyFallback
        case .disconnected: return .convoyTextTertiaryFallback
        case .finished: return .convoySuccessFallback
        }
    }
}

// MARK: - Group Alert Level

enum GroupAlertLevel: String, Codable {
    case safe
    case watch
    case actionNeeded
    
    // Compatibility aliases
    static let warning = GroupAlertLevel.watch
    static let critical = GroupAlertLevel.actionNeeded
    
    var label: String {
        switch self {
        case .safe: return "All Together"
        case .watch: return "Watch"
        case .actionNeeded: return "Action Needed"
        }
    }
    
    var color: Color {
        switch self {
        case .safe: return .convoySuccessFallback
        case .watch: return .convoyWarningFallback
        case .actionNeeded: return .convoySafetyFallback
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.shield.fill"
        case .watch: return "eye.fill"
        case .actionNeeded: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Ride Style

enum RideStyle: String, Codable, CaseIterable, Identifiable {
    case destination
    case scenic
    case curvy
    case roundTrip
    case custom
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .destination: return "Destination"
        case .scenic: return "Scenic"
        case .curvy: return "Curvy"
        case .roundTrip: return "Round Trip"
        case .custom: return "Custom"
        }
    }
    
    var icon: String {
        switch self {
        case .destination: return "mappin.and.ellipse"
        case .scenic: return "mountain.2.fill"
        case .curvy: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .roundTrip: return "arrow.triangle.2.circlepath"
        case .custom: return "pencil.and.ruler.fill"
        }
    }
    
    var description: String {
        switch self {
        case .destination: return "Point to point"
        case .scenic: return "Beautiful roads"
        case .curvy: return "Twisties & bends"
        case .roundTrip: return "Back to start"
        case .custom: return "Your own route"
        }
    }
}

// MARK: - Route Preference

enum RoutePreference: String, Codable, CaseIterable, Identifiable {
    case fast
    case scenic
    case curvy
    case custom
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .fast: return "Fast"
        case .scenic: return "Scenic"
        case .curvy: return "Curvy"
        case .custom: return "Custom"
        }
    }
    
    var icon: String {
        switch self {
        case .fast: return "hare.fill"
        case .scenic: return "eye.fill"
        case .curvy: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
}

// MARK: - Start Structure

enum StartStructure: String, Codable, CaseIterable, Identifiable {
    case together
    case separateConverge
    case multiGroup
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .together: return "Start Together"
        case .separateConverge: return "Meet at a Point"
        case .multiGroup: return "Multiple Groups"
        }
    }
    
    var description: String {
        switch self {
        case .together: return "Everyone departs from the same location"
        case .separateConverge: return "Riders start separately, meet at a point"
        case .multiGroup: return "Groups converge at selected points"
        }
    }
    
    var icon: String {
        switch self {
        case .together: return "person.3.fill"
        case .separateConverge: return "arrow.triangle.merge"
        case .multiGroup: return "point.3.connected.trianglepath.dotted"
        }
    }
}

// MARK: - Rider Role

enum RiderRole: String, Codable {
    case organizer
    case lead
    case tail
    case rider
    
    static var sweep: RiderRole { .tail }
    
    var label: String {
        switch self {
        case .organizer: return "Organizer"
        case .lead: return "Lead"
        case .tail: return "Sweep"
        case .rider: return "Rider"
        }
    }
    
    var icon: String {
        switch self {
        case .organizer: return "crown.fill"
        case .lead: return "flag.fill"
        case .tail: return "shield.fill"
        case .rider: return "figure.outdoor.cycle"
        }
    }
}

// MARK: - Map Layer

enum MapLayerType: String, CaseIterable, Identifiable {
    case standard
    case satellite
    case hybrid
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .standard: return "Standard"
        case .satellite: return "Satellite"
        case .hybrid: return "Hybrid"
        }
    }
    
    var icon: String {
        switch self {
        case .standard: return "map.fill"
        case .satellite: return "globe.americas.fill"
        case .hybrid: return "square.stack.3d.up.fill"
        }
    }
}

// MARK: - Hazard Type

enum HazardType: String, Codable, CaseIterable, Identifiable {
    case pothole
    case gravel
    case oil
    case accident
    case roadClosure
    case construction
    case other
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .pothole: return "Pothole"
        case .gravel: return "Gravel"
        case .oil: return "Oil Spill"
        case .accident: return "Accident"
        case .roadClosure: return "Road Closed"
        case .construction: return "Construction"
        case .other: return "Hazard"
        }
    }
    
    var icon: String {
        switch self {
        case .pothole: return "circle.dashed"
        case .gravel: return "triangle.fill"
        case .oil: return "drop.fill"
        case .accident: return "exclamationmark.triangle.fill"
        case .roadClosure: return "xmark.octagon.fill"
        case .construction: return "cone.fill"
        case .other: return "exclamationmark.circle.fill"
        }
    }
}

// MARK: - Safety Event Type

enum SafetyEventType: String, Codable {
    case sos
    case crashDetected
    case riderSeparated
    case riderDisconnected
    case riderStopped
    case routeDeviation
}

// MARK: - Notification Category

enum NotificationCategory: String, Codable {
    case social
    case ride
    case safety
    
    var color: Color {
        switch self {
        case .social: return .convoyAccentFallback
        case .ride: return .convoySuccessFallback
        case .safety: return .convoySafetyFallback
        }
    }
}

// MARK: - Club Visibility

enum ClubVisibility: String, Codable, CaseIterable, Identifiable {
    case publicClub
    case privateClub
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .publicClub: return "Public"
        case .privateClub: return "Private"
        }
    }
    
    var description: String {
        switch self {
        case .publicClub: return "Anyone can find and request to join"
        case .privateClub: return "Invite only"
        }
    }
}

// MARK: - Online Status

enum OnlineStatus: String, Codable {
    case online
    case riding
    case offline
    
    var color: Color {
        switch self {
        case .online: return .convoySuccessFallback
        case .riding: return .convoyAccentFallback
        case .offline: return .convoyTextTertiaryFallback
        }
    }
    
    var label: String {
        switch self {
        case .online: return "Online"
        case .riding: return "Riding"
        case .offline: return "Offline"
        }
    }
}

// MARK: - Unit Preference

enum UnitPreference: String, Codable, CaseIterable, Identifiable {
    case metric
    case imperial
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .metric: return "Kilometers"
        case .imperial: return "Miles"
        }
    }
    
    var distanceUnit: String {
        switch self {
        case .metric: return "km"
        case .imperial: return "mi"
        }
    }
    
    var speedUnit: String {
        switch self {
        case .metric: return "km/h"
        case .imperial: return "mph"
        }
    }
}

// MARK: - Invitation Status

enum InvitationStatus: String, Codable {
    case pending
    case accepted
    case declined
    case expired
    
    var label: String {
        switch self {
        case .pending: return "Invited"
        case .accepted: return "Joined"
        case .declined: return "Declined"
        case .expired: return "Expired"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .convoyWarningFallback
        case .accepted: return .convoySuccessFallback
        case .declined: return .convoySafetyFallback
        case .expired: return .convoyTextTertiaryFallback
        }
    }
}

// MARK: - Riding Experience

enum RidingExperience: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case experienced
    case expert
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .experienced: return "Experienced"
        case .expert: return "Expert"
        }
    }
}

// MARK: - App Tab

enum ConvoyTab: String, CaseIterable, Identifiable {
    case home
    case clubs
    case rides
    case friends
    case profile
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .home: return "Home"
        case .clubs: return "Clubs"
        case .rides: return "Rides"
        case .friends: return "Friends"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .clubs: return "shield.fill"
        case .rides: return "road.lanes"
        case .friends: return "person.2.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

// MARK: - Formation & Riding Dynamics

enum Formation: String, Codable, CaseIterable, Identifiable {
    case staggered
    case singleFile
    case freePace
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .staggered: return "Staggered"
        case .singleFile: return "Single File"
        case .freePace: return "Free Pace"
        }
    }
}

enum Pace: String, Codable, CaseIterable, Identifiable {
    case relaxed
    case moderate
    case spirited
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .relaxed: return "Relaxed (Cruising)"
        case .moderate: return "Moderate (Brisk)"
        case .spirited: return "Spirited (Fast)"
        }
    }
}

enum RidingStyle: String, Codable, CaseIterable, Identifiable {
    case cruising
    case curvaceous
    case twisty
    case adventure
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .cruising: return "Scenic Cruising"
        case .curvaceous: return "Curvaceous Twisties"
        case .twisty: return "Ghat Passes"
        case .adventure: return "Adventure Trail"
        }
    }
}

enum WaypointType: String, Codable, CaseIterable, Identifiable {
    case meetingPoint
    case stop
    case food
    case fuel
    case viewpoint
    case destination
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .meetingPoint: return "Meeting Point"
        case .stop: return "Stop"
        case .food: return "Food & Chai"
        case .fuel: return "Fuel Station"
        case .viewpoint: return "Scenic Viewpoint"
        case .destination: return "Destination"
        }
    }
    
    var icon: String {
        switch self {
        case .meetingPoint: return "flag.fill"
        case .stop: return "mappin.circle.fill"
        case .food: return "cup.and.saucer.fill"
        case .fuel: return "fuelpump.fill"
        case .viewpoint: return "camera.fill"
        case .destination: return "flag.checkered"
        }
    }
}
