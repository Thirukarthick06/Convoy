import SwiftUI
import SwiftData

// MARK: - Home View

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Ride> { $0.statusRaw == "planned" },
           sort: \Ride.scheduledDate)
    private var upcomingRides: [Ride]
    
    @Query(filter: #Predicate<Ride> { $0.statusRaw == "completed" },
           sort: \Ride.scheduledDate, order: .reverse)
    private var completedRides: [Ride]
    
    @Query private var users: [User]
    
    @State private var showPlanRide = false
    @State private var showJoinRide = false
    
    private var currentUser: User? { users.first }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.xl) {
                    
                    // MARK: - Hero Section
                    heroSection
                    
                    // MARK: - Primary Action
                    primaryAction
                    
                    // MARK: - Upcoming Ride
                    if let nextRide = upcomingRides.first {
                        upcomingRideSection(nextRide)
                    } else {
                        emptyUpcomingSection
                    }
                    
                    // MARK: - Quick Actions
                    quickActionsSection
                    
                    // MARK: - Recent Ride
                    if let recentRide = completedRides.first {
                        recentRideSection(recentRide)
                    }
                    
                    // MARK: - Ride Insight
                    insightSection
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.sm)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    convoyLogo
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                }
            }
            .sheet(isPresented: $showPlanRide) {
                PlanRideView()
                    .environment(appState)
            }
            .sheet(isPresented: $showJoinRide) {
                JoinRideSheet()
            }
        }
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.xxs) {
            Text(appState.greeting)
                .font(.convoyTitle2)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text("Ready to ride?")
                .font(.convoyBody)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
        .convoyAppearAnimation()
    }
    
    // MARK: - Primary Action
    
    private var primaryAction: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            showPlanRide = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("START A RIDE", systemImage: "location.fill")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("Plan or start riding now")
                        .font(.convoyFootnote)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(ConvoyTheme.Spacing.lg)
            .background(
                LinearGradient(
                    colors: [Color.convoyAccentFallback, Color.convoyAccentFallback.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
            .convoyShadow(ConvoyTheme.Shadow.glow)
        }
        .buttonStyle(.plain)
        .convoyAppearAnimation(delay: 0.05)
    }
    
    // MARK: - Upcoming Ride
    
    private func upcomingRideSection(_ ride: Ride) -> some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader("Upcoming Ride")
            
            NavigationLink(destination: RideDetailView(ride: ride)) {
                ConvoyCard {
                    VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ride.name)
                                    .font(.convoyHeadline)
                                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                                
                                Text("\(ride.scheduledDate.convoyShortDate) · \(ride.scheduledDate.convoyTime)")
                                    .font(.convoyFootnote)
                                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                            }
                            
                            Spacer()
                            
                            ConvoyStatusBadge(ride.status.label, color: ride.status.color)
                        }
                        
                        Divider().opacity(0.3)
                        
                        // Route info
                        HStack(spacing: ConvoyTheme.Spacing.lg) {
                            routeInfoItem(icon: "mappin.circle.fill", label: ride.destinationName)
                            routeInfoItem(icon: "road.lanes", label: ride.estimatedDistanceKm.formattedDistance())
                            routeInfoItem(icon: "clock", label: ride.estimatedDuration.convoyDuration)
                        }
                        
                        // Participants
                        HStack(spacing: -8) {
                            ForEach(Array(ride.participants.prefix(5).enumerated()), id: \.element.id) { index, participant in
                                ConvoyAvatar(name: participant.name, size: 30)
                                    .overlay(Circle().stroke(Color.convoySurfaceFallback, lineWidth: 2))
                                    .zIndex(Double(5 - index))
                            }
                            
                            if ride.participants.count > 5 {
                                Text("+\(ride.participants.count - 5)")
                                    .font(.convoyCaption)
                                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                                    .padding(.leading, 12)
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
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .convoyAppearAnimation(delay: 0.1)
    }
    
    private var emptyUpcomingSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader("Next Ride")
            
            ConvoyCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No ride planned")
                            .font(.convoyHeadline)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        Text("Your next adventure starts here.")
                            .font(.convoyFootnote)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
        .convoyAppearAnimation(delay: 0.1)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader("Quick Actions")
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: ConvoyTheme.Spacing.sm),
                GridItem(.flexible(), spacing: ConvoyTheme.Spacing.sm),
            ], spacing: ConvoyTheme.Spacing.sm) {
                QuickActionCard(icon: "map.fill", title: "Plan Ride", color: .convoyAccentFallback) {
                    showPlanRide = true
                }
                QuickActionCard(icon: "qrcode.viewfinder", title: "Join Ride", color: Color(hex: "5B8DEF")) {
                    showJoinRide = true
                }
                QuickActionCard(icon: "sos", title: "SOS", color: .convoySafetyFallback) {
                    appState.isShowingSOS = true
                }
                QuickActionCard(icon: "person.crop.circle.badge.checkmark", title: "Emergency", color: .convoyWarningFallback) {
                    appState.isShowingSafetyCenter = true
                }
            }
        }
        .convoyAppearAnimation(delay: 0.15)
    }
    
    // MARK: - Recent Ride
    
    private func recentRideSection(_ ride: Ride) -> some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader("Recent Ride", actionLabel: "All Rides") {
                appState.selectedTab = .rides
            }
            
            NavigationLink(destination: RideDetailView(ride: ride)) {
                ConvoyCard {
                VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
                    // Map placeholder
                    RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.convoySurfaceElevatedFallback, Color.convoySurfaceFallback],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 100)
                        .overlay(
                            // Route line simulation
                            Path { path in
                                path.move(to: CGPoint(x: 20, y: 70))
                                path.addCurve(
                                    to: CGPoint(x: 280, y: 30),
                                    control1: CGPoint(x: 100, y: 20),
                                    control2: CGPoint(x: 200, y: 80)
                                )
                            }
                            .stroke(Color.convoyAccentFallback.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        )
                    
                    Text(ride.name)
                        .font(.convoyHeadline)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    Text(ride.scheduledDate.convoyRelative)
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    
                    HStack(spacing: ConvoyTheme.Spacing.lg) {
                        statItem(value: (ride.actualDistanceKm ?? ride.estimatedDistanceKm).formattedDistance(), label: "Distance")
                        statItem(value: (ride.actualDuration ?? ride.estimatedDuration).convoyDuration, label: "Duration")
                        statItem(value: "\(ride.participants.count)", label: "Riders")
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .convoyAppearAnimation(delay: 0.2)
    }
    }
    
    // MARK: - Insight
    
    private var insightSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader("Ride Insight")
            
            ConvoyCard {
                HStack(spacing: ConvoyTheme.Spacing.md) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.convoyAccentFallback)
                        .frame(width: 44, height: 44)
                        .background(Color.convoyAccentFallback.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your longest ride this month")
                            .font(.convoySubheadline)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        Text("234 km to Yelagiri Hills")
                            .font(.convoyFootnote)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                    
                    Spacer()
                }
            }
        }
        .convoyAppearAnimation(delay: 0.25)
    }
    
    // MARK: - Helpers
    
    private func routeInfoItem(icon: String, label: String) -> some View {
        Label(label, systemImage: icon)
            .font(.convoyCaption)
            .foregroundStyle(Color.convoyTextSecondaryFallback)
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            Text(label)
                .font(.convoyCaption2)
                .foregroundStyle(Color.convoyTextTertiaryFallback)
        }
    }
    
    private var convoyLogo: some View {
        Text("CONVOY")
            .font(.system(size: 15, weight: .black, design: .default))
            .tracking(3)
            .foregroundStyle(Color.convoyAccentFallback)
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            VStack(spacing: ConvoyTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm, style: .continuous))
                
                Text(title)
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ConvoyTheme.Spacing.md)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Join Ride Sheet (Placeholder)

struct JoinRideSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rideCode = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: ConvoyTheme.Spacing.xl) {
                Spacer()
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(Color.convoyAccentFallback)
                
                Text("Join a Ride")
                    .font(.convoyTitle2)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                
                Text("Scan a QR code or enter a ride code")
                    .font(.convoySubheadline)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                
                ConvoySearchField("Enter ride code", text: $rideCode)
                    .padding(.horizontal)
                
                ConvoyButton("Join Ride", icon: "person.badge.plus") {}
                    .padding(.horizontal)
                    .disabled(rideCode.isEmpty)
                    .opacity(rideCode.isEmpty ? 0.5 : 1)
                
                Spacer()
                Spacer()
            }
            .background(Color.convoyBackgroundFallback)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environment(AppState())
        .modelContainer(for: [User.self, Ride.self, Friend.self, Club.self])
        .preferredColorScheme(.dark)
}
