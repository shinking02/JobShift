import Foundation
import GoogleAPIClientForREST_Calendar

final class CalendarManager {
    static let shared: CalendarManager = .init()

    private let service = GTLRCalendarService()
    private(set) var calendars: [UserCalendar]
    private(set) var defaultCalendar: UserCalendar
    private(set) var isShowOnlyJobEvent: Bool
    
    private init() {
        calendars = []
        service.authorizer = AppState.shared.user?.fetcherAuthorizer
        isShowOnlyJobEvent = Storage.getIsShowOnlyJobEvent()
        defaultCalendar = UserCalendar(id: "", summary: "")
    }
    
    private func setCalendars() async {
        await withCheckedContinuation { continuation in
            let query = GTLRCalendarQuery_CalendarListList.query()
            service.executeQuery(query) { ticket, response, error in
                if error != nil {
                    print("ERROR: \(error!.localizedDescription)")
                    continuation.resume()
                }
                let calendarList = response as! GTLRCalendar_CalendarList
                self.calendars = (calendarList.items ?? []).map { calendar in
                    return UserCalendar(
                        id: calendar.identifier!,
                        summary: calendar.summary!
                    )
                }
                let defaultCalendarId = Storage.getDefaultCalendarId()
                self.defaultCalendar = self.calendars.first { $0.id == defaultCalendarId } ?? self.calendars.first!
                continuation.resume()
            }
        }
    }
    
    func syncFromGoogleCalendar() async {
        await setCalendars()
    }
    
    func setDefaultCalendar(_ calendar: UserCalendar) {
        Storage.setDefaultCalendarId(calendar.id)
        defaultCalendar = calendar
    }
    
    func setIsShowOnlyJobEvent(_ value: Bool) {
        isShowOnlyJobEvent = value
        Storage.setIsShowOnlyJobEvent(isShowOnlyJobEvent)
    }
}
