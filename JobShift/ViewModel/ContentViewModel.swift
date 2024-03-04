import Observation

@Observable final class ContentViewModel {
    var showCalendarSheet: Bool = true
    var selectedTab: Tab = .shift {
        didSet {
            showCalendarSheet = selectedTab == .shift
        }
    }
    var showOnBoardingSheet: Bool = false
}
