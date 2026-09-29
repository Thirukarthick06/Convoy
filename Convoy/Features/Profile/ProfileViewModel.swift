import SwiftUI
import SwiftData

// MARK: - Profile View Model

@MainActor
@Observable
final class ProfileViewModel {
    var showGarage: Bool = false
    var showEmergencyContacts: Bool = false
    var showSettings: Bool = false
    var showRideJournal: Bool = false
    
    func addMotorcycle(
        name: String,
        manufacturer: String,
        model: String,
        year: Int,
        isPrimary: Bool,
        user: User?,
        context: ModelContext
    ) {
        guard let user else { return }
        
        if isPrimary {
            for bike in user.motorcycles {
                bike.isPrimary = false
            }
        }
        
        let bike = Motorcycle(
            name: name,
            manufacturer: manufacturer,
            model: model,
            year: year,
            isPrimary: isPrimary
        )
        user.motorcycles.append(bike)
        try? context.save()
        HapticManager.shared.success()
    }
    
    func addEmergencyContact(
        name: String,
        phone: String,
        relationship: String,
        user: User?,
        context: ModelContext
    ) {
        guard let user else { return }
        let contact = EmergencyContact(name: name, phoneNumber: phone, relationship: relationship)
        user.emergencyContacts.append(contact)
        try? context.save()
        HapticManager.shared.success()
    }
}
