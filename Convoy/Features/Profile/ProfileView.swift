import SwiftUI
import SwiftData

// MARK: - Profile View

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var showGarage = false
    @State private var showEmergencyContacts = false
    @State private var showSettings = false
    @State private var showRideJournal = false
    
    private var currentUser: User? { users.first }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.xl) {
                    // Profile Header
                    profileHeader
                    
                    // Statistics
                    statsSection
                    
                    // Menu Sections
                    menuSection
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.sm)
                .padding(.bottom, ConvoyTheme.Spacing.huge)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                }
            }
            .sheet(isPresented: $showGarage) {
                GarageView()
            }
            .sheet(isPresented: $showEmergencyContacts) {
                EmergencyContactsView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(appState)
            }
            .sheet(isPresented: $showRideJournal) {
                RideJournalView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            ConvoyAvatar(
                name: currentUser?.name ?? "Rider",
                size: ConvoyTheme.AvatarSize.profile
            )
            
            VStack(spacing: ConvoyTheme.Spacing.xxs) {
                Text(currentUser?.name ?? "Rider")
                    .font(.convoyTitle2)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                
                Text("@\(currentUser?.username ?? "rider")")
                    .font(.convoySubheadline)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                
                if let experience = currentUser?.ridingExperience {
                    ConvoyStatusBadge(experience.label, color: .convoyAccentFallback, icon: "figure.outdoor.cycle")
                        .padding(.top, 4)
                }
            }
            
            if let bio = currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.convoyFootnote)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .convoyAppearAnimation()
    }
    
    // MARK: - Statistics
    
    private var statsSection: some View {
        ConvoyCard {
            HStack {
                ConvoyStat(
                    "\(currentUser?.totalRides ?? 0)",
                    label: "Rides",
                    icon: "road.lanes"
                )
                .frame(maxWidth: .infinity)
                
                divider
                
                ConvoyStat(
                    (currentUser?.totalDistanceKm ?? 0).formattedDistance(),
                    label: "Distance",
                    icon: "point.topleft.down.to.point.bottomright.curvepath.fill"
                )
                .frame(maxWidth: .infinity)
                
                divider
                
                ConvoyStat(
                    (currentUser?.totalRidingTimeDuration ?? 0).convoyDuration,
                    label: "Riding",
                    icon: "clock"
                )
                .frame(maxWidth: .infinity)
            }
        }
        .convoyAppearAnimation(delay: 0.05)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.convoyTextTertiaryFallback.opacity(0.3))
            .frame(width: 0.5, height: 44)
    }
    
    // MARK: - Menu
    
    private var menuSection: some View {
        VStack(spacing: ConvoyTheme.Spacing.xs) {
            // Garage
            ProfileMenuItem(icon: "bicycle", title: "My Garage", subtitle: garageSubtitle) {
                showGarage = true
            }
            
            // Emergency contacts
            ProfileMenuItem(icon: "staroflife.fill", title: "Emergency Contacts", subtitle: emergencySubtitle) {
                showEmergencyContacts = true
            }
            
            // Safety Center
            ProfileMenuItem(icon: "shield.checkered", title: "Safety Center") {
                appState.isShowingSafetyCenter = true
            }
            
            // Ride Journal & Memories
            ProfileMenuItem(icon: "book.fill", title: "Ride Journal & Memories", subtitle: "Relive completed rides") {
                showRideJournal = true
            }
            
            Divider().padding(.vertical, 4)
            
            // Preferences
            ProfileMenuItem(icon: "bell.fill", title: "Notifications") {}
            ProfileMenuItem(icon: "lock.fill", title: "Privacy") {}
            ProfileMenuItem(icon: "ruler.fill", title: "Units", subtitle: currentUser?.unitPreference.label ?? "Kilometers") {}
            ProfileMenuItem(icon: "paintbrush.fill", title: "Appearance") {}
            
            Divider().padding(.vertical, 4)
            
            // Sign out
            ProfileMenuItem(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true) {
                appState.signOut()
            }
        }
        .convoyAppearAnimation(delay: 0.1)
    }
    
    private var garageSubtitle: String {
        let count = currentUser?.motorcycles.count ?? 0
        return count == 0 ? "Add your bikes" : "\(count) motorcycle\(count == 1 ? "" : "s")"
    }
    
    private var emergencySubtitle: String {
        let count = currentUser?.emergencyContacts.count ?? 0
        return count == 0 ? "Add contacts" : "\(count) contact\(count == 1 ? "" : "s")"
    }
}

