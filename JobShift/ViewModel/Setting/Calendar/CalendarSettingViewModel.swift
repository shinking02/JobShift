import Foundation

class CalendarSettingViewModel: ObservableObject {
    @Published var allCalendars: [UserCalendar] = []
    @Published var selectedCalendars: Set<UserCalendar> = []
    @Published var showOnlyJobEvent: Bool = false
    
    init() {
        allCalendars = UserDefaultsData.shared.getAllCalendars()
        selectedCalendars = Set(UserDefaultsData.shared.getActiveCalendars())
        showOnlyJobEvent = UserDefaultsData.shared.getShowOnlyJobEventSetting()
    }
    
    func toggleCalendarSelection(_ calendar: UserCalendar) {
        if selectedCalendars.contains(calendar) {
            selectedCalendars.remove(calendar)
        } else {
            selectedCalendars.insert(calendar)
        }
        UserDefaultsData.shared.setActiveCalendars(Array(selectedCalendars))
    }
    
    func updateShowOnlyJobEventSetting() {
        UserDefaultsData.shared.setShowOnlyJobEventSetting(showOnlyJobEvent)
    }
}
