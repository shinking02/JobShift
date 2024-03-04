import Observation

@Observable final class CalendarSettingViewModel {
    var appState = AppState.shared
    var calendars = AppState.shared.userCalendars
    func setActiveCalendar(_ calendar: UserCalendar) {
        appState.userCalendars = appState.userCalendars.map { item in
            let item = item
            if item.id == calendar.id {
                item.isActive.toggle()
            }
            return item
        }
    }
    func onDisappear() {
        appState.userCalendars = calendars
    }
}
