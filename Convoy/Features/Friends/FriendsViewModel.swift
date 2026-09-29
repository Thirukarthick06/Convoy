import SwiftUI
import SwiftData

// MARK: - Friends View Model

@MainActor
@Observable
final class FriendsViewModel {
    var searchText: String = ""
    var showAddFriend: Bool = false
    var showQRShare: Bool = false
    
    func filterFriends(_ friends: [Friend]) -> [Friend] {
        friends.filter { friend in
            if !searchText.isEmpty {
                let matchesName = friend.name.localizedCaseInsensitiveContains(searchText)
                let matchesUser = friend.username.localizedCaseInsensitiveContains(searchText)
                if !matchesName && !matchesUser { return false }
            }
            return true
        }
    }
    
    func addFriend(name: String, username: String, motorcycle: String?, context: ModelContext) {
        let friend = Friend(
            name: name,
            username: username.isEmpty ? name.lowercased().replacingOccurrences(of: " ", with: ".") : username,
            motorcycle: motorcycle
        )
        context.insert(friend)
        try? context.save()
        HapticManager.shared.success()
    }
}
