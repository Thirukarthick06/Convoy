import SwiftUI
import SwiftData

// MARK: - Clubs View

struct ClubsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allClubs: [Club]
    
    @State private var searchText = ""
    @State private var selectedSegment: ClubSegment = .myClubs
    @State private var showCreateClub = false
    
    enum ClubSegment: String, CaseIterable, Identifiable {
        case myClubs = "My Clubs"
        case explore = "Discover"
        
        var id: String { rawValue }
    }
    
    private var filteredClubs: [Club] {
        allClubs.filter { club in
            if !searchText.isEmpty {
                return club.name.lowercased().contains(searchText.lowercased()) ||
                       club.city.lowercased().contains(searchText.lowercased())
            }
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.lg) {
                    
                    // Search Field
                    ConvoySearchField(
                        placeholder: "Search clubs by name, city, or motorcycle style",
                        text: $searchText
                    )
                    
                    // Segment
                    segmentControl
                    
                    // Clubs List
                    if filteredClubs.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: ConvoyTheme.Spacing.md) {
                            ForEach(filteredClubs) { club in
                                NavigationLink(destination: ClubDetailView(club: club)) {
                                    clubCard(for: club)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.sm)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Clubs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.lightImpact()
                        showCreateClub = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.convoyAccentFallback)
                    }
                }
            }
            .sheet(isPresented: $showCreateClub) {
                CreateClubSheet()
            }
        }
    }
    
    // MARK: - Segment Control
    
    private var segmentControl: some View {
        HStack(spacing: ConvoyTheme.Spacing.xs) {
            ForEach(ClubSegment.allCases) { segment in
                Button {
                    HapticManager.shared.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = segment
                    }
                } label: {
                    Text(segment.rawValue)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(
                            selectedSegment == segment
                            ? Color.convoyBackgroundFallback
                            : Color.convoyTextSecondaryFallback
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(
                            selectedSegment == segment
                            ? Color.convoyAccentFallback
                            : Color.convoySurfaceFallback
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
    
    // MARK: - Club Card
    
    private func clubCard(for club: Club) -> some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.md) {
            // Header: Name & City
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                        .fill(Color.convoySurfaceElevatedFallback)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "shield.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.convoyAccentFallback)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(club.name)
                        .font(.convoyHeadline)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                        Text(club.city)
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                        
                        Text("•")
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                        
                        Text("\(club.memberCount) members")
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            
            // Description
            Text(club.clubDescription)
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .lineLimit(2)
            
            // Stats Row
            HStack(spacing: ConvoyTheme.Spacing.xl) {
                HStack(spacing: 4) {
                    Image(systemName: "road.lanes")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.convoyAccentFallback)
                    Text("\(club.totalRides) Rides")
                        .font(.convoyCaptionBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "gauge.with.dots.needle.50percent")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.convoyAccentFallback)
                    Text(club.totalDistanceKm.formattedDistance())
                        .font(.convoyCaptionBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
                
                Spacer()
                
                ConvoyPill(text: club.isVerified ? "VERIFIED" : "COMMUNITY", color: club.isVerified ? Color.convoySuccessFallback : Color.convoyTextSecondaryFallback)
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
            Image(systemName: "shield.slash")
                .font(.system(size: 44))
                .foregroundStyle(Color.convoyTextSecondaryFallback.opacity(0.5))
                .padding(.top, ConvoyTheme.Spacing.xl)
            
            Text("No Clubs Found")
                .font(.convoyHeadline)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text("Discover regional motorcycle clubs or start your own chapter.")
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .multilineTextAlignment(.center)
            
            ConvoyButton("Create Club", icon: "plus") {
                showCreateClub = true
            }
            .padding(.top, ConvoyTheme.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ConvoyTheme.Spacing.xl)
    }
}

// MARK: - Club Detail View

struct ClubDetailView: View {
    let club: Club
    
    @State private var isMember: Bool = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: ConvoyTheme.Spacing.xl) {
                
                // Hero Banner
                VStack(spacing: ConvoyTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.convoySurfaceElevatedFallback)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "shield.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(Color.convoyAccentFallback)
                    }
                    
                    VStack(spacing: 4) {
                        Text(club.name)
                            .font(.convoyTitle2)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        
                        Text("\(club.city) • Established \(Calendar.current.component(.year, from: club.createdAt))")
                            .font(.convoySubheadline)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                    
                    // Join / Leave Button
                    Button {
                        withAnimation {
                            isMember.toggle()
                        }
                        HapticManager.shared.lightImpact()
                    } label: {
                        Text(isMember ? "Joined ✓" : "Join Club")
                            .font(.convoyCalloutBold)
                            .foregroundStyle(isMember ? Color.convoyTextPrimaryFallback : Color.convoyBackgroundFallback)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(isMember ? Color.convoySurfaceElevatedFallback : Color.convoyAccentFallback)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ConvoyTheme.Spacing.lg)
                
                // Key Metrics
                HStack(spacing: ConvoyTheme.Spacing.md) {
                    ConvoyStat(title: "Members", value: "\(club.memberCount)", icon: "person.3.fill")
                    ConvoyStat(title: "Rides Held", value: "\(club.totalRides)", icon: "road.lanes")
                    ConvoyStat(title: "Total Km", value: club.totalDistanceKm.formattedDistance(), icon: "gauge.with.dots.needle.50percent")
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // About Section
                VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.xs) {
                    ConvoySectionHeader(title: "ABOUT THE CLUB")
                    Text(club.clubDescription)
                        .font(.convoyBody)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Road Captains & Rules
                VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
                    ConvoySectionHeader(title: "CLUB ETIQUETTE & SAFETY")
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color.convoyAccentFallback)
                            Text("Full riding gear mandatory (ECE/DOT helmet, armored jacket, riding boots).")
                                .font(.convoyCaption)
                                .foregroundStyle(Color.convoyTextSecondaryFallback)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "person.line.dotted.person.fill")
                                .foregroundStyle(Color.convoyAccentFallback)
                            Text("Strict adherence to Lead and Sweep instructions; zero overtaking within the pack.")
                                .font(.convoyCaption)
                                .foregroundStyle(Color.convoyTextSecondaryFallback)
                        }
                    }
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                Spacer(minLength: ConvoyTheme.Spacing.huge)
            }
        }
        .background(Color.convoyBackgroundFallback)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Create Club Sheet

struct CreateClubSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @State private var clubName = ""
    @State private var city = ""
    @State private var description = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Club Information") {
                    TextField("Club Name (e.g. Royal Riders Chennai)", text: $clubName)
                    TextField("City / Region", text: $city)
                    TextField("Description & Motto", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Start a Riding Club")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        guard !clubName.isEmpty else { return }
                        let newClub = Club(
                            name: clubName,
                            clubDescription: description,
                            city: city,
                            memberCount: 1,
                            totalRides: 0,
                            totalDistanceKm: 0,
                            isVerified: false
                        )
                        modelContext.insert(newClub)
                        try? modelContext.save()
                        HapticManager.shared.success()
                        dismiss()
                    }
                    .disabled(clubName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
