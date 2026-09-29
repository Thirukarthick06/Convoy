import SwiftUI
import CoreLocation

// MARK: - Date Formatting

extension Date {
    /// "Today", "Tomorrow", or formatted date
    var convoyRelative: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: self)
        }
    }
    
    /// "3:30 PM"
    var convoyTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
    
    /// "Sat, Oct 14"
    var convoyShortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: self)
    }
    
    /// "Saturday, October 14, 2024"
    var convoyFullDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
    
    /// Greeting based on time of day
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
}

// MARK: - Distance Formatting

extension Double {
    /// Format distance in km (e.g., "128.4 km" or "450 m")
    func formattedDistance(unit: UnitPreference = .metric) -> String {
        switch unit {
        case .metric:
            if self < 1.0 {
                return "\(Int(self * 1000)) m"
            }
            return String(format: "%.1f km", self)
        case .imperial:
            let miles = self * 0.621371
            if miles < 0.1 {
                return "\(Int(self * 3280.84)) ft"
            }
            return String(format: "%.1f mi", miles)
        }
    }
    
    /// Format speed (e.g., "85 km/h")
    func formattedSpeed(unit: UnitPreference = .metric) -> String {
        switch unit {
        case .metric:
            return "\(Int(self)) km/h"
        case .imperial:
            return "\(Int(self * 0.621371)) mph"
        }
    }
    
    /// Format seconds duration into "2h 35m"
    func formattedDuration() -> String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Duration Formatting

extension TimeInterval {
    /// "2h 35m"
    var convoyDuration: String {
        formattedDuration()
    }
    
    /// "02:35:00"
    var convoyTimer: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply a Convoy card style
    func convoyCardStyle() -> some View {
        self
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
            .convoyShadow(ConvoyTheme.Shadow.sm)
    }
    
    /// Apply glass effect
    func convoyGlass() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous)
                    .stroke(Color.convoyGlassBorder, lineWidth: 0.5)
            )
    }
    
    /// Animate on appear
    func convoyAppearAnimation(delay: Double = 0) -> some View {
        self
            .modifier(AppearAnimationModifier(delay: delay))
    }
    
    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Appear Animation Modifier

struct AppearAnimationModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8).delay(delay),
                value: isVisible
            )
            .onAppear { isVisible = true }
    }
}

// MARK: - CLLocationCoordinate2D

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {
    /// Distance in kilometers to another coordinate
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2) / 1000.0
    }
}

// MARK: - String

extension String {
    /// Generate initials from a name (e.g., "Kevin Miller" → "KM")
    var initials: String {
        let parts = self.split(separator: " ")
        let letters = parts.compactMap { $0.first }.prefix(2)
        return String(letters).uppercased()
    }
}

// MARK: - Array

extension Array {
    /// Safe subscript that returns nil for out-of-bounds
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
