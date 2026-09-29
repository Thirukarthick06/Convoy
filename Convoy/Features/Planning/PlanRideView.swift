import SwiftUI
import SwiftData
import MapKit

// MARK: - Plan Ride View

struct PlanRideView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var clubs: [Club]
    @Query private var friends: [Friend]
    
    // Form State
    @State private var rideTitle: String = ""
    @State private var rideDescription: String = ""
    @State private var scheduledDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
    @State private var startLocation: String = "Bangalore (MG Road)"
    @State private var endLocation: String = "Coorg (Madikeri)"
    @State private var distanceKm: Double = 248.0
    @State private var estimatedHours: Double = 5.5
    
    // Riding Parameters
    @State private var ridingStyle: RidingStyle = .curvaceous
    @State private var formation: Formation = .staggered
    @State private var pace: Pace = .moderate
    @State private var selectedClub: Club?
    
    // Waypoints
    @State private var waypoints: [NewWaypoint] = [
        NewWaypoint(name: "Channapatna Breakfast Stop", type: .food),
        NewWaypoint(name: "Kushalnagar Fuel Refill", type: .fuel)
    ]
    @State private var newWaypointName: String = ""
    
    // AI Route Generator
    @State private var isGeneratingAIRoute: Bool = false
    @State private var curvinessLevel: Double = 0.8
    @State private var avoidHighways: Bool = true
    @State private var aiOptimizationApplied: Bool = false
    @State private var showAIPlanner: Bool = false
    @State private var showRoutePlanner: Bool = false
    
    struct NewWaypoint: Identifiable {
        let id = UUID()
        var name: String
        var type: WaypointType
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.xl) {
                    
                    // Route Overview Card
                    routePreviewCard
                    
                    // AI Route Generator Banner
                    aiRouteOptimizerCard
                    
                    // Section 1: Ride Details
                    detailsSection
                    
                    // Section 2: Itinerary & Waypoints
                    waypointsSection
                    
                    // Section 3: Formation & Riding Style
                    parametersSection
                    
                    // Section 4: Club / Group Assignment
                    clubSection
                    
                    // Create Button
                    ConvoyButton("Publish Ride", icon: "flag.checkered") {
                        saveRide()
                    }
                    .disabled(rideTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(rideTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                    .padding(.top, ConvoyTheme.Spacing.md)
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.sm)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Plan New Ride")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
            }
            .sheet(isPresented: $showAIPlanner) {
                AIPlannerView { rec in
                    self.rideTitle = rec.title
                    self.rideDescription = rec.description
                    self.distanceKm = rec.distanceKm
                    self.estimatedHours = rec.estimatedDurationHours
                    self.aiOptimizationApplied = true
                }
            }
            .sheet(isPresented: $showRoutePlanner) {
                RoutePlannerView(startLocation: startLocation, destination: endLocation)
            }
        }
    }
    
    // MARK: - Route Preview Card
    
    private var routePreviewCard: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("START POINT")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    TextField("Start location", text: $startLocation)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.convoyAccentFallback)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("DESTINATION")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    TextField("Destination", text: $endLocation)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Divider()
                .background(Color.convoyBorderFallback)
            
            HStack {
                Label(String(format: "%.0f km", distanceKm), systemImage: "arrow.triangle.swap")
                    .font(.convoySubheadlineBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                
                Spacer()
                
                Label(String(format: "%.1f hrs", estimatedHours), systemImage: "clock")
                    .font(.convoySubheadlineBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                
                Spacer()
                
                Label("\(waypoints.count) stops", systemImage: "mappin")
                    .font(.convoySubheadlineBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
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
    
    // MARK: - AI Route Optimizer
    
    private var aiRouteOptimizerCard: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.md) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.convoyAccentFallback)
                    Text("Convoy AI Route Engine")
                        .font(.convoyCalloutBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
                
                Spacer()
                
                if aiOptimizationApplied {
                    ConvoyPill(text: "OPTIMIZED", color: Color.convoySuccessFallback)
                }
            }
            
            Text("Automatically weave motorcycle-preferred twisties, scenic elevation passes, and avoid boring commercial highways.")
                .font(.convoyCaption)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
            
            // Curviness Slider
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Twistiness Preference")
                        .font(.convoyCaptionBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    Spacer()
                    Text(curvinessLevel > 0.6 ? "High (Mountain Twisties)" : "Balanced")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyAccentFallback)
                }
                
                Slider(value: $curvinessLevel, in: 0.1...1.0)
                    .tint(Color.convoyAccentFallback)
            }
            
            Toggle("Avoid Heavy Commercial Expressways", isOn: $avoidHighways)
                .font(.convoyCallout)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
                .tint(Color.convoyAccentFallback)
            
            // AI Action Button
            Button {
                simulateAIOptimization()
            } label: {
                HStack {
                    if isGeneratingAIRoute {
                        ProgressView()
                            .tint(Color.convoyBackgroundFallback)
                            .padding(.trailing, 4)
                        Text("Calculating Scenic Twisties...")
                            .font(.convoyCalloutBold)
                            .foregroundStyle(Color.convoyBackgroundFallback)
                    } else {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.convoyBackgroundFallback)
                        Text(aiOptimizationApplied ? "Re-calculate AI Route" : "Generate Scenic Twisties Route")
                            .font(.convoyCalloutBold)
                            .foregroundStyle(Color.convoyBackgroundFallback)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.convoyAccentFallback)
                .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
            }
            .disabled(isGeneratingAIRoute)
        }
        .padding(ConvoyTheme.Spacing.md)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                .stroke(aiOptimizationApplied ? Color.convoySuccessFallback.opacity(0.4) : Color.convoyBorderFallback, lineWidth: 1)
        )
    }
    
    private func simulateAIOptimization() {
        isGeneratingAIRoute = true
        HapticManager.shared.lightImpact()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isGeneratingAIRoute = false
            aiOptimizationApplied = true
            distanceKm = 264.0
            estimatedHours = 6.0
            ridingStyle = .curvaceous
            
            // Add a scenic canyon waypoint
            waypoints.insert(
                NewWaypoint(name: "Bisle Ghat Scenic Overlook", type: .viewpoint),
                at: 1
            )
            HapticManager.shared.success()
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "RIDE DETAILS")
            
            VStack(spacing: ConvoyTheme.Spacing.md) {
                TextField("Ride Title (e.g. Western Ghats Monsoon Ride)", text: $rideTitle)
                    .font(.convoyCallout)
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                
                DatePicker("Scheduled Date & Time", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                    .font(.convoyCallout)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                
                TextField("Notes / Briefing (optional)", text: $rideDescription, axis: .vertical)
                    .lineLimit(3...5)
                    .font(.convoyCallout)
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
            }
        }
    }
    
    // MARK: - Waypoints Section
    
    private var waypointsSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            HStack {
                ConvoySectionHeader(title: "PLANNED STOPS (\(waypoints.count))")
                Spacer()
            }
            
            VStack(spacing: ConvoyTheme.Spacing.xs) {
                ForEach(waypoints) { wp in
                    HStack {
                        Image(systemName: wp.type.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.convoyAccentFallback)
                            .frame(width: 24)
                        
                        Text(wp.name)
                            .font(.convoyCallout)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        
                        Spacer()
                        
                        ConvoyPill(text: wp.type.label, color: Color.convoyTextSecondaryFallback)
                        
                        Button {
                            waypoints.removeAll(where: { $0.id == wp.id })
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.convoyTextSecondaryFallback)
                        }
                    }
                    .padding(ConvoyTheme.Spacing.sm)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                }
                
                // Add Stop Field
                HStack {
                    TextField("Add stop (e.g. Fuel, Chai, Viewpoint)", text: $newWaypointName)
                        .font(.convoyCallout)
                    
                    Button {
                        guard !newWaypointName.isEmpty else { return }
                        waypoints.append(NewWaypoint(name: newWaypointName, type: .stop))
                        newWaypointName = ""
                        HapticManager.shared.lightImpact()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.convoyAccentFallback)
                    }
                }
                .padding(ConvoyTheme.Spacing.sm)
                .background(Color.convoySurfaceFallback)
                .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
            }
        }
    }
    
    // MARK: - Parameters Section
    
    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "CONVOY SETTINGS")
            
            VStack(spacing: ConvoyTheme.Spacing.md) {
                // Formation Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Formation")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    
                    Picker("Formation", selection: $formation) {
                        ForEach(Formation.allCases, id: \.self) { form in
                            Text(form.label).tag(form)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Pace Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Group Riding Pace")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    
                    Picker("Pace", selection: $pace) {
                        ForEach(Pace.allCases, id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(ConvoyTheme.Spacing.md)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        }
    }
    
    // MARK: - Club Section
    
    private var clubSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "HOSTING CLUB")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ConvoyTheme.Spacing.sm) {
                    // Open Group
                    clubSelectionPill(title: "Open Group", isSelected: selectedClub == nil) {
                        selectedClub = nil
                    }
                    
                    // User's clubs
                    ForEach(clubs) { club in
                        clubSelectionPill(title: club.name, isSelected: selectedClub?.id == club.id) {
                            selectedClub = club
                        }
                    }
                }
            }
        }
    }
    
    private func clubSelectionPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.convoyCalloutBold)
                .foregroundStyle(isSelected ? Color.convoyBackgroundFallback : Color.convoyTextPrimaryFallback)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.convoyAccentFallback : Color.convoySurfaceFallback)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.convoyAccentFallback : Color.convoyBorderFallback, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Save Ride
    
    private func saveRide() {
        guard let currentUser = appState.currentUser else { return }
        
        let newRide = Ride(
            title: rideTitle,
            rideDescription: rideDescription,
            scheduledDate: scheduledDate,
            startLocationName: startLocation,
            startLatitude: 12.9716,
            startLongitude: 77.5946,
            endLocationName: endLocation,
            endLatitude: 12.4244,
            endLongitude: 75.7382,
            distanceKm: distanceKm,
            estimatedDurationSeconds: estimatedHours * 3600,
            ridingStyle: ridingStyle,
            formation: formation,
            pace: pace,
            organizerId: currentUser.id,
            organizerName: currentUser.name,
            leaderRiderId: currentUser.id,
            participants: [
                RideParticipant(
                    riderId: currentUser.id,
                    riderName: currentUser.name,
                    role: .lead,
                    status: .joined,
                    formationPosition: 1,
                    motorcycleModel: currentUser.primaryMotorcycle?.displayName
                )
            ]
        )
        
        // Attach waypoints after creation
        newRide.waypoints = waypoints.enumerated().map { index, wp in
            Waypoint(
                name: wp.name,
                latitude: 12.6 + Double(index) * 0.2,
                longitude: 76.5 + Double(index) * 0.3,
                order: index + 1,
                waypointType: wp.type
            )
        }
        
        modelContext.insert(newRide)
        try? modelContext.save()
        
        HapticManager.shared.rideCreated()
        dismiss()
    }
}
