import SwiftUI
import SwiftData
import MapKit

// MARK: - Rides View

struct RidesView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Ride.scheduledDate) private var allRides: [Ride]
    
    @State private var selectedFilter: RideFilter = .upcoming
    @State private var searchText = ""
    @State private var selectedRide: Ride?
    @State private var showPlanRide = false
    
    enum RideFilter: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
        case past = "Past"
        case all = "All"
        
        var id: String { rawValue }
    }
    
    private var filteredRides: [Ride] {
        allRides.filter { ride in
            // Filter by status
            let matchesFilter: Bool
            switch selectedFilter {
            case .upcoming:
                matchesFilter = ride.status == .planned || ride.status == .lobby || ride.status == .starting
            case .past:
                matchesFilter = ride.status == .completed || ride.status == .cancelled
            case .all:
                matchesFilter = true
            }
            
            // Search text
            if searchText.isEmpty {
                return matchesFilter
            } else {
                let query = searchText.lowercased()
                return matchesFilter && (
                    ride.title.lowercased().contains(query) ||
                    ride.startLocationName.lowercased().contains(query) ||
                    ride.endLocationName.lowercased().contains(query)
                )
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.lg) {
                    
                    // Search Bar
                    ConvoySearchField(
                        placeholder: "Search rides, routes, or destinations",
                        text: $searchText
                    )
                    
                    // Filter Segmented Control
                    filterSegment
                    
                    // Rides List
                    if filteredRides.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: ConvoyTheme.Spacing.md) {
                            ForEach(filteredRides) { ride in
                                NavigationLink(destination: RideDetailView(ride: ride)) {
                                    rideCard(for: ride)
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
            .navigationTitle("Rides")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.lightImpact()
                        showPlanRide = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Plan")
                                .font(.convoyCalloutBold)
                        }
                        .foregroundStyle(Color.convoyAccentFallback)
                    }
                }
            }
            .sheet(isPresented: $showPlanRide) {
                PlanRideView()
            }
        }
    }
    
    // MARK: - Filter Segment
    
    private var filterSegment: some View {
        HStack(spacing: ConvoyTheme.Spacing.xs) {
            ForEach(RideFilter.allCases) { filter in
                Button {
                    HapticManager.shared.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(
                            selectedFilter == filter
                            ? Color.convoyBackgroundFallback
                            : Color.convoyTextSecondaryFallback
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            selectedFilter == filter
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
    
    // MARK: - Ride Card
    
    private func rideCard(for ride: Ride) -> some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.md) {
            // Header: Date & Status
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.convoyAccentFallback)
                    Text(ride.scheduledDate.convoyShortDate)
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    Text("•")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    Text(ride.scheduledDate.convoyTime)
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                
                Spacer()
                
                ConvoyStatusBadge(status: ride.status)
            }
            
            // Title & Style
            VStack(alignment: .leading, spacing: 4) {
                Text(ride.title)
                    .font(.convoyHeadline)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    Text("\(ride.startLocationName) → \(ride.endLocationName)")
                        .font(.convoySubheadline)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                        .lineLimit(1)
                }
            }
            
            // Route Metrics Bar
            HStack(spacing: ConvoyTheme.Spacing.lg) {
                metricItem(icon: "arrow.triangle.swap", title: ride.distanceKm.formattedDistance(), subtitle: "Distance")
                metricItem(icon: "clock", title: ride.estimatedDurationSeconds.formattedDuration(), subtitle: "Est. Time")
                metricItem(icon: "person.2.fill", title: "\(ride.participants.count)", subtitle: "Riders")
                
                Spacer()
                
                // Style Pill
                ConvoyPill(text: ride.ridingStyle.label, color: Color.convoyAccentFallback)
            }
            .padding(.top, 4)
            
            // Roster Avatars Preview
            if !ride.participants.isEmpty {
                HStack(spacing: ConvoyTheme.Spacing.sm) {
                    HStack(spacing: -8) {
                        ForEach(ride.participants.prefix(4)) { participant in
                            Circle()
                                .fill(Color.convoySurfaceElevatedFallback)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Text(String(participant.riderName.prefix(1)))
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.convoyAccentFallback)
                                }
                                .overlay(Circle().stroke(Color.convoySurfaceFallback, lineWidth: 2))
                        }
                    }
                    
                    if ride.participants.count > 4 {
                        Text("+\(ride.participants.count - 4) more")
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.convoyCaptionBold)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color.convoyAccentFallback)
                }
                .padding(.top, 4)
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
    
    private func metricItem(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.convoyAccentFallback)
                Text(title)
                    .font(.convoySubheadlineBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
            }
            Text(subtitle)
                .font(.convoyCaption)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            Image(systemName: "road.lanes")
                .font(.system(size: 44))
                .foregroundStyle(Color.convoyTextSecondaryFallback.opacity(0.5))
                .padding(.top, ConvoyTheme.Spacing.xl)
            
            Text(selectedFilter == .upcoming ? "No Upcoming Rides" : "No Past Rides")
                .font(.convoyHeadline)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text(selectedFilter == .upcoming
                 ? "Plan your next motorcycle adventure or join an existing group."
                 : "Completed rides with your group will appear here.")
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ConvoyTheme.Spacing.xl)
            
            if selectedFilter == .upcoming {
                ConvoyButton("Plan a Ride", icon: "plus") {
                    showPlanRide = true
                }
                .padding(.top, ConvoyTheme.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ConvoyTheme.Spacing.xl)
    }
}
