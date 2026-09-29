import SwiftUI
import SwiftData

// MARK: - Ride Complete View

struct RideCompleteView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let ride: Ride
    var distanceCovered: Double = 234.0
    var maxSpeed: Double = 98.0
    
    @State private var notesText: String = ""
    @State private var savedToJournal: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.xl) {
                    
                    // Celebration Header
                    celebrationHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    // Convoy Pack Safety Summary
                    safetySummaryCard
                    
                    // Cornering & Lean Insights
                    leanAngleCard
                    
                    // Notes & Memories
                    notesSection
                    
                    // Action Buttons
                    actionButtons
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.lg)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Ride Recap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var celebrationHeader: some View {
        VStack(spacing: ConvoyTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.convoyAccentFallback.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "flag.checkered")
                    .font(.system(size: 38))
                    .foregroundStyle(Color.convoyAccentFallback)
            }
            
            Text("Ride Completed!")
                .font(.convoyTitle)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text(ride.title)
                .font(.convoyHeadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
            
            Text(Date().convoyFullDate)
                .font(.convoyCaption)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
        .padding(.vertical, ConvoyTheme.Spacing.sm)
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        VStack(spacing: ConvoyTheme.Spacing.sm) {
            HStack(spacing: ConvoyTheme.Spacing.sm) {
                ConvoyStat(title: "Distance", value: String(format: "%.1f km", distanceCovered), icon: "arrow.triangle.swap")
                ConvoyStat(title: "Duration", value: "3h 48m", icon: "clock")
            }
            
            HStack(spacing: ConvoyTheme.Spacing.sm) {
                ConvoyStat(title: "Max Speed", value: "\(Int(maxSpeed)) km/h", icon: "speedometer")
                ConvoyStat(title: "Avg Speed", value: "62 km/h", icon: "gauge.with.dots.needle.50percent")
            }
        }
    }
    
    // MARK: - Safety Summary
    
    private var safetySummaryCard: some View {
        HStack(spacing: ConvoyTheme.Spacing.md) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.convoySuccessFallback)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Pack Reached Safely")
                    .font(.convoySubheadlineBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                
                Text("All \(ride.participants.count) riders stayed together with 0 safety incidents reported.")
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
    }
    
    // MARK: - Lean Angle Card
    
    private var leanAngleCard: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "CORNERING DYNAMICS")
            
            HStack(spacing: ConvoyTheme.Spacing.lg) {
                VStack(spacing: 4) {
                    Text("34°")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.convoyAccentFallback)
                    Text("Max Left Lean")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.convoyBorderFallback)
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("36°")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.convoyAccentFallback)
                    Text("Max Right Lean")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .background(Color.convoyBorderFallback)
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("1,240 m")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    Text("Elevation Climbed")
                        .font(.convoyCaption)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(ConvoyTheme.Spacing.md)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        }
    }
    
    // MARK: - Notes Section
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
            ConvoySectionHeader(title: "RIDE JOURNAL & MEMORIES")
            
            TextField("Add thoughts, road condition notes, or unforgettable moments...", text: $notesText, axis: .vertical)
                .lineLimit(3...5)
                .font(.convoyCallout)
                .padding(ConvoyTheme.Spacing.md)
                .background(Color.convoySurfaceFallback)
                .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: ConvoyTheme.Spacing.sm) {
            ConvoyButton(savedToJournal ? "Saved to Journal ✓" : "Save to Journal", icon: "book.fill") {
                saveToJournal()
            }
            .disabled(savedToJournal)
            
            ConvoyButton("Share Ride Memory", icon: "square.and.arrow.up", style: .secondary) {
                HapticManager.shared.lightImpact()
            }
        }
    }
    
    private func saveToJournal() {
        let journalEntry = RideJournal(
            rideId: ride.id,
            rideTitle: ride.title,
            date: Date(),
            startLocation: ride.startLocationName,
            endLocation: ride.endLocationName,
            narrative: notesText.isEmpty ? "Great group ride through scenic twisties." : notesText,
            highlights: [
                "Completed in staggered formation",
                "Max lean angle 36° reached",
                "Zero safety incidents"
            ],
            distanceKm: distanceCovered,
            durationSeconds: 13680,
            averageSpeedKmh: 62,
            maxSpeedKmh: maxSpeed,
            riderCount: ride.participants.count,
            stopCount: ride.waypoints.count
        )
        
        modelContext.insert(journalEntry)
        try? modelContext.save()
        
        HapticManager.shared.success()
        withAnimation {
            savedToJournal = true
        }
    }
}
