import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            Color.convoyBackgroundFallback.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)
                
                // Bottom controls
                VStack(spacing: ConvoyTheme.Spacing.lg) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.convoyAccentFallback : Color.convoyTextTertiaryFallback)
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.bottom, ConvoyTheme.Spacing.sm)
                    
                    if currentPage == pages.count - 1 {
                        // Final page — auth buttons
                        VStack(spacing: ConvoyTheme.Spacing.sm) {
                            Button(action: { completeOnboarding() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Continue with Apple")
                                        .font(.convoyHeadline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .foregroundStyle(.white)
                                .background(Color.convoyTextPrimaryFallback)
                                .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous))
                            }
                            
                            Button(action: { completeOnboarding() }) {
                                Text("Create Account")
                                    .font(.convoyHeadline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .foregroundStyle(Color.convoyAccentFallback)
                                    .background(Color.convoyAccentFallback.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: ConvoyTheme.Radius.md, style: .continuous))
                            }
                        }
                    } else {
                        // Next / Skip
                        HStack {
                            Button("Skip") {
                                withAnimation { currentPage = pages.count - 1 }
                            }
                            .font(.convoySubheadline)
                            .foregroundStyle(Color.convoyTextSecondaryFallback)
                            
                            Spacer()
                            
                            Button(action: { withAnimation { currentPage += 1 } }) {
                                HStack(spacing: 6) {
                                    Text("Next")
                                        .font(.convoyHeadline)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(Color.convoyAccentFallback)
                                .padding(.horizontal, ConvoyTheme.Spacing.lg)
                                .padding(.vertical, ConvoyTheme.Spacing.sm)
                                .background(Color.convoyAccentFallback.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, ConvoyTheme.Spacing.xl)
                .padding(.bottom, ConvoyTheme.Spacing.xxxl)
            }
        }
        .onAppear { isAnimating = true }
    }
    
    private func completeOnboarding() {
        HapticManager.shared.buttonTap()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            appState.hasCompletedOnboarding = true
            appState.isAuthenticated = true
        }
    }
}

// MARK: - Onboarding Page Data

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let symbols: [String]
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "road.lanes",
            title: "Ride together.\nStay together.",
            subtitle: "CONVOY",
            symbols: ["figure.outdoor.cycle", "arrow.right", "figure.outdoor.cycle"]
        ),
        OnboardingPage(
            icon: "location.fill",
            title: "Know where\neveryone is.",
            subtitle: "See your entire group on the map in real time.",
            symbols: ["mappin.and.ellipse", "person.3.fill", "location.fill"]
        ),
        OnboardingPage(
            icon: "map.fill",
            title: "Plan rides\neveryone can follow.",
            subtitle: "Routes that work for your group, with meeting points and stops.",
            symbols: ["point.topleft.down.to.point.bottomright.curvepath.fill", "arrow.triangle.merge", "flag.checkered"]
        ),
        OnboardingPage(
            icon: "shield.checkered",
            title: "Ride safer.",
            subtitle: "Group separation alerts, emergency contacts, and SOS — always within reach.",
            symbols: ["exclamationmark.triangle.fill", "sos", "phone.fill"]
        ),
        OnboardingPage(
            icon: "book.pages.fill",
            title: "Remember\nevery ride.",
            subtitle: "Your rides become stories — with routes, stats, and photos.",
            symbols: ["photo.on.rectangle", "chart.bar.fill", "text.quote"]
        ),
    ]
}

// MARK: - Single Onboarding Page

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    
    @State private var symbolsAnimated = false
    
    var body: some View {
        VStack(spacing: ConvoyTheme.Spacing.xxl) {
            Spacer()
            
            // Icon cluster
            ZStack {
                // Background glow
                Circle()
                    .fill(Color.convoyAccentFallback.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .scaleEffect(symbolsAnimated ? 1 : 0.8)
                
                // Floating symbols
                ForEach(Array(page.symbols.enumerated()), id: \.offset) { index, symbol in
                    Image(systemName: symbol)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color.convoyAccentFallback.opacity(0.6))
                        .offset(symbolOffset(index: index))
                        .scaleEffect(symbolsAnimated ? 1 : 0.5)
                        .opacity(symbolsAnimated ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(Double(index) * 0.15),
                            value: symbolsAnimated
                        )
                }
                
                // Center icon
                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.convoyAccentFallback)
                    .scaleEffect(symbolsAnimated ? 1 : 0.6)
                    .opacity(symbolsAnimated ? 1 : 0)
            }
            .frame(height: 220)
            
            // Text
            VStack(spacing: ConvoyTheme.Spacing.md) {
                if page.subtitle == "CONVOY" {
                    // Logo page
                    Text("CONVOY")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .tracking(6)
                        .foregroundStyle(Color.convoyAccentFallback)
                        .padding(.bottom, 4)
                    
                    Text(page.title)
                        .font(.convoyLargeTitle)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                        .multilineTextAlignment(.center)
                } else {
                    Text(page.title)
                        .font(.convoyLargeTitle)
                        .foregroundStyle(Color.convoyTextPrimaryFallback)
                        .multilineTextAlignment(.center)
                    
                    Text(page.subtitle)
                        .font(.convoyBody)
                        .foregroundStyle(Color.convoyTextSecondaryFallback)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ConvoyTheme.Spacing.xl)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, ConvoyTheme.Spacing.xl)
        .onChange(of: isActive) { _, newValue in
            if newValue {
                symbolsAnimated = false
                withAnimation { symbolsAnimated = true }
            }
        }
        .onAppear {
            if isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { symbolsAnimated = true }
                }
            }
        }
    }
    
    private func symbolOffset(index: Int) -> CGSize {
        let angle = (Double(index) / Double(max(1, page.symbols.count))) * .pi * 2 - .pi / 2
        let radius: CGFloat = 72
        return CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius
        )
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
