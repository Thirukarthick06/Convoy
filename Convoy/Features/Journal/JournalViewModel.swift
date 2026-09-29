import SwiftUI
import SwiftData

// MARK: - Journal View Model

@MainActor
@Observable
final class JournalViewModel {
    var selectedJournal: RideJournal?
    var searchText: String = ""
    
    func filterJournals(_ journals: [RideJournal]) -> [RideJournal] {
        if searchText.isEmpty { return journals }
        return journals.filter {
            $0.rideTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.startLocation.localizedCaseInsensitiveContains(searchText) ||
            $0.endLocation.localizedCaseInsensitiveContains(searchText) ||
            $0.narrative.localizedCaseInsensitiveContains(searchText)
        }
    }
}
