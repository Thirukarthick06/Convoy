import SwiftUI
import MapKit

// MARK: - AI Planner View

/// AI route synthesis interface allowing riders to generate twisty, scenic motorcycle routes.
struct AIPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var onApplyRecommendation: ((AIScenicRouteRecommendation) -> Void)?
    
    @State private var startLocation = "Bangalore (MG Road)"
    @State private var destination = "Coorg (Madikeri)"
    @State private var curvinessLevel: Double = 0.85
    @State private var avoidHighways: Bool = true
    @State private var prioritizeScenicViewpoints: Bool = true
    
    @State private var isGenerating: Bool = false
    @State private var recommendation: AIScenicRouteRecommendation?
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.lg) {
                    
                    // AI Sparkle Banner
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.convoyAccentFallback)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Convoy AI Twisties Engine")
                                .font(.convoyHeadline)
                                .foregroundStyle(Color.convoyTextPrimaryFallback)
                            Text("Synthesizes topographical curvature, smooth tarmac, and scenic passes.")
                                .font(.convoyCaption)
                                .foregroundStyle(Color.convoyTextSecondaryFallback)
                        }
                    }
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                    
                    // Parameters
                    VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.md) {
                        ConvoySectionHeader(title: "ROUTE PARAMETERS")
                        
                        // Locations
                        VStack(spacing: 8) {
                            TextField("Starting Point", text: $startLocation)
                                .font(.convoyCallout)
                                .padding(10)
                                .background(Color.convoySurfaceElevatedFallback)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            TextField("Destination", text: $destination)
                                .font(.convoyCallout)
                                .padding(10)
                                .background(Color.convoySurfaceElevatedFallback)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Curviness Slider
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Twisties Curvature Target")
                                    .font(.convoySubheadlineBold)
                                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                                Spacer()
                                Text("\(Int(curvinessLevel * 100))%")
                                    .font(.convoySubheadlineBold)
                                    .foregroundStyle(Color.convoyAccentFallback)
                            }
                            
                            Slider(value: $curvinessLevel, in: 0.2...1.0, step: 0.05)
                                .tint(Color.convoyAccentFallback)
                        }
                        
                        Toggle("Avoid Boring Straight Highways", isOn: $avoidHighways)
                            .font(.convoyCallout)
                            .tint(Color.convoyAccentFallback)
                        
                        Toggle("Include Scenic Mountain Viewpoints", isOn: $prioritizeScenicViewpoints)
                            .font(.convoyCallout)
                            .tint(Color.convoyAccentFallback)
                    }
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                    
                    // Generate Button
                    ConvoyButton(isGenerating ? "Synthesizing Best Curves..." : "Generate AI Twisty Route", icon: "sparkles") {
                        generateRoute()
                    }
                    .disabled(isGenerating)
                    
                    // Generated Recommendation Result
                    if let rec = recommendation {
                        VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(rec.title)
                                        .font(.convoyTitle3)
                                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                                    Text(rec.subtitle)
                                        .font(.convoyCaption)
                                        .foregroundStyle(Color.convoyAccentFallback)
                                }
                                Spacer()
                                ConvoyPill(text: "RECOMMENDED", color: Color.convoySuccessFallback)
                            }
                            
                            HStack(spacing: ConvoyTheme.Spacing.lg) {
                                ConvoyStat(title: "Distance", value: "\(Int(rec.distanceKm)) km", icon: "arrow.triangle.swap")
                                ConvoyStat(title: "Duration", value: String(format: "%.1f hrs", rec.estimatedDurationHours), icon: "clock")
                                ConvoyStat(title: "Twisties", value: "\(Int(rec.curvinessScore * 100))%", icon: "point.topleft.down.to.point.bottomright.curvepath.fill")
                            }
                            
                            Text(rec.description)
                                .font(.convoyBody)
                                .foregroundStyle(Color.convoyTextSecondaryFallback)
                            
                            ConvoyButton("Apply AI Route to Ride", icon: "checkmark") {
                                onApplyRecommendation?(rec)
                                HapticManager.shared.success()
                                dismiss()
                            }
                        }
                        .padding(ConvoyTheme.Spacing.md)
                        .background(Color.convoySurfaceFallback)
                        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md)
                                .stroke(Color.convoyAccentFallback.opacity(0.4), lineWidth: 1)
                        )
                    }
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.md)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("AI Route Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
            }
        }
    }
    
    private func generateRoute() {
        isGenerating = true
        HapticManager.shared.lightImpact()
        
        Task {
            let result = try? await AIService.shared.generateTwistyRoute(
                startLocation: startLocation,
                destination: destination,
                curvinessTarget: curvinessLevel,
                avoidHighways: avoidHighways
            )
            
            await MainActor.run {
                self.recommendation = result
                self.isGenerating = false
                HapticManager.shared.success()
            }
        }
    }
}
