import Foundation
import SwiftData
import CoreLocation

// MARK: - User

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var username: String
    var email: String
    var profileImageName: String?
    var ridingExperienceRaw: String
    var bio: String
    var unitPreferenceRaw: String
    
    // Statistics
    var totalRides: Int
    var totalDistanceKm: Double
    var totalRidingTimeSeconds: Double
    
    // Privacy
    var isLocationSharingEnabled: Bool
    var isProfilePublic: Bool
    
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var motorcycles: [Motorcycle]
    @Relationship(deleteRule: .cascade) var emergencyContacts: [EmergencyContact]
    
    var ridingExperience: RidingExperience {
        get { RidingExperience(rawValue: ridingExperienceRaw) ?? .intermediate }
        set { ridingExperienceRaw = newValue.rawValue }
    }
    
    var unitPreference: UnitPreference {
        get { UnitPreference(rawValue: unitPreferenceRaw) ?? .metric }
        set { unitPreferenceRaw = newValue.rawValue }
    }
    
    var totalRidingTimeDuration: TimeInterval { totalRidingTimeSeconds }
    
    var primaryMotorcycle: Motorcycle? {
        motorcycles.first { $0.isPrimary } ?? motorcycles.first
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        username: String,
        email: String = "",
        profileImageName: String? = nil,
        ridingExperience: RidingExperience = .intermediate,
        bio: String = "",
        unitPreference: UnitPreference = .metric,
        totalRides: Int = 0,
        totalDistanceKm: Double = 0,
        totalRidingTimeSeconds: Double = 0,
        isLocationSharingEnabled: Bool = true,
        isProfilePublic: Bool = true,
        motorcycles: [Motorcycle] = [],
        emergencyContacts: [EmergencyContact] = []
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.profileImageName = profileImageName
        self.ridingExperienceRaw = ridingExperience.rawValue
        self.bio = bio
        self.unitPreferenceRaw = unitPreference.rawValue
        self.totalRides = totalRides
        self.totalDistanceKm = totalDistanceKm
        self.totalRidingTimeSeconds = totalRidingTimeSeconds
        self.isLocationSharingEnabled = isLocationSharingEnabled
        self.isProfilePublic = isProfilePublic
        self.createdAt = Date()
        self.motorcycles = motorcycles
        self.emergencyContacts = emergencyContacts
    }
}

// MARK: - Motorcycle

@Model
final class Motorcycle {
    @Attribute(.unique) var id: UUID
    var name: String
    var manufacturer: String
    var model: String
    var year: Int
    var photoName: String?
    var notes: String
    var isPrimary: Bool
    
    init(
        id: UUID = UUID(),
        name: String = "",
        manufacturer: String,
        model: String,
        year: Int = Calendar.current.component(.year, from: Date()),
        photoName: String? = nil,
        notes: String = "",
        isPrimary: Bool = false
    ) {
        self.id = id
        self.name = name.isEmpty ? "\(manufacturer) \(model)" : name
        self.manufacturer = manufacturer
        self.model = model
        self.year = year
        self.photoName = photoName
        self.notes = notes
        self.isPrimary = isPrimary
    }
    
    var displayName: String {
        name.isEmpty ? "\(manufacturer) \(model)" : name
    }
    
    var subtitle: String {
        "\(year) \(manufacturer) \(model)"
    }
}

// MARK: - Emergency Contact

@Model
final class EmergencyContact {
    @Attribute(.unique) var id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    
    init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        relationship: String = ""
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
    }
}

// MARK: - Friend (lightweight reference)

@Model
final class Friend {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var name: String
    var username: String
    var profileImageName: String?
    var motorcycleName: String?
    var onlineStatusRaw: String
    var isEmergencyContact: Bool = false
    var addedAt: Date
    
    var onlineStatus: OnlineStatus {
        get { OnlineStatus(rawValue: onlineStatusRaw) ?? .offline }
        set { onlineStatusRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        name: String,
        username: String,
        profileImageName: String? = nil,
        motorcycleName: String? = nil,
        onlineStatus: OnlineStatus = .offline
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.username = username
        self.profileImageName = profileImageName
        self.motorcycleName = motorcycleName
        self.onlineStatusRaw = onlineStatus.rawValue
        self.addedAt = Date()
    }
    
    var motorcycle: String? {
        get { motorcycleName }
        set { motorcycleName = newValue }
    }
    
    convenience init(
        name: String,
        username: String,
        motorcycle: String? = nil
    ) {
        self.init(
            name: name,
            username: username,
            motorcycleName: motorcycle
        )
    }
}
