import Observation

@Observable final class ContentViewModel {
    var showCalendarSheet: Bool = false
    var selectedTab: Tab = .shift {
        didSet {
            showCalendarSheet = selectedTab == .shift
        }
    }
    var showOnBoardingSheet: Bool = false
    func onAppear() {
        Task {
            // Wait a bit before displaying the sheet or it will appear before TabView.
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if selectedTab == .shift {
                showCalendarSheet = true
            }
        }
    }
}
