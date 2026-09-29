import SwiftUI
import SwiftData

// MARK: - SOS Emergency View

struct SOSView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var countdown: Int = 10
    @State private var isCountdownActive: Bool = true
    @State private var sosTransmitted: Bool = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // High-contrast Emergency Background
            Color.convoySafetyFallback
                .opacity(0.18)
                .ignoresSafeArea()
            
            Color.convoyBackgroundFallback
                .ignoresSafeArea()
                .opacity(0.85)
            
            VStack(spacing: ConvoyTheme.Spacing.xl) {
                // Top Dismiss Button
                HStack {
                    Spacer()
                    Button("Cancel") {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                    .font(.convoyCalloutBold)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, 20)
                
                Spacer()
                
                // Pulsating SOS Beacon
                if !sosTransmitted {
                    countdownView
                } else {
                    transmittedView
                }
                
                Spacer()
                
                // Medical ID & Location Info
                medicalSnapshot
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                
                // Bottom Call 112 CTA
                callEmergencyButton
                    .padding(.horizontal, ConvoyTheme.Spacing.lg)
                    .padding(.bottom, 24)
            }
        }
        .onReceive(timer) { _ in
            if isCountdownActive && countdown > 0 {
                countdown -= 1
                HapticManager.shared.emergencyAlert()
                if countdown == 0 {
                    triggerSOS()
                }
            }
        }
    }
    
    // MARK: - Countdown View
    
    private var countdownView: some View {
        VStack(spacing: ConvoyTheme.Spacing.lg) {
            ZStack {
                // Outer Pulse Ring
                Circle()
                    .stroke(Color.convoySafetyFallback.opacity(0.3), lineWidth: 4)
                    .frame(width: 200, height: 200)
                    .scaleEffect(1.2)
                
                // Inner Ring
                Circle()
                    .fill(Color.convoySafetyFallback.opacity(0.2))
                    .frame(width: 170, height: 170)
                
                // Countdown Number
                VStack(spacing: 4) {
                    Text("\(countdown)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(Color.convoySafetyFallback)
                    
                    Text("SECONDS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color.convoySafetyFallback)
                }
            }
            
            VStack(spacing: 6) {
                Text("EMERGENCY SOS TRIGGERED")
                    .font(.convoyHeadline)
                    .foregroundStyle(Color.convoySafetyFallback)
                
                Text("Notifying your Convoy pack and emergency contacts with exact GPS coordinates.")
                    .font(.convoySubheadline)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ConvoyTheme.Spacing.xl)
            }
            
            // Cancel Button
            Button {
                isCountdownActive = false
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Text("Cancel Emergency Alert")
                    .font(.convoyCalloutBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.convoySurfaceElevatedFallback)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.convoyBorderFallback, lineWidth: 1))
            }
            .padding(.top, ConvoyTheme.Spacing.sm)
        }
    }
    
    // MARK: - Transmitted View
    
    private var transmittedView: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 54))
                .foregroundStyle(Color.convoySafetyFallback)
            
            Text("SOS BROADCAST ACTIVE")
                .font(.convoyTitle2)
                .foregroundStyle(Color.convoySafetyFallback)
            
            Text("Your live GPS location (12.9716°N, 77.5946°E) has been sent to Arun, Vishal, and Sarah Mathews.")
                .font(.convoyBody)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ConvoyTheme.Spacing.xl)
        }
    }
    
    // MARK: - Medical Snapshot
    
    private var medicalSnapshot: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            HStack {
                Image(systemName: "cross.case.fill")
                    .foregroundStyle(Color.convoySafetyFallback)
                Text("CRITICAL MEDICAL INFO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.convoySafetyFallback)
                Spacer()
            }
            
            HStack(spacing: ConvoyTheme.Spacing.xl) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blood Group")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    Text("O Positive")
                        .font(.convoySubheadlineBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Allergies")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    Text("None Known")
                        .font(.convoySubheadlineBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Emergency Contact")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    Text("Sarah (+91 98765 43210)")
                        .font(.convoySubheadlineBold)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                }
            }
        }
        .padding(ConvoyTheme.Spacing.md)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                .stroke(Color.convoySafetyFallback.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Call 112 Button
    
    private var callEmergencyButton: some View {
        Button {
            HapticManager.shared.heavyImpact()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("Call Emergency Services (112)")
                    .font(.convoyHeadline)
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.convoySafetyFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
            .shadow(color: Color.convoySafetyFallback.opacity(0.4), radius: 8, y: 3)
        }
    }
    
    private func triggerSOS() {
        sosTransmitted = true
        isCountdownActive = false
        HapticManager.shared.emergencyAlert()
    }
}

// MARK: - Safety Center View

struct SafetyCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var crashDetectionEnabled: Bool = true
    @State private var autoBeaconEnabled: Bool = true
    @State private var showCrashTestSimulator: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.xl) {
                    
                    // Status Banner
                    HStack(spacing: ConvoyTheme.Spacing.md) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.convoySuccessFallback)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Safety Systems Armed")
                                .font(.convoySubheadlineBold)
                                .foregroundStyle(Color.convoyTextPrimaryFallback)
                            Text("Motion sensors & emergency beacon active.")
                                .font(.convoyCaption)
                                .foregroundStyle(Color.convoyTextSecondaryFallback)
                        }
                        
                        Spacer()
                    }
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                            .stroke(Color.convoySuccessFallback.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Sensor Switches
                    VStack(spacing: ConvoyTheme.Spacing.sm) {
                        ConvoySectionHeader(title: "DETECTION SENSORS")
                        
                        Toggle("Crash & High-G Impact Detection", isOn: $crashDetectionEnabled)
                            .font(.convoyCallout)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                            .tint(Color.convoyAccentFallback)
                            .padding(ConvoyTheme.Spacing.md)
                            .background(Color.convoySurfaceFallback)
                            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                        
                        Toggle("Auto-Broadcast Fallen Rider to Pack", isOn: $autoBeaconEnabled)
                            .font(.convoyCallout)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                            .tint(Color.convoyAccentFallback)
                            .padding(ConvoyTheme.Spacing.md)
                            .background(Color.convoySurfaceFallback)
                            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                    }
                    
                    // Crash Simulator Test Trigger
                    VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
                        ConvoySectionHeader(title: "HARDWARE SIMULATOR")
                        
                        Button {
                            HapticManager.shared.heavyImpact()
                            showCrashTestSimulator = true
                        } label: {
                            HStack {
                                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                                    .foregroundStyle(Color.convoyWarningFallback)
                                Text("Simulate High-G Crash Event")
                                    .font(.convoyCalloutBold)
                                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.convoyTextSecondaryFallback)
                            }
                            .padding(ConvoyTheme.Spacing.md)
                            .background(Color.convoySurfaceFallback)
                            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                        }
                    }
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.md)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Safety Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
            .fullScreenCover(isPresented: $showCrashTestSimulator) {
                SOSView()
            }
        }
    }
}
