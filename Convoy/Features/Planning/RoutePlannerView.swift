import SwiftUI
import MapKit

// MARK: - Route Planner View

/// Detailed route planner view showing waypoint sequence, elevation changes, and twisties rating.
struct RoutePlannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var startLocation: String = "Bangalore (MG Road)"
    var destination: String = "Coorg (Madikeri)"
    
    @State private var waypoints: [String] = [
        "Channapatna Heritage Stop",
        "Kushalnagar River Point",
        "Madikeri Ghat Overlook"
    ]
    @State private var newWaypointName: String = ""
    @State private var curvinessIndex: Double = 0.88
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ConvoyTheme.Spacing.lg) {
                    
                    // Route Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                                .foregroundStyle(Color.convoyAccentFallback)
                            Text("SCENIC TWISTIES ROUTE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.convoyAccentFallback)
                            Spacer()
                            Text("Curviness 88%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.convoySuccessFallback)
                        }
                        
                        Text("\(startLocation) → \(destination)")
                            .font(.convoyHeadline)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                    }
                    .padding(ConvoyTheme.Spacing.md)
                    .background(Color.convoySurfaceFallback)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                    
                    // Map Preview
                    Map {
                        Marker("Start: \(startLocation)", coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946))
                            .tint(Color.convoyAccentFallback)
                        Marker("Destination: \(destination)", coordinate: CLLocationCoordinate2D(latitude: 12.4244, longitude: 75.7382))
                            .tint(Color.convoySuccessFallback)
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md))
                    
                    // Waypoints List
                    VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
                        ConvoySectionHeader(title: "WAYPOINT SEQUENCE")
                        
                        ForEach(Array(waypoints.enumerated()), id: \.offset) { index, point in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.convoyAccentFallback.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.convoyAccentFallback)
                                }
                                
                                Text(point)
                                    .font(.convoySubheadline)
                                    .foregroundStyle(Color.convoyTextPrimaryFallback)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        _ = waypoints.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                                }
                            }
                            .padding(ConvoyTheme.Spacing.md)
                            .background(Color.convoySurfaceFallback)
                            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                        }
                    }
                    
                    // Add Waypoint
                    HStack(spacing: 8) {
                        TextField("Add Fuel / Chai Stop...", text: $newWaypointName)
                            .font(.convoyBody)
                            .foregroundStyle(Color.convoyTextPrimaryFallback)
                            .padding(12)
                            .background(Color.convoySurfaceFallback)
                            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                        
                        Button {
                            guard !newWaypointName.isEmpty else { return }
                            withAnimation {
                                waypoints.append(newWaypointName)
                                newWaypointName = ""
                            }
                            HapticManager.shared.lightImpact()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.convoyBackgroundFallback)
                                .frame(width: 44, height: 44)
                                .background(Color.convoyAccentFallback)
                                .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm))
                        }
                        .disabled(newWaypointName.isEmpty)
                    }
                    
                    Spacer(minLength: ConvoyTheme.Spacing.huge)
                }
                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                .padding(.top, ConvoyTheme.Spacing.md)
            }
            .background(Color.convoyBackgroundFallback)
            .navigationTitle("Route Itinerary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
    }
}
