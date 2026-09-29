import SwiftUI

// MARK: - Avatar

/// Rider avatar with optional online status indicator.
struct ConvoyAvatar: View {
    let name: String
    let imageName: String?
    let size: CGFloat
    let showStatus: Bool
    let status: OnlineStatus?
    
    init(
        name: String,
        imageName: String? = nil,
        size: CGFloat = ConvoyTheme.AvatarSize.md,
        showStatus: Bool = false,
        status: OnlineStatus? = nil
    ) {
        self.name = name
        self.imageName = imageName
        self.size = size
        self.showStatus = showStatus
        self.status = status
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContent
                .frame(width: size, height: size)
                .clipShape(Circle())
            
            if showStatus, let status {
                Circle()
                    .fill(status.color)
                    .frame(width: size * 0.28, height: size * 0.28)
                    .overlay(
                        Circle()
                            .stroke(Color.convoyBackgroundFallback, lineWidth: 2)
                    )
                    .offset(x: 1, y: 1)
            }
        }
    }
    
    @ViewBuilder
    private var avatarContent: some View {
        if let imageName, !imageName.isEmpty {
            // System person icon as placeholder for demo
            Circle()
                .fill(
                    LinearGradient(
                        colors: [avatarColor, avatarColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Text(name.initials)
                        .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                )
        } else {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [avatarColor, avatarColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Text(name.initials)
                        .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                )
        }
    }
    
    /// Deterministic color based on name hash
    private var avatarColor: Color {
        let colors: [Color] = [
            Color(hex: "FF6B35"), // Convoy orange
            Color(hex: "5B8DEF"), // Blue
            Color(hex: "9B59B6"), // Purple
            Color(hex: "27AE60"), // Green
            Color(hex: "E74C3C"), // Red
            Color(hex: "F39C12"), // Yellow
            Color(hex: "1ABC9C"), // Teal
            Color(hex: "E67E22"), // Deep orange
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - Status Badge

/// Small pill-shaped status indicator.
struct ConvoyStatusBadge: View {
    let label: String
    let color: Color
    let icon: String?
    
    init(_ label: String, color: Color, icon: String? = nil) {
        self.label = label
        self.color = color
        self.icon = icon
    }
    
    init(status: RideStatus) {
        self.label = status.label
        self.color = status.color
        self.icon = status.icon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(label)
                .font(.system(size: 11, weight: .bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(color)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Pill

/// Tag/filter pill — selectable or display.
struct ConvoyPill: View {
    let label: String
    let icon: String?
    let isSelected: Bool
    var customColor: Color? = nil
    let action: () -> Void
    
    init(_ label: String, icon: String? = nil, isSelected: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.isSelected = isSelected
        self.customColor = nil
        self.action = action
    }
    
    init(text: String, color: Color = Color.convoyAccentFallback) {
        self.label = text
        self.icon = nil
        self.isSelected = false
        self.customColor = color
        self.action = {}
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, ConvoyTheme.Spacing.sm)
            .padding(.vertical, ConvoyTheme.Spacing.xs)
            .foregroundStyle(
                customColor != nil ? customColor! : (isSelected ? .white : Color.convoyTextSecondaryFallback)
            )
            .background(
                customColor != nil
                    ? customColor!.opacity(0.15)
                    : (isSelected ? Color.convoyAccentFallback : Color.convoySurfaceFallback)
            )
            .clipShape(Capsule())
            .animation(ConvoyTheme.Animation.quick, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Field

/// Convoy-styled search input.
struct ConvoySearchField: View {
    let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String = "Search", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        HStack(spacing: ConvoyTheme.Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.convoyTextTertiaryFallback)
            
            TextField(placeholder, text: $text)
                .font(.convoyBody)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.convoyTextTertiaryFallback)
                }
            }
        }
        .padding(.horizontal, ConvoyTheme.Spacing.sm)
        .frame(height: 44)
        .background(Color.convoySurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous))
    }
}

// MARK: - Alert Banner

/// Contextual alert banner for safety/ride events.
struct ConvoyAlertBanner: View {
    let message: String
    let icon: String
    let level: AlertLevel
    let action: (() -> Void)?
    let dismissAction: (() -> Void)?
    
    enum AlertLevel {
        case info, warning, critical
        
        var color: Color {
            switch self {
            case .info: return .convoyAccentFallback
            case .warning: return .convoyWarningFallback
            case .critical: return .convoySafetyFallback
            }
        }
    }
    
    init(
        _ message: String,
        icon: String = "exclamationmark.triangle.fill",
        level: AlertLevel = .warning,
        action: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.icon = icon
        self.level = level
        self.action = action
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        HStack(spacing: ConvoyTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(level.color)
            
            Text(message)
                .font(.convoySubheadline)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
                .lineLimit(2)
            
            Spacer()
            
            if let dismissAction {
                Button(action: dismissAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.convoyTextTertiaryFallback)
                        .frame(width: 28, height: 28)
                }
            }
        }
        .padding(ConvoyTheme.Spacing.sm)
        .background(level.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous)
                .stroke(level.color.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Rider Marker

/// Map annotation marker for a rider.
struct ConvoyRiderMarker: View {
    let name: String
    let role: RiderRole
    let status: RiderStatus
    let size: CGFloat
    
    init(name: String, role: RiderRole = .rider, status: RiderStatus = .moving, size: CGFloat = 44) {
        self.name = name
        self.role = role
        self.status = status
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(markerColor)
                    .frame(width: size, height: size)
                    .shadow(color: markerColor.opacity(0.4), radius: 6, y: 2)
                
                Text(name.initials)
                    .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                if role == .lead || role == .tail {
                    roleIndicator
                }
            }
            
            // Direction triangle
            Triangle()
                .fill(markerColor)
                .frame(width: 10, height: 6)
                .rotationEffect(.degrees(180))
                .offset(y: -4)
        }
    }
    
    private var markerColor: Color {
        switch role {
        case .lead: return .convoyAccentFallback
        case .tail: return Color(hex: "5B8DEF")
        case .organizer: return .convoyAccentFallback
        case .rider: return status.color
        }
    }
    
    @ViewBuilder
    private var roleIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: role.icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(role == .lead ? Color.convoyAccentFallback : Color(hex: "5B8DEF"))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.convoyBackgroundFallback, lineWidth: 1.5))
            }
            Spacer()
        }
        .frame(width: size + 8, height: size + 8)
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

#Preview("Components") {
    ScrollView {
        VStack(spacing: 20) {
            HStack {
                ConvoyAvatar(name: "Kevin Miller", size: 48, showStatus: true, status: .online)
                ConvoyAvatar(name: "Arun Kumar", size: 48, showStatus: true, status: .riding)
                ConvoyAvatar(name: "Priya Shah", size: 48, showStatus: true, status: .offline)
            }
            
            HStack {
                ConvoyStatusBadge("Active", color: .convoySuccessFallback, icon: "circle.fill")
                ConvoyStatusBadge("Lead", color: .convoyAccentFallback, icon: "flag.fill")
                ConvoyStatusBadge("Off Route", color: .convoySafetyFallback, icon: "exclamationmark.triangle.fill")
            }
            
            HStack {
                ConvoyPill("Scenic", icon: "mountain.2.fill", isSelected: true) {}
                ConvoyPill("Curvy", icon: "point.topleft.down.to.point.bottomright.curvepath.fill") {}
                ConvoyPill("Fast") {}
            }
            
            ConvoySearchField("Search riders", text: .constant(""))
            
            ConvoyAlertBanner("Rahul may have fallen behind", level: .warning)
            ConvoyAlertBanner("SOS activated by Arun", icon: "sos", level: .critical)
            
            HStack(spacing: 20) {
                ConvoyRiderMarker(name: "Kevin", role: .lead)
                ConvoyRiderMarker(name: "Arun", role: .rider, status: .moving)
                ConvoyRiderMarker(name: "Rahul", role: .tail, status: .stopped)
            }
        }
        .padding()
    }
    .background(Color.convoyBackgroundFallback)
    .preferredColorScheme(.dark)
}
