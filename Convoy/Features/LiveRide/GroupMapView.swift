import SwiftUI
import MapKit

// MARK: - Group Map View

/// Interactive live MapKit component displaying the convoy formation, pack members, and active route.
struct GroupMapView: View {
    let ride: Ride
    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        Map(position: $cameraPosition) {
            // Convoy Lead Annotation
            Annotation("Lead Rider", coordinate: CLLocationCoordinate2D(latitude: 12.9730, longitude: 77.5960)) {
                ConvoyRiderMarker(name: "Arun", role: .lead, status: .moving, size: 40)
            }
            
            // Current User Annotation
            Annotation("You", coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)) {
                ZStack {
                    Circle()
                        .fill(Color.convoySuccessFallback.opacity(0.3))
                        .frame(width: 48, height: 48)
                    Circle()
                        .fill(Color.convoySuccessFallback)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                }
            }
            
            // Sweep Rider Annotation
            Annotation("Sweep Rider", coordinate: CLLocationCoordinate2D(latitude: 12.9690, longitude: 77.5920)) {
                ConvoyRiderMarker(name: "Vishal", role: .tail, status: .moving, size: 38)
            }
            
            // Scheduled Waypoints
            ForEach(ride.waypoints) { wp in
                Marker(wp.name, coordinate: CLLocationCoordinate2D(latitude: wp.latitude, longitude: wp.longitude))
                    .tint(Color.convoyAccentFallback)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
    }
}
