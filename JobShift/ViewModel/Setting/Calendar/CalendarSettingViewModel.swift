import Observation

@Observable final class CalendarSettingViewModel {
    var appState = AppState.shared
    var calendars = AppState.shared.userCalendars
    var defaultCalendar: UserCalendar = AppState.shared.defaultCalendar ?? AppState.shared.userCalendars.first!
    func setActiveCalendar(_ calendar: UserCalendar) {
        appState.userCalendars = appState.userCalendars.map { item in
            let item = item
            if item.id == calendar.id {
                item.isActive.toggle()
            }
            return item
        }
    }
    func onWillDisappear() {
        appState.userCalendars = calendars
        appState.defaultCalendar = defaultCalendar
    }
}
