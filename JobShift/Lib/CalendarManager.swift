import Foundation
import RealmSwift
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
        service.shouldFetchNextPages = true
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
    
    private func createRealmEvent(gtEvent: GTLRCalendar_Event, calendarId: String) -> Event {
        let event = Event()
        let isAllDay = gtEvent.start?.dateTime == nil
        let start = {
           if isAllDay {
               let date = gtEvent.start?.date?.date ?? Date()
               return date.fixed(hour: 0, minute: 0, second: 0)
           } else {
               return gtEvent.start?.dateTime?.date ?? Date()
           }
        }()
        let end = {
            if isAllDay {
                let date = gtEvent.end?.date?.date ?? Date()
                return date.added(day: -1).fixed(hour: 23, minute: 59, second: 59)
            } else {
                return gtEvent.end?.dateTime?.date ?? Date()
            }
        }()
        event.id = gtEvent.identifier ?? ""
        event.calendarId = calendarId
        event.summary = gtEvent.summary ?? ""
        event.start = start
        event.end = end
        event.isAllDay = isAllDay
        return event
    }
    
    func syncEvents(calendarId: String) async {
        let syncToken = Storage.getGoogleSyncToken(for: calendarId)
        let eventsQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        eventsQuery.singleEvents = true
        eventsQuery.syncToken = syncToken
        
        await withCheckedContinuation { continuation in
            service.executeQuery(eventsQuery) { ticket, response, error in
                // 410 = invalid sync token
                if ticket.statusCode == 410 {
                    Storage.setGoogleSyncToken(for: calendarId, token: "")
                    Task { await self.syncEvents(calendarId: calendarId) }
                    continuation.resume()
                }
                let events = (response as? GTLRCalendar_Events)?.items ?? []
                DispatchQueue.global(qos: .utility).async {
                    // swiftlint:disable:next force_try
                    let realm = try! Realm()
                    events.forEach { gtEvent in
                        do {
                            if gtEvent.status == "cancelled" {
                                let deleteTarget = realm.objects(Event.self).filter("id == %@", gtEvent.identifier ?? "")
                                try realm.write {
                                    realm.delete(deleteTarget)
                                }
                                return
                            }
                            let event = self.createRealmEvent(gtEvent: gtEvent, calendarId: calendarId)
                            try realm.write {
                                realm.add(event, update: .modified)
                            }
                        } catch {
                            print("ERROR: \(error.localizedDescription)")
                        }
                    }
                }
                Storage.setGoogleSyncToken(for: calendarId, token: (response as? GTLRCalendar_Events)?.nextSyncToken ?? "")
                continuation.resume()
            }
        }
    }
    
    func syncAllEvents() async {
        await setCalendars()
        await withTaskGroup(of: Void.self) { group in
            for calendar in calendars {
                group.addTask {
                    await self.syncEvents(calendarId: calendar.id)
                }
            }
        }
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
