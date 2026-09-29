import SwiftUI
import SwiftData
import MapKit
import Combine

// MARK: - Live Ride View

struct LiveRideView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let ride: Ride
    
    // Live Telemetry Simulation
    @State private var currentSpeed: Double = 68.0
    @State private var maxSpeed: Double = 94.0
    @State private var distanceCovered: Double = 42.6
    @State private var remainingDistance: Double = 185.4
    @State private var leanAngle: Double = 18.0
    @State private var elevation: Double = 420.0
    
    // Map State
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(
        centerCoordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        distance: 2500,
        heading: 45,
        pitch: 50
    )))
    
    // Quick Signal / Hazard Broadcast
    @State private var activeBroadcast: String?
    @State private var showBroadcastBanner: Bool = false
    
    // Separation Alert Simulation
    @State private var separatedRider: String? = nil
    
    // Ride Finish
    @State private var showRideComplete: Bool = false
    @State private var showSOS: Bool = false
    @State private var isPaused: Bool = false
    
    // Simulation Timer
    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Fullscreen Map
            liveMap
                .ignoresSafeArea()
            
            // UI Overlays
            VStack(spacing: 0) {
                // Top: Convoy Formation Ribbon + Status
                topBarSection
                    .padding(.top, 50)
                    .padding(.horizontal, ConvoyTheme.Spacing.md)
                
                // Broadcast Alert Banner (if triggered)
                if showBroadcastBanner, let message = activeBroadcast {
                    broadcastBanner(message: message)
                        .padding(.horizontal, ConvoyTheme.Spacing.md)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Separation Warning (if rider stopped)
                if let separated = separatedRider {
                    separationWarning(riderName: separated)
                        .padding(.horizontal, ConvoyTheme.Spacing.md)
                        .padding(.top, 8)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Bottom: Glove-Friendly HUD & Quick Signals
                bottomHUDSection
                    .padding(.horizontal, ConvoyTheme.Spacing.md)
                    .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $showRideComplete) {
            RideCompleteView(ride: ride, distanceCovered: distanceCovered, maxSpeed: maxSpeed)
        }
        .fullScreenCover(isPresented: $showSOS) {
            SOSView()
        }
        .onReceive(timer) { _ in
            simulateTelemetry()
        }
    }
    
    // MARK: - Live Map
    
    private var liveMap: some View {
        Map(position: $cameraPosition) {
            // Leader Marker
            Annotation("Arun (Lead)", coordinate: CLLocationCoordinate2D(latitude: 12.9730, longitude: 77.5960)) {
                riderAnnotation(initial: "A", role: "LEAD", color: Color.convoyAccentFallback)
            }
            
            // User Marker (You)
            Annotation("You", coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)) {
                ZStack {
                    Circle()
                        .fill(Color.convoySuccessFallback.opacity(0.3))
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .fill(Color.convoySuccessFallback)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                }
            }
            
            // Sweep Marker
            Annotation("Vishal (Sweep)", coordinate: CLLocationCoordinate2D(latitude: 12.9690, longitude: 77.5920)) {
                riderAnnotation(initial: "V", role: "SWEEP", color: Color.convoyWarningFallback)
            }
            
            // Next Waypoint Marker
            Marker("Vellore Chai Stop", coordinate: CLLocationCoordinate2D(latitude: 12.9800, longitude: 77.6100))
                .tint(Color.convoyAccentFallback)
        }
        .mapStyle(.standard(elevation: .realistic))
    }
    
    private func riderAnnotation(initial: String, role: String, color: Color) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 4)
                
                Text(initial)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.convoyBackgroundFallback)
            }
            
            Text(role)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(color)
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Top Bar Section
    
    private var topBarSection: some View {
        VStack(spacing: 8) {
            // Header Row: Back button, Title, SOS
            HStack {
                Button {
                    HapticManager.shared.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                VStack(spacing: 2) {
                    Text(ride.title)
                        .font(.convoyCalloutBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.convoySuccessFallback)
                            .frame(width: 8, height: 8)
                        Text("3 RIDERS CONNECTED • STAGGERED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.convoySuccessFallback)
                    }
                }
                
                Spacer()
                
                // Emergency SOS Button
                Button {
                    HapticManager.shared.emergencyAlert()
                    showSOS = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sos")
                            .font(.system(size: 14, weight: .black))
                        Text("SOS")
                            .font(.system(size: 12, weight: .black))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.convoySafetyFallback)
                    .clipShape(Capsule())
                    .shadow(color: Color.convoySafetyFallback.opacity(0.5), radius: 6)
                }
            }
            
            // Convoy Formation Ribbon (Real-Time Chain)
            HStack(spacing: 4) {
                formationNode(name: "Arun", role: "LEAD", distance: "Ahead 80m", isLead: true)
                formationLink(distance: "80m", isSafe: true)
                formationNode(name: "You", role: "MID", distance: "\(Int(currentSpeed)) km/h", isYou: true)
                formationLink(distance: "140m", isSafe: true)
                formationNode(name: "Vishal", role: "SWEEP", distance: "Behind 140m", isSweep: true)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    private func formationNode(name: String, role: String, distance: String, isLead: Bool = false, isYou: Bool = false, isSweep: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(name)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isYou ? Color.convoySuccessFallback : Color.convoyTextPrimaryFallback)
            
            Text(role)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(isLead ? Color.convoyAccentFallback : (isSweep ? Color.convoyWarningFallback : Color.convoyTextSecondaryFallback))
            
            Text(distance)
                .font(.system(size: 9))
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formationLink(distance: String, isSafe: Bool) -> some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(isSafe ? Color.convoySuccessFallback : Color.convoyWarningFallback)
                .frame(height: 2)
            Image(systemName: "arrow.right")
                .font(.system(size: 8))
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
        .frame(width: 32)
    }
    
    // MARK: - Alerts
    
    private func broadcastBanner(message: String) -> some View {
        HStack(spacing: ConvoyTheme.Spacing.sm) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.convoyAccentFallback)
            
            Text(message)
                .font(.convoyCalloutBold)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm)
                .stroke(Color.convoyAccentFallback, lineWidth: 1)
        )
    }
    
    private func separationWarning(riderName: String) -> some View {
        HStack(spacing: ConvoyTheme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.convoyWarningFallback)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(riderName) has stopped")
                    .font(.convoySubheadlineBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                Text("Distance growing (1.2 km). Convoy alert notified.")
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            
            Spacer()
            
            Button("Dismiss") {
                withAnimation { separatedRider = nil }
            }
            .font(.convoyCaptionBold)
            .foregroundStyle(Color.convoyAccentFallback)
        }
        .padding(ConvoyTheme.Spacing.md)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                .stroke(Color.convoyWarningFallback, lineWidth: 1)
        )
    }
    
    // MARK: - Bottom HUD & Quick Signals
    
    private var bottomHUDSection: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            
            // Large Glove-Friendly Quick Signals
            HStack(spacing: ConvoyTheme.Spacing.sm) {
                quickSignalButton(title: "Fuel Stop", icon: "fuelpump.fill", color: Color.convoyWarningFallback) {
                    sendSignal("⛽️ Fuel Stop requested by Kevin")
                }
                quickSignalButton(title: "Pull Over", icon: "hand.raised.fill", color: Color.convoySafetyFallback) {
                    sendSignal("🛑 Pull Over requested — regroup needed")
                }
                quickSignalButton(title: "Hazard", icon: "exclamationmark.triangle.fill", color: Color.convoyAccentFallback) {
                    sendSignal("⚠️ Road Hazard ahead (Gravel / Potholes)")
                }
                quickSignalButton(title: "Thumbs Up", icon: "hand.thumbsup.fill", color: Color.convoySuccessFallback) {
                    sendSignal("👍 Convoy pace is good")
                }
            }
            
            // Telemetry Dashboard Glass Card
            VStack(spacing: ConvoyTheme.Spacing.md) {
                HStack {
                    // Speedometer Display
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(Int(currentSpeed))")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        
                        Text("KM/H SPEED")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                    
                    Spacer()
                    
                    // Lean Angle & Heading
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "angle")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.convoyAccentFallback)
                            Text("\(Int(leanAngle))° Lean")
                                .font(.convoySubheadlineBold)
                                .foregroundStyle(Color.convoyTextPrimaryFallback)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "safari.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.convoyAccentFallback)
                            Text("NE 045°")
                                .font(.convoySubheadlineBold)
                                .foregroundStyle(Color.convoyTextPrimaryFallback)
                        }
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Trip Progress Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f km covered", distanceCovered))
                            .font(.convoyCaptionBold)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                        Text("Remaining: \(String(format: "%.1f km", remainingDistance))")
                            .font(.convoyCaption)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                    }
                    
                    Spacer()
                    
                    // Ride Controls: Pause & Finish
                    HStack(spacing: 8) {
                        Button {
                            withAnimation { isPaused.toggle() }
                            HapticManager.shared.lightImpact()
                        } label: {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.convoyTextPrimaryFallback)
                                .frame(width: 44, height: 44)
                                .background(Color.convoySurfaceElevatedFallback)
                                .clipShape(Circle())
                        }
                        
                        Button {
                            HapticManager.shared.rideComplete()
                            appState.endRide()
                            showRideComplete = true
                        } label: {
                            Text("Finish")
                                .font(.convoyCalloutBold)
                                .foregroundStyle(Color.convoyBackgroundFallback)
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(Color.convoyAccentFallback)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(ConvoyTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    private func quickSignalButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                    .stroke(color.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func sendSignal(_ message: String) {
        HapticManager.shared.heavyImpact()
        activeBroadcast = message
        withAnimation { showBroadcastBanner = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation { showBroadcastBanner = false }
        }
    }
    
    // MARK: - Simulation Telemetry
    
    private func simulateTelemetry() {
        guard !isPaused else { return }
        
        // Random micro speed fluctuations
        let speedDelta = Double.random(in: -3.0...3.0)
        currentSpeed = max(35.0, min(108.0, currentSpeed + speedDelta))
        if currentSpeed > maxSpeed { maxSpeed = currentSpeed }
        
        distanceCovered += 0.04
        remainingDistance = max(0, remainingDistance - 0.04)
        
        leanAngle = max(0, min(38, leanAngle + Double.random(in: -4.0...4.0)))
    }
}