// MARK: - Profile Menu Item

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: ConvoyTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isDestructive ? Color.convoySafetyFallback : Color.convoyAccentFallback)
                    .frame(width: 32, height: 32)
                    .background(
                        (isDestructive ? Color.convoySafetyFallback : Color.convoyAccentFallback)
                            .opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.xs, style: .continuous))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.convoyBody)
                        .foregroundStyle(isDestructive ? Color.convoySafetyFallback : Color.convoyTextPrimaryFallback)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextTertiaryFallback)
                    }
                }
                
                Spacer()
                
                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.convoyTextTertiaryFallback)
                }
            }
            .padding(.vertical, ConvoyTheme.Spacing.xs)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Garage View

struct GarageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var showAddMotorcycle = false
    
    private var motorcycles: [Motorcycle] { users.first?.motorcycles ?? [] }
    
    var body: some View {
        NavigationStack {
            Group {
                if motorcycles.isEmpty {
                    emptyState
                } else {
                    motorcycleList
                }
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("My Garage")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddMotorcycle = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.convoyAccentFallback)
                    }
                }
            }
            .sheet(isPresented: $showAddMotorcycle) {
                AddMotorcycleView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: ConvoyTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "bicycle")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.convoyTextTertiaryFallback)
            
            Text("Your garage is empty")
                .font(.convoyTitle3)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text("Add your motorcycles to personalize your profile.")
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .multilineTextAlignment(.center)
            
            ConvoySecondaryButton("Add Motorcycle", icon: "plus") {
                showAddMotorcycle = true
            }
            .frame(width: 200)
            
            Spacer()
        }
        .padding()
    }
    
    private var motorcycleList: some View {
        ScrollView {
            VStack(spacing: ConvoyTheme.Spacing.sm) {
                ForEach(motorcycles) { motorcycle in
                    MotorcycleCard(motorcycle: motorcycle)
                }
            }
            .padding()
        }
    }
}

// MARK: - Motorcycle Card

struct MotorcycleCard: View {
    let motorcycle: Motorcycle
    
    var body: some View {
        ConvoyCard {
            HStack(spacing: ConvoyTheme.Spacing.md) {
                // Motorcycle icon
                Image(systemName: "bicycle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.convoyAccentFallback)
                    .frame(width: 52, height: 52)
                    .background(Color.convoyAccentFallback.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(motorcycle.displayName)
                            .font(.convoyHeadline)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        
                        if motorcycle.isPrimary {
                            ConvoyStatusBadge("Primary", color: .convoyAccentFallback)
                        }
                    }
                    
                    Text(motorcycle.subtitle)
                        .font(.convoyFootnote)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.convoyTextTertiaryFallback)
            }
        }
    }
}

// MARK: - Add Motorcycle View

