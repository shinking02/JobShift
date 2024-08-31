import GoogleAPIClientForREST_Calendar
import Foundation
import RealmSwift


// Realmとの同期処理や予定の変更などのアプリ内のカレンダー処理の全てを行う。
// このクラス以外でのDBの更新やGoogle Calendar APIの使用を禁止する
@Observable
final class CalendarManager {
    static let shared: CalendarManager = .init()
    
    private(set) var isShowOnlyJobEvent = false
    private(set) var defaultCalendar: UserCalendar = .init(id: "", summary: "")
    private let service = GTLRCalendarService()
    private(set) var calendars: [UserCalendar]

    private init() {
        calendars = []
        service.authorizer = AppState.shared.user?.fetcherAuthorizer
        service.shouldFetchNextPages = true
        isShowOnlyJobEvent = Storage.getIsShowOnlyJobEvent()
    }
    
    private func syncCalendarList() async {
        let fetchCalendarsQuery = GTLRCalendarQuery_CalendarListList.query()
        await withCheckedContinuation { continuation in
            service.executeQuery(fetchCalendarsQuery) { ticket, response, error in
                if let error {
                    print("CalendarManagerError: \(error.localizedDescription)")
                    continuation.resume()
                }
                self.calendars = ((response as! GTLRCalendar_CalendarList).items ?? []).map { item in
                    UserCalendar(id: item.identifier!, summary: item.summary!)
                }
                continuation.resume()
            }
        }
        setDefaultCalendar(calendars.first { $0.id == Storage.getDefaultCalendarId() } ?? calendars.first!)
    }
    
