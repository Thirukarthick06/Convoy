import SwiftUI
import SwiftData
import MapKit

// MARK: - Ride Detail View

struct RideDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let ride: Ride
    
    @State private var showShareSheet = false
    @State private var showLobbySheet = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private var isRideLeader: Bool {
        guard let current = appState.currentUser else { return false }
        return ride.leaderRiderId == current.id || ride.organizerId == current.id
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: ConvoyTheme.Spacing.xl) {
                
                // Route Map Header
                mapHeader
                
                // Ride Title & Status
                titleSection
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Key Metrics Grid
                metricsGrid
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Riding Config (Formation, Pace, Style)
                rideConfigSection
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Convoy Roster & Roles
                rosterSection
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Waypoints Timeline
                waypointsSection
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Safety & Briefing Notes
                briefingSection
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Primary Action Button
                actionButtonSection
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                Spacer(minLength: ConvoyTheme.Spacing.huge)
            }
            .padding(.top, ConvoyTheme.Spacing.sm)
        }
        .background(Color.convoyBackgroundFallback)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.shared.lightImpact()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareRideSheet(ride: ride)
        }
    }
    
    // MARK: - Map Header
    
    private var mapHeader: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude),
                span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
            ))) {
                // Start Marker
                Marker(ride.startLocationName, coordinate: CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude))
                    .tint(Color.convoyAccentFallback)
                
                // End Marker
                Marker(ride.endLocationName, coordinate: CLLocationCoordinate2D(latitude: ride.endLatitude, longitude: ride.endLongitude))
                    .tint(Color.convoySuccessFallback)
                
                // Waypoint Markers
                ForEach(ride.waypoints) { wp in
                    Marker(wp.name, coordinate: CLLocationCoordinate2D(latitude: wp.latitude, longitude: wp.longitude))
                        .tint(Color.convoyWarningFallback)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg))
            .padding(.horizontal, ConvoyTheme.Spacing.lg)
            
            // Map controls overlay
            HStack(spacing: 8) {
                Label("\(ride.waypoints.count) Stops", systemImage: "mappin.and.ellipse")
                    .font(.convoyCaptionBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(ConvoyTheme.Spacing.xl)
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.xs) {
            HStack {
                ConvoyStatusBadge(status: ride.status)
                Spacer()
                Text(ride.scheduledDate.convoyFullDate)
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            
            Text(ride.title)
                .font(.convoyTitle2)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            if !ride.rideDescription.isEmpty {
                Text(ride.rideDescription)
                    .font(.convoyBody)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                    .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: ConvoyTheme.Spacing.sm) {
            ConvoyStat(
                title: "Distance",
                value: ride.distanceKm.formattedDistance(),
                icon: "arrow.triangle.swap"
            )
            ConvoyStat(
                title: "Est. Time",
                value: ride.estimatedDurationSeconds.formattedDuration(),
                icon: "clock"
            )
            ConvoyStat(
                title: "Riders",
                value: "\(ride.participants.count)",
                icon: "person.2.fill"
            )
        }
    }
    
    // MARK: - Riding Config
    
    private var rideConfigSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "RIDE PARAMETERS")
            
            HStack(spacing: ConvoyTheme.Spacing.md) {
                configPill(title: "Style", value: ride.ridingStyle.label, icon: "gauge.with.dots.needle.50percent")
                configPill(title: "Formation", value: ride.formation.label, icon: "arrow.triangle.pull")
                configPill(title: "Pace", value: ride.pace.label, icon: "speedometer")
            }
        }
    }
    
    private func configPill(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.convoyAccentFallback)
                Text(title)
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            Text(value)
                .font(.convoySubheadlineBold)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ConvoyTheme.Spacing.sm)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm)
                .stroke(Color.convoyBorderFallback, lineWidth: 1)
        )
    }
    
    // MARK: - Convoy Roster & Roles
    
    private var rosterSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            HStack {
                ConvoySectionHeader(title: "CONVOY ROSTER (\(ride.participants.count))")
                Spacer()
                Text("Formation Order")
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyAccentFallback)
            }
            
            VStack(spacing: ConvoyTheme.Spacing.xs) {
                ForEach(ride.participants.sorted(by: { $0.formationPosition < $1.formationPosition })) { participant in
                    rosterRow(participant: participant)
                }
            }
        }
    }
    
    private func rosterRow(participant: RideParticipant) -> some View {
        HStack(spacing: ConvoyTheme.Spacing.md) {
            // Position Badge
            ZStack {
                Circle()
                    .fill(Color.convoySurfaceElevatedFallback)
                    .frame(width: 32, height: 32)
                Text("\(participant.formationPosition)")
                    .font(.convoyCaptionBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(participant.riderName)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    if participant.role == .lead {
                        ConvoyPill(text: "LEAD", color: Color.convoyAccentFallback)
                    } else if participant.role == .sweep {
                        ConvoyPill(text: "SWEEP", color: Color.convoyWarningFallback)
                    }
                }
                
                if let bike = participant.motorcycleModel {
                    Text(bike)
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
            }
            
            Spacer()
            
            // Status Indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(participant.status == .ready || participant.status == .moving ? Color.convoySuccessFallback : Color.convoyWarningFallback)
                    .frame(width: 8, height: 8)
                Text(participant.status.label)
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
        }
        .padding(ConvoyTheme.Spacing.sm)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm)
                .stroke(Color.convoyBorderFallback, lineWidth: 1)
        )
    }
    
    // MARK: - Waypoints Section
    
    private var waypointsSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "ROUTE ITINERARY")
            
            VStack(spacing: 0) {
                // Start
                itineraryItem(
                    index: 0,
                    title: ride.startLocationName,
                    subtitle: "Meeting & Rollout Point • \(ride.scheduledDate.convoyTime)",
                    type: .start,
                    isLast: ride.waypoints.isEmpty && ride.endLocationName.isEmpty
                )
                
                // Waypoints
                ForEach(Array(ride.waypoints.enumerated()), id: \.element.id) { index, wp in
                    itineraryItem(
                        index: index + 1,
                        title: wp.name,
                        subtitle: wp.waypointType.label + (wp.notes.isEmpty ? "" : " • \(wp.notes)"),
                        type: .stop,
                        isLast: index == ride.waypoints.count - 1 && ride.endLocationName.isEmpty
                    )
                }
                
                // End
                itineraryItem(
                    index: ride.waypoints.count + 1,
                    title: ride.endLocationName,
                    subtitle: "Final Destination",
                    type: .destination,
                    isLast: true
                )
            }
            .padding(ConvoyTheme.Spacing.md)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                    .stroke(Color.convoyBorderFallback, lineWidth: 1)
            )
        }
    }
    
    enum ItineraryType {
        case start, stop, destination
    }
    
    private func itineraryItem(index: Int, title: String, subtitle: String, type: ItineraryType, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: ConvoyTheme.Spacing.md) {
            VStack(spacing: 0) {
                Circle()
                    .fill(type == .start ? Color.convoyAccentFallback : (type == .destination ? Color.convoySuccessFallback : Color.convoyWarningFallback))
                    .frame(width: 14, height: 14)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.convoyBorderFallback)
                        .frame(width: 2, height: 36)
                }
            }
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.convoyCalloutBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                Text(subtitle)
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Briefing Section
    
    private var briefingSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "SAFETY & CONVOY PROTOCOLS")
            
            VStack(alignment: .leading, spacing: 8) {
                protocolRow(icon: "shield.checkered", text: "Maintain 2-second staggered spacing on open roads.")
                protocolRow(icon: "arrow.left.arrow.right", text: "Switch to single file through ghat sections and sharp twisties.")
                protocolRow(icon: "fuelpump.fill", text: "Arrive at meeting point with a full fuel tank.")
                protocolRow(icon: "cross.case.fill", text: "Sweep rider carries first aid & tire inflator kit.")
            }
            .padding(ConvoyTheme.Spacing.md)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                    .stroke(Color.convoyBorderFallback, lineWidth: 1)
            )
        }
    }
    
    private func protocolRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: ConvoyTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.convoyAccentFallback)
                .frame(width: 18)
            Text(text)
                .font(.convoyCaption)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonSection: some View {
        VStack(spacing: ConvoyTheme.Spacing.sm) {
            if ride.status == .planned {
                ConvoyButton("Enter Ride Lobby", icon: "person.3.fill") {
                    appState.enterLobby(ride)
                    appState.startRide(ride)
                }
            } else if ride.status == .lobby || ride.status == .starting {
                ConvoyButton("Start Live Convoy", icon: "flag.checkered") {
                    appState.startRide(ride)
                }
            } else if ride.status == .active {
                ConvoyButton("Resume Live Convoy", icon: "location.fill") {
                    appState.isShowingLiveRide = true
                }
            } else if ride.status == .completed {
                ConvoyButton("View Ride Memory", icon: "book.fill", style: .secondary) {
                    // Navigate to journal
                }
            }
        }
        .padding(.top, ConvoyTheme.Spacing.md)
    }
}

// MARK: - Share Ride Sheet

struct ShareRideSheet: View {
    @Environment(\.dismiss) private var dismiss
    let ride: Ride
    
    var body: some View {
        NavigationStack {
            VStack(spacing: ConvoyTheme.Spacing.xl) {
                Image(systemName: "qrcode")
                    .font(.system(size: 120))
                    .foregroundStyle(Color.convoyAccentFallback)
                    .padding(.top, ConvoyTheme.Spacing.xl)
                
                VStack(spacing: 8) {
                    Text(ride.title)
                        .font(.convoyTitle3)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    Text("Convoy Join Code: \(String(ride.id.uuidString.prefix(6)).uppercased())")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundStyle(Color.convoyAccentFallback)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.convoySurfaceFallback)
                        .clipShape(Capsule())
                }
                
                Text("Share this code or QR with your riding group to sync formation and live route tracking.")
                    .font(.convoyBody)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ConvoyTheme.Spacing.xl)
                
                Spacer()
                
                ConvoyButton("Copy Invite Link", icon: "link") {
                    HapticManager.shared.success()
                    dismiss()
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.bottom, ConvoyTheme.Spacing.lg)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Invite Riders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