struct AddMotorcycleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var manufacturer = ""
    @State private var model = ""
    @State private var name = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var isPrimary = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Motorcycle") {
                    TextField("Manufacturer", text: $manufacturer)
                    TextField("Model", text: $model)
                    TextField("Nickname (optional)", text: $name)
                    Picker("Year", selection: $year) {
                        ForEach((1970...Calendar.current.component(.year, from: Date()) + 1).reversed(), id: \.self) { yr in
                            Text(String(yr)).tag(yr)
                        }
                    }
                }
                
                Section {
                    Toggle("Primary Motorcycle", isOn: $isPrimary)
                }
            }
            .navigationTitle("Add Motorcycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { saveMotorcycle() }
                        .font(.convoyHeadline)
                        .foregroundStyle(Color.convoyAccentFallback)
                        .disabled(manufacturer.isEmpty || model.isEmpty)
                }
            }
        }
    }
    
    private func saveMotorcycle() {
        let motorcycle = Motorcycle(
            name: name,
            manufacturer: manufacturer,
            model: model,
            year: year,
            isPrimary: isPrimary
        )
        
        users.first?.motorcycles.append(motorcycle)
        try? modelContext.save()
        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Emergency Contacts View

struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var showAddContact = false
    
    private var contacts: [EmergencyContact] { users.first?.emergencyContacts ?? [] }
    
    var body: some View {
        NavigationStack {
            Group {
                if contacts.isEmpty {
                    VStack(spacing: ConvoyTheme.Spacing.lg) {
                        Spacer()
                        Image(systemName: "staroflife.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(Color.convoyWarningFallback)
                        Text("No emergency contacts")
                            .font(.convoyTitle3)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        Text("Add contacts who should be notified in an emergency.")
                            .font(.convoySubheadline)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                            .multilineTextAlignment(.center)
                        ConvoySecondaryButton("Add Contact", icon: "plus") {
                            showAddContact = true
                        }
                        .frame(width: 200)
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(contacts) { contact in
                            HStack(spacing: ConvoyTheme.Spacing.md) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(Color.convoyWarningFallback)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.name)
                                        .font(.convoyHeadline)
                                    Text(contact.phoneNumber)
                                        .font(.convoyFootnote)
                                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                                    if !contact.relationship.isEmpty {
                                        Text(contact.relationship)
                                            .font(.convoyCaption)
                                            .foregroundStyle(Color.convoyTextTertiaryFallback)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Emergency Contacts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddContact = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.convoyAccentFallback)
                    }
                }
            }
            .sheet(isPresented: $showAddContact) {
                AddEmergencyContactView()
            }
        }
    }
}

// MARK: - Add Emergency Contact

struct AddEmergencyContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var name = ""
    @State private var phone = ""
    @State private var relationship = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Relationship (optional)", text: $relationship)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { saveContact() }
                        .font(.convoyHeadline)
                        .foregroundStyle(Color.convoyAccentFallback)
                        .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
    
    private func saveContact() {
        let contact = EmergencyContact(name: name, phoneNumber: phone, relationship: relationship)
        users.first?.emergencyContacts.append(contact)
        try? modelContext.save()
        HapticManager.shared.notification(.success)
        dismiss()
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    settingsRow(icon: "person.fill", title: "Edit Profile")
                    settingsRow(icon: "bell.fill", title: "Notifications")
                    settingsRow(icon: "lock.fill", title: "Privacy")
                }
                
                Section("Riding") {
                    settingsRow(icon: "ruler.fill", title: "Units")
                    settingsRow(icon: "map.fill", title: "Offline Maps")
                    settingsRow(icon: "location.fill", title: "Location Settings")
                }
                
                Section("Appearance") {
                    settingsRow(icon: "paintbrush.fill", title: "Theme")
                    settingsRow(icon: "textformat.size", title: "Text Size")
                }
                
                Section("Safety") {
                    settingsRow(icon: "staroflife.fill", title: "Emergency Contacts")
                    settingsRow(icon: "shield.checkered", title: "Crash Detection")
                    settingsRow(icon: "location.fill", title: "Safety Tracking")
                }
                
                Section("Developer") {
                    settingsRow(icon: "wrench.fill", title: "Demo Mode")
                    settingsRow(icon: "ant.fill", title: "Simulation Controls")
                }
                
                Section {
                    Button(action: {
                        appState.signOut()
                        dismiss()
                    }) {
                        Text("Sign Out")
                            .foregroundStyle(Color.convoySafetyFallback)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
    }
    
    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: ConvoyTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.convoyAccentFallback)
                .frame(width: 28, height: 28)
                .background(Color.convoyAccentFallback.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            
            Text(title)
                .font(.convoyBody)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
        .modelContainer(for: [User.self, Ride.self])
        .preferredColorScheme(.dark)
}
