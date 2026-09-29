import SwiftUI
import SwiftData

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        @Bindable var state = appState
        
        ZStack(alignment: .bottom) {
            // Tab Content
            TabView(selection: $state.selectedTab) {
                HomeView()
                    .tag(ConvoyTab.home)
                
                ClubsView()
                    .tag(ConvoyTab.clubs)
                
                RidesView()
                    .tag(ConvoyTab.rides)
                
                FriendsView()
                    .tag(ConvoyTab.friends)
                
                ProfileView()
                    .tag(ConvoyTab.profile)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            // Bottom Bar Overlay: Active Ride Bar + Custom Tab Bar
            VStack(spacing: 0) {
                // Active Ride Pill (Floating)
                if state.isRiding, let ride = state.activeRide {
                    activeRideBanner(ride: ride)
                        .padding(.horizontal, ConvoyTheme.Spacing.md)
                        .padding(.bottom, ConvoyTheme.Spacing.xs)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Custom Tab Bar
                customTabBar
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .fullScreenCover(isPresented: $state.isShowingLiveRide) {
            if let ride = state.activeRide {
                LiveRideView(ride: ride)
            }
        }
        .sheet(isPresented: $state.isShowingPlanRide) {
            PlanRideView()
        }
        .sheet(isPresented: $state.isShowingSafetyCenter) {
            SafetyCenterView()
        }
        .fullScreenCover(isPresented: $state.isShowingSOS) {
            SOSView()
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(ConvoyTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, ConvoyTheme.Spacing.sm)
        .padding(.top, ConvoyTheme.Spacing.xs)
        .padding(.bottom, 28) // Home indicator safe area
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Color.convoyBackgroundFallback.opacity(0.85)
                }
                .overlay(alignment: .top) {
                    Divider()
                        .background(Color.convoyBorderFallback)
                }
        }
    }
    
    private func tabButton(for tab: ConvoyTab) -> some View {
        Button {
            HapticManager.shared.tabSelection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appState.selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: appState.selectedTab == tab ? .semibold : .regular))
                    .symbolEffect(.bounce, value: appState.selectedTab == tab)
                    .frame(height: 24)
                
                Text(tab.label)
                    .font(.system(size: 10, weight: appState.selectedTab == tab ? .semibold : .medium))
            }
            .foregroundStyle(
                appState.selectedTab == tab
                ? Color.convoyAccentFallback
                : Color.convoyTextSecondaryFallback
            )
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Active Ride Banner
    
    private func activeRideBanner(ride: Ride) -> some View {
        Button {
            HapticManager.shared.lightImpact()
            appState.isShowingLiveRide = true
        } label: {
            HStack(spacing: ConvoyTheme.Spacing.md) {
                // Pulsing Green Indicator
                Circle()
                    .fill(Color.convoySuccessFallback)
                    .frame(width: 10, height: 10)
                    .overlay {
                        Circle()
                            .stroke(Color.convoySuccessFallback.opacity(0.5), lineWidth: 3)
                            .scaleEffect(1.6)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ride.title)
                        .font(.convoySubheadline)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text("LIVE CONVOY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.convoySuccessFallback)
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                        
                        Text("\(ride.participants.count) riders")
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                }
                
                Spacer()
                
                // Return to Map arrow
                HStack(spacing: 4) {
                    Text("Map")
                        .font(.convoyCaptionBold)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(Color.convoyAccentFallback)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.convoyAccentFallback.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, ConvoyTheme.Spacing.md)
            .padding(.vertical, ConvoyTheme.Spacing.sm)
            .background {
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                    .fill(Color.convoySurfaceFallback)
                    .overlay(
                        RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                            .stroke(Color.convoySuccessFallback.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 10, y: 4)
            }
        }
        .buttonStyle(.plain)
    }
}
