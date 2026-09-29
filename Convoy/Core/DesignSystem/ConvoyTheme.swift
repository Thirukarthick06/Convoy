import SwiftUI

// MARK: - Convoy Design Tokens

/// Central design system for the Convoy application.
/// All visual tokens flow from here — never use ad-hoc colors or sizing.
enum ConvoyTheme {

    // MARK: - Spacing Scale

    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let huge: CGFloat = 56
        static let massive: CGFloat = 80
    }

    // MARK: - Corner Radius

    enum Radius {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let pill: CGFloat = 100
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 44
    }

    // MARK: - Avatar Sizes

    enum AvatarSize {
        static let sm: CGFloat = 32
        static let md: CGFloat = 40
        static let lg: CGFloat = 56
        static let xl: CGFloat = 72
        static let profile: CGFloat = 96
    }

    // MARK: - Animations

    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.65)
        static let gentle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
    }
}

// MARK: - Color System

extension Color {
    // MARK: Backgrounds
    static let convoyBackground = Color("ConvoyBackground")
    static let convoySurface = Color("ConvoySurface")
    static let convoySurfaceElevated = Color("ConvoySurfaceElevated")

    // MARK: Accent
    static let convoyAccent = Color("ConvoyAccent")
    static let convoyAccentSubtle = Color("ConvoyAccent").opacity(0.15)

    // MARK: Text
    static let convoyTextPrimary = Color("ConvoyTextPrimary")
    static let convoyTextSecondary = Color("ConvoyTextSecondary")
    static let convoyTextTertiary = Color("ConvoyTextTertiary")

    // MARK: Semantic
    static let convoySafety = Color("ConvoySafety")
    static let convoySuccess = Color("ConvoySuccess")
    static let convoyWarning = Color("ConvoyWarning")

    // MARK: Map
    static let convoyRoute = Color("ConvoyAccent")
    static let convoyRouteAlt = Color("ConvoyAccent").opacity(0.4)

    // MARK: Adaptive glass
    static let convoyGlass = Color("ConvoySurface").opacity(0.72)
    static let convoyGlassBorder = Color.white.opacity(0.08)

    // MARK: Fallback initializers (used when asset catalog is missing)

    /// Programmatic color definitions — mirrors asset catalog values.
    /// These are the canonical Convoy palette.
    static let convoyBackgroundFallback = Color(light: .init(hex: "FFFFFF"), dark: .init(hex: "0A0A0C"))
    static let convoySurfaceFallback = Color(light: .init(hex: "F5F5F7"), dark: .init(hex: "1C1C1E"))
    static let convoySurfaceElevatedFallback = Color(light: .init(hex: "FFFFFF"), dark: .init(hex: "2C2C2E"))
    static let convoyAccentFallback = Color(hex: "FF6B35")
    static let convoyTextPrimaryFallback = Color(light: .init(hex: "1D1D1F"), dark: .init(hex: "F5F5F7"))
    static let convoyTextSecondaryFallback = Color(light: .init(hex: "86868B"), dark: .init(hex: "98989D"))
    static let convoyTextTertiaryFallback = Color(light: .init(hex: "AEAEB2"), dark: .init(hex: "636366"))
    static let convoySafetyFallback = Color(light: .init(hex: "FF3B30"), dark: .init(hex: "FF453A"))
    static let convoySuccessFallback = Color(light: .init(hex: "34C759"), dark: .init(hex: "30D158"))
    static let convoyWarningFallback = Color(light: .init(hex: "FF9500"), dark: .init(hex: "FF9F0A"))
    static let convoyBorderFallback = Color(light: .init(hex: "E5E5EA"), dark: .init(hex: "2C2C2E"))
}

// MARK: - Color Helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Typography

extension Font {
    // MARK: Display
    static let convoyLargeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let convoyTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let convoyTitle2 = Font.system(size: 22, weight: .bold, design: .default)
    static let convoyTitle3 = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: Body
    static let convoyHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let convoyBody = Font.system(size: 17, weight: .regular, design: .default)
    static let convoyCallout = Font.system(size: 16, weight: .regular, design: .default)
    static let convoyCalloutBold = Font.system(size: 16, weight: .bold, design: .default)
    static let convoySubheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let convoySubheadlineBold = Font.system(size: 15, weight: .bold, design: .default)
    static let convoyFootnote = Font.system(size: 13, weight: .regular, design: .default)
    static let convoyCaption = Font.system(size: 12, weight: .regular, design: .default)
    static let convoyCaptionBold = Font.system(size: 12, weight: .bold, design: .default)
    static let convoyCaption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: Numeric / Monospaced
    static let convoyMono = Font.system(size: 17, weight: .medium, design: .monospaced)
    static let convoyMonoLarge = Font.system(size: 34, weight: .bold, design: .monospaced)
    static let convoyStatValue = Font.system(size: 28, weight: .bold, design: .rounded)
}

// MARK: - Shadow Presets

extension ConvoyTheme {
    enum Shadow {
        static let sm = ConvoyShadow(color: .black.opacity(0.06), radius: 4, y: 2)
        static let md = ConvoyShadow(color: .black.opacity(0.1), radius: 8, y: 4)
        static let lg = ConvoyShadow(color: .black.opacity(0.15), radius: 16, y: 8)
        static let glow = ConvoyShadow(color: .convoyAccentFallback.opacity(0.3), radius: 12, y: 0)
    }
}

struct ConvoyShadow {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
}

extension View {
    func convoyShadow(_ shadow: ConvoyShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
