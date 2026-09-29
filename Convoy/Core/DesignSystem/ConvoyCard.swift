import SwiftUI

// MARK: - Card

/// Standard Convoy content card with surface background.
struct ConvoyCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ConvoyTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
    }
}

// MARK: - Glass Card

/// Translucent glass card — ideal for map overlays and immersive contexts.
struct ConvoyGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ConvoyTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

// MARK: - Route Card

/// Visual card for displaying a ride/route preview.
struct ConvoyRouteCard: View {
    let title: String
    let subtitle: String
    let distance: String
    let duration: String
    let participantCount: Int
    let statusColor: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String,
        distance: String,
        duration: String,
        participantCount: Int = 0,
        statusColor: Color = .convoyAccentFallback,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.distance = distance
        self.duration = duration
        self.participantCount = participantCount
        self.statusColor = statusColor
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.sm) {
                // Route preview placeholder
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.convoySurfaceElevatedFallback,
                                Color.convoySurfaceFallback
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "map.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.convoyTextTertiaryFallback)
                    )
                
                VStack(alignment: .leading, spacing: ConvoyTheme.Spacing.xxs) {
                    Text(title)
                        .font(.convoyHeadline)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                    
                    Text(subtitle)
                        .font(.convoyFootnote)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                }
                
                HStack(spacing: ConvoyTheme.Spacing.md) {
                    Label(distance, systemImage: "road.lanes")
                    Label(duration, systemImage: "clock")
                    if participantCount > 0 {
                        Label("\(participantCount)", systemImage: "person.2.fill")
                    }
                }
                .font(.convoyCaption)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
            }
            .padding(ConvoyTheme.Spacing.sm)
            .background(Color.convoySurfaceFallback)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

/// Consistent section header with optional action.
struct ConvoySectionHeader: View {
    let title: String
    let action: (() -> Void)?
    let actionLabel: String?
    
    init(_ title: String, actionLabel: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionLabel = actionLabel
        self.action = action
    }
    
    init(title: String, actionLabel: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionLabel = actionLabel
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.convoyTitle3)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            
            Spacer()
            
            if let actionLabel, let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.convoySubheadline)
                        .foregroundStyle(Color.convoyAccentFallback)
                }
            }
        }
    }
}

// MARK: - Stat

/// Single stat display (value + label).
struct ConvoyStat: View {
    let value: String
    let label: String
    let icon: String?
    
    init(_ value: String, label: String, icon: String? = nil) {
        self.value = value
        self.label = label
        self.icon = icon
    }
    
    init(title: String, value: String, icon: String? = nil) {
        self.value = value
        self.label = title
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: ConvoyTheme.Spacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.convoyAccentFallback)
            }
            Text(value)
                .font(.convoyStatValue)
                .foregroundStyle(Color.convoyTextPrimaryFallback)
            Text(label)
                .font(.convoyCaption)
                .foregroundStyle(Color.convoyTextSecondaryFallback)
        }
    }
}

// MARK: - Previews

#Preview("Cards") {
    ScrollView {
        VStack(spacing: 16) {
            ConvoyCard {
                VStack(alignment: .leading) {
                    Text("Card Title").font(.convoyHeadline)
                    Text("Card content").font(.convoyBody)
                }
            }
            
            ConvoyGlassCard {
                Text("Glass Card")
                    .font(.convoyHeadline)
            }
            
            ConvoyRouteCard(
                title: "Saturday Coastal Run",
                subtitle: "Oct 14, 2024 · 8:00 AM",
                distance: "128 km",
                duration: "2h 30m",
                participantCount: 5
            )
            
            ConvoySectionHeader("Recent Rides", actionLabel: "See All") {}
            
            HStack {
                ConvoyStat("24", label: "Rides", icon: "road.lanes")
                ConvoyStat("1,248", label: "km", icon: "point.topleft.down.to.point.bottomright.curvepath.fill")
                ConvoyStat("36h", label: "Riding", icon: "clock")
            }
        }
        .padding()
    }
    .background(Color.convoyBackgroundFallback)
    .preferredColorScheme(.dark)
}
