import SwiftUI

// MARK: - Tab Router

/// Router that manages active tab selection, badges, and deep-link routing.
@MainActor
@Observable
final class TabRouter {
    var selectedTab: ConvoyTab = .home
    
    // Badge counts
    var ridesBadgeCount: Int = 0
    var friendsBadgeCount: Int = 0
    var clubsBadgeCount: Int = 0
    
    func switchTo(_ tab: ConvoyTab) {
        selectedTab = tab
        HapticManager.shared.tabSelection()
    }
    
    func handleDeepLink(url: URL) -> Bool {
        guard let host = url.host else { return false }
        
        switch host {
        case "rides":
            switchTo(.rides)
            return true
        case "clubs":
            switchTo(.clubs)
            return true
        case "friends":
            switchTo(.friends)
            return true
        case "profile":
            switchTo(.profile)
            return true
        case "home":
            switchTo(.home)
            return true
        default:
            return false
        }
    }
}
