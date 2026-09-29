import SwiftUI

// MARK: - Primary Button

/// Convoy primary/secondary action button.
struct ConvoyButton: View {
    enum Style {
        case primary, secondary, destructive
    }
    
    let title: String
    let icon: String?
    let style: Style
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = isDestructive ? .destructive : style
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: ConvoyTheme.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.convoyHeadline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return Color.convoyAccentFallback
        case .destructive: return .white
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return Color.convoyAccentFallback
        case .secondary: return Color.convoySurfaceElevatedFallback
        case .destructive: return Color.convoySafetyFallback
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .destructive: return Color.clear
        case .secondary: return Color.convoyBorderFallback
        }
    }
}

// MARK: - Secondary Button

/// Convoy secondary button — subtle surface background, accent text.
struct ConvoySecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: ConvoyTheme.Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundStyle(Color.convoyAccentFallback)
            .background(Color.convoyAccentFallback.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Button

/// Small inline button for quick actions.
struct ConvoyCompactButton: View {
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void
    
    enum Style {
        case accent, secondary, destructive
        
        var foreground: Color {
            switch self {
            case .accent: return .convoyAccentFallback
            case .secondary: return .convoyTextSecondaryFallback
            case .destructive: return .convoySafetyFallback
            }
        }
        
        var background: Color {
            switch self {
            case .accent: return .convoyAccentFallback.opacity(0.12)
            case .secondary: return .convoyTextSecondaryFallback.opacity(0.1)
            case .destructive: return .convoySafetyFallback.opacity(0.12)
            }
        }
    }
    
    init(_ title: String, icon: String? = nil, style: Style = .accent, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, ConvoyTheme.Spacing.sm)
            .padding(.vertical, ConvoyTheme.Spacing.xs)
            .foregroundStyle(style.foreground)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Map Button

/// Floating button overlay for map controls.
struct ConvoyMapButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.convoyTextPrimaryFallback)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .convoyShadow(ConvoyTheme.Shadow.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Buttons") {
    VStack(spacing: 16) {
        ConvoyButton("Start Ride", icon: "location.fill") {}
        ConvoySecondaryButton("Plan Ride", icon: "map.fill") {}
        ConvoyButton("Emergency SOS", icon: "sos", isDestructive: true) {}
        HStack {
            ConvoyCompactButton("Call", icon: "phone.fill") {}
            ConvoyCompactButton("Message", icon: "message.fill", style: .secondary) {}
            ConvoyCompactButton("Cancel", icon: "xmark", style: .destructive) {}
        }
    }
    .padding()
    .background(Color.convoyBackgroundFallback)
    .preferredColorScheme(.dark)
}