    private func syncEvents(calendarId: String) async {
        let syncToken = Storage.getGoogleSyncToken(for: calendarId)
        let fetchEventsQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        fetchEventsQuery.singleEvents = true
        fetchEventsQuery.syncToken = syncToken
        
        await withCheckedContinuation { continuation in
            service.executeQuery(fetchEventsQuery) { ticket, response, error in
                // 410 = invalid sync token
                if ticket.statusCode == 410 {
                    Storage.setGoogleSyncToken(for: calendarId, token: "")
                    Task { await self.syncEvents(calendarId: calendarId) }
                    continuation.resume()
                    return
                }

                if let error = error {
                    print("CalendarManagerError: \(error.localizedDescription)")
                    continuation.resume()
                    return
                }
                
                guard let events = (response as? GTLRCalendar_Events)?.items else {
                    continuation.resume()
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                DispatchQueue.global(qos: .utility).async {
                    do {
                        let realm = try Realm()
                        for googleEvent in events {
                            dispatchGroup.enter()
                            if googleEvent.status == "cancelled" {
                                let deleteTarget = realm.objects(Event.self).filter("id == %@", googleEvent.identifier!)
                                try realm.write {
                                    realm.delete(deleteTarget)
                                }
                            } else {
                                let realmEvent = Event()
                                let isAllDay = googleEvent.start?.dateTime == nil
                                realmEvent.id = googleEvent.identifier ?? ""
                                realmEvent.summary = googleEvent.summary ?? ""
                                realmEvent.calendarId = calendarId
                                realmEvent.isAllDay = isAllDay
                                realmEvent.start = googleEvent.start?.dateTime?.date ?? googleEvent.start?.date?.date ?? Date()
                                realmEvent.end = googleEvent.end?.dateTime?.date ?? googleEvent.end?.date?.date ?? Date()
                                
                                try realm.write {
                                    realm.add(realmEvent, update: .modified)
                                }
                            }
                            dispatchGroup.leave()
                        }
                        
                        dispatchGroup.notify(queue: .global(qos: .utility)) {
                            let nextSyncToken = (response as? GTLRCalendar_Events)?.nextSyncToken ?? ""
                            Storage.setGoogleSyncToken(for: calendarId, token: nextSyncToken)
                            continuation.resume()
                        }
                    } catch {
                        print("CalendarManagerError: \(error.localizedDescription)")
                        dispatchGroup.notify(queue: .global(qos: .utility)) {
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
    
    func setIsShowOnlyJobEvents(_ isShowOnlyJobEvents: Bool) {
        self.isShowOnlyJobEvent = isShowOnlyJobEvents
        Storage.setIsShowOnlyJobEvent(isShowOnlyJobEvents)
    }
    
    func setDefaultCalendar(_ calendar: UserCalendar) {
        self.defaultCalendar = calendar
        Storage.setDefaultCalendarId(calendar.id)
    }

    func syncGoogleCalendar(skipSyncCalendarList: Bool) async {
        if !skipSyncCalendarList {
            await syncCalendarList()
        }
        await withTaskGroup(of: Void.self) { group in
            for calendar in calendars {
                group.addTask {
                    await self.syncEvents(calendarId: calendar.id)
                }
            }
        }
    }
    
    func addEvent(summary: String, startDate: Date, endDate: Date, isAllDay: Bool, calendarId: String) async {
        let googleEvent = GTLRCalendar_Event()
        let gtlrStart = isAllDay ? GTLRDateTime(forAllDayWith: startDate) : GTLRDateTime(date: startDate)
        let gtlrEnd = isAllDay ? GTLRDateTime(forAllDayWith: endDate) : GTLRDateTime(date: endDate)
        let eventStart = GTLRCalendar_EventDateTime()
        let eventEnd = GTLRCalendar_EventDateTime()
        
        if isAllDay {
            eventStart.date = gtlrStart
            eventEnd.date = gtlrEnd
        } else {
            eventStart.dateTime = gtlrStart
            eventEnd.dateTime = gtlrEnd
        }
        
        googleEvent.start = eventStart
        googleEvent.end = eventEnd
        googleEvent.summary = summary
        
        let eventInsertQuery = GTLRCalendarQuery_EventsInsert.query(withObject: googleEvent, calendarId: calendarId)
        await withCheckedContinuation { continuation in
            service.executeQuery(eventInsertQuery) { ticket, response, error in
                if let error {
                    print("CalendarManagerError: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
        await self.syncGoogleCalendar(skipSyncCalendarList: true)
    }
    
    func editEvent(event: Event, beforeCalendarId: String) async {
        let googleEvent = GTLRCalendar_Event()
        let gtlrStart = event.isAllDay ? GTLRDateTime(forAllDayWith: event.start) : GTLRDateTime(date: event.start)
        let gtlrEnd = event.isAllDay ? GTLRDateTime(forAllDayWith: event.end) : GTLRDateTime(date: event.end)
        let eventStart = GTLRCalendar_EventDateTime()
        let eventEnd = GTLRCalendar_EventDateTime()
        
        if event.isAllDay {
            eventStart.date = gtlrStart
            eventEnd.date = gtlrEnd
        } else {
            eventStart.dateTime = gtlrStart
            eventEnd.dateTime = gtlrEnd
        }
        
        googleEvent.identifier = event.id
        googleEvent.start = eventStart
        googleEvent.end = eventEnd
        googleEvent.summary = event.summary
        
        let eventUpdateQuery = GTLRCalendarQuery_EventsUpdate.query(withObject: googleEvent, calendarId: beforeCalendarId, eventId: event.id)
        await withCheckedContinuation { continuation in
            service.executeQuery(eventUpdateQuery) { ticket, response, error in
                if let error {
                    print("CalendarManagerError: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
        if event.calendarId != beforeCalendarId {
            let eventMoveQuery = GTLRCalendarQuery_EventsMove.query(withCalendarId: beforeCalendarId, eventId: event.id, destination: event.calendarId)
            await withCheckedContinuation { continuation in
                service.executeQuery(eventMoveQuery) { ticket, response, error in
                    if let error {
                        print("CalendarManagerError: \(error.localizedDescription)")
                    }
                    continuation.resume()
                }
            }
        }
        await self.syncGoogleCalendar(skipSyncCalendarList: true)
    }
    
    func deleteEvent(eventId: String, calendarId: String) async {
        let eventDeleteQuery = GTLRCalendarQuery_EventsDelete.query(withCalendarId: calendarId, eventId: eventId)
        await withCheckedContinuation { continuation in
            service.executeQuery(eventDeleteQuery) { ticket, response, error in
                if let error {
                    print("CalendarManagerError: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
        await self.syncGoogleCalendar(skipSyncCalendarList: true)
    }
}
