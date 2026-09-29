import SwiftUI
import SwiftData

// MARK: - Ride Journal View

struct RideJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \RideJournal.date, order: .reverse) private var journals: [RideJournal]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.xl) {
                    
                    if journals.isEmpty {
                        emptyJournalState
                    } else {
                        ForEach(journals) { entry in
                            journalEntryCard(entry)
                        }
                    }
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.md)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Ride Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
    }
    
    // MARK: - Journal Entry Card
    
    private func journalEntryCard(_ entry: RideJournal) -> some View {
        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.md) {
            // Header: Date & Title
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.convoyFullDate)
                    .font(.convoyCaption)
                    .foregroundStyle(Color.convoyAccentFallback)
                
                Text(entry.rideTitle)
                    .font(.convoyTitle3)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                
                Text("\(entry.startLocation) → \(entry.endLocation)")
                    .font(.convoySubheadline)
                    .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            
            // Metrics Ribbon
            HStack(spacing: ConvoyTheme.Spacing.lg) {
                metricItem(icon: "arrow.triangle.swap", value: entry.distanceKm.formattedDistance(), label: "Distance")
                metricItem(icon: "clock", value: entry.durationSeconds.formattedDuration(), label: "Duration")
                metricItem(icon: "person.2.fill", value: "\(entry.riderCount)", label: "Pack Size")
                metricItem(icon: "speedometer", value: "\(Int(entry.maxSpeedKmh)) km/h", label: "Max Speed")
            }
            .padding(.vertical, 4)
            
            Divider()
                .background(Color.convoyBorderFallback)
            
            // Narrative Story
            Text(entry.narrative)
                .font(.convoyBody)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .lineSpacing(4)
            
            // Highlights Pills
            if !entry.highlights.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("HIGHLIGHTS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(entry.highlights, id: \.self) { highlight in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.convoyAccentFallback)
                                    .padding(.top, 4)
                                Text(highlight)
                                    .font(.convoyCaption)
                                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(ConvoyTheme.Spacing.lg)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg)
                .stroke(Color.convoyBorderFallback, lineWidth: 1)
        )
    }
    
    private func metricItem(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.convoyAccentFallback)
                Text(value)
                    .font(.convoyCaptionBold)
                    .foregroundStyle(Color.convoyTextPrimaryFallback)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyJournalState: some View {
        VStack(spacing: ConvoyTheme.Spacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 44))
                .foregroundStyle(Color.convoyTextSecondaryFallback.opacity(0.5))
                .padding(.top, ConvoyTheme.Spacing.xl)
            
            Text("No Ride Memories Yet")
                .font(.convoyHeadline)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Text("Completed group rides will automatically preserve your memories, route telemetry, and moments here.")
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ConvoyTheme.Spacing.xl)
    }
}
