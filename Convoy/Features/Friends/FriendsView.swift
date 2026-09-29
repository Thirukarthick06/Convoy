import SwiftUI
import SwiftData

// MARK: - Friends View

struct FriendsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @Query private var friends: [Friend]
    
    @State private var searchText = ""
    @State private var showAddFriend = false
    @State private var showQRShare = false
    
    private var filteredFriends: [Friend] {
        friends.filter { friend in
            if searchText.isEmpty { return true }
            return friend.name.lowercased().contains(searchText.lowercased()) ||
                   friend.username.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.lg) {
                    
                    // Live Status Banner
                    liveStatusBanner
                    
                    // Search Field
                    ConvoySearchField(
                        placeholder: "Search riders by name, handle, or motorcycle",
                        text: $searchText
                    )
                    
                    // Friends List
                    if filteredFriends.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: ConvoyTheme.Spacing.md) {
                            ForEach(filteredFriends) { friend in
                                friendCard(for: friend)
                            }
                        }
                    }
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.sm)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Riders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            HapticManager.shared.lightImpact()
                            showQRShare = true
                        } label: {
                            Image(systemName: "qrcode")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.convoyAccentFallback)
                        }
                        
                        Button {
                            HapticManager.shared.lightImpact()
                            showAddFriend = true
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.convoyAccentFallback)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddFriend) {
                AddFriendSheet()
            }
            .sheet(isPresented: $showQRShare) {
                RiderQRSheet()
            }
        }
    }
    
    // MARK: - Live Status Banner
    
    private var liveStatusBanner: some View {
        HStack(spacing: ConvoyTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.convoySuccessFallback.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Circle()
                    .fill(Color.convoySuccessFallback)
                    .frame(width: 10, height: 10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("2 RIDERS ON THE ROAD")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.convoySuccessFallback)
                
                Text("Arun K. & Vikram S. are cruising on NH48")
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
        .padding(ConvoyTheme.Spacing.md)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                .stroke(Color.convoySuccessFallback.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Friend Card
    
    private func friendCard(for friend: Friend) -> some View {
        HStack(spacing: ConvoyTheme.Spacing.md) {
            // Avatar
            Circle()
                .fill(Color.convoySurfaceElevatedFallback)
                .frame(width: 48, height: 48)
                .overlay {
                    Text(String(friend.name.prefix(1)))
                        .font(.convoyHeadline)
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(friend.name)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    if friend.isEmergencyContact {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.convoySafetyFallback)
                    }
                }
                
                if let bike = friend.motorcycle {
                    HStack(spacing: 4) {
                        Image(systemName: "bicycle")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                        Text(bike)
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                }
            }
            
            Spacer()
            
            // Invite to Ride Button
            Button {
                HapticManager.shared.lightImpact()
            } label: {
                Text("Invite")
                    .font(.convoyCaptionBold)
                    .foregroundStyle(Color.convoyAccentFallback)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.convoyAccentFallback.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(ConvoyTheme.Spacing.md)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                .stroke(Color.convoyBorderFallback, lineWidth: 1)
        )
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 44))
                .foregroundStyle(Color.convoyTextSecondaryFallback.opacity(0.5))
                .padding(.top, ConvoyTheme.Spacing.xl)
            
            Text("No Riders Found")
                .font(.convoyHeadline)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text("Connect with fellow motorcycle riders in your area.")
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
            
            ConvoyButton("Add Rider", icon: "person.badge.plus") {
                showAddFriend = true
            }
            .padding(.top, ConvoyTheme.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ConvoyTheme.Spacing.xl)
    }
}

// MARK: - Add Friend Sheet

struct AddFriendSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var riderName = ""
    @State private var username = ""
    @State private var bikeModel = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rider Details") {
                    TextField("Full Name", text: $riderName)
                    TextField("Convoy Username (@handle)", text: $username)
                    TextField("Motorcycle Model", text: $bikeModel)
                }
            }
            .navigationTitle("Add Rider")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !riderName.isEmpty else { return }
                        let newFriend = Friend(
                            name: riderName,
                            username: username.isEmpty ? riderName.lowercased().replacingOccurrences(of: " ", with: ".") : username,
                            motorcycle: bikeModel.isEmpty ? nil : bikeModel
                        )
                        modelContext.insert(newFriend)
                        try? modelContext.save()
                        HapticManager.shared.success()
                        dismiss()
                    }
                    .disabled(riderName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Rider QR Sheet

struct RiderQRSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: ConvoyTheme.Spacing.xl) {
                Image(systemName: "qrcode")
                    .font(.system(size: 140))
                    .foregroundStyle(Color.convoyAccentFallback)
                    .padding(.top, ConvoyTheme.Spacing.xl)
                
                VStack(spacing: 4) {
                    Text(appState.currentUser?.name ?? "Rider")
                        .font(.convoyTitle2)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    Text("@\(appState.currentUser?.username ?? "convoy.rider")")
                        .font(.convoySubheadline)
                        .foregroundStyle(Color.convoyAccentFallback)
                }
                
                Text("Let nearby riders scan this QR code to instantly add you to their Convoy pack and safety circle.")
                    .font(.convoyBody)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ConvoyTheme.Spacing.xl)
                
                Spacer()
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Rider Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
