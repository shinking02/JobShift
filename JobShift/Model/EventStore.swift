// swiftlint:disable force_try

import GoogleAPIClientForREST_Calendar
import RealmSwift

class Event: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var calendarId: String
    @Persisted var summary: String
    @Persisted var isAllDay: Bool
    @Persisted var start: Date
    @Persisted var end: Date
    static func all() -> Results<Event> {
        let realm = try! Realm()
        return realm.objects(Event.self)
    }
}

@Observable final class EventStore {
    static let shared: EventStore = .init()
    private let appState = AppState.shared
    private init() {}
    
    func addEvent(_ event: Event) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(event)
        }
    }

    func syncEvent(_ gtlrEvent: GTLRCalendar_Event, _ calendarId: String) {
        let realm = try! Realm()
        let existingEvent = realm.objects(Event.self).filter("id = %@", gtlrEvent.identifier!).first
        if let existingEvent = existingEvent {
            try! realm.write {
                realm.delete(existingEvent)
            }
        }
        let newEvent = createEvent(gtlrEvent, calendarId)
        try! realm.write {
            realm.add(newEvent)
        }
    }
    
    func deleteEvent(_ id: String) {
        let realm = try! Realm()
        let target = realm.object(ofType: Event.self, forPrimaryKey: id)
        if let target = target {
            try! realm.write {
                realm.delete(target)
            }
        }
    }
    
    func deleteEventForCalendar(_ calendarId: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Event.self).filter("calendarId == %@", calendarId))
        }
    }

    func clear() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Event.self))
        }
    }
    
    func getEvent(_ id: String) -> Event? {
        let realm = try! Realm()
        return realm.object(ofType: Event.self, forPrimaryKey: id)
    }
    
    // return all events that intersect with the given date
    func getEvents(_ date: Date) -> Results<Event> {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let dateStart = calendar.date(from: dateComponents)!
        let dateEnd = calendar.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: dateStart)!
        let activeCalendarIds = appState.userCalendars.filter { $0.isActive }.map { $0.id }
        let jobNames = SwiftDataSource.shared.fetchJobs().map { $0.name }
        let filterRule = {
            if appState.isShowOnlyJobEvent {
                return """
                    calendarId IN %@ /
                    AND (start <= %@ AND start >= %@ OR end <= %@ AND end >= %@ OR start <= %@ AND end >= %@) /
                    AND summary IN %@
                """
            }
            return """
                calendarId IN %@ /
                AND (start <= %@ AND start >= %@ OR end <= %@ AND end >= %@ OR start <= %@ AND end >= %@)
            """
        }()
        let realm = try! Realm()
        let events = realm.objects(Event.self)
            .filter(
                filterRule,
                activeCalendarIds,
                dateEnd,
                dateStart,
                dateEnd,
                dateStart,
                dateStart,
                dateEnd,
                jobNames
            )
            .sorted(byKeyPath: "start", ascending: true)
        return events
    }
    
    func updateEvent(_ event: GTLRCalendar_Event) {
        let realm = try! Realm()
        let existingEvent = realm.objects(Event.self).filter("id = %@", event.identifier!).first
        if let existingEvent = existingEvent {
            try! realm.write {
                existingEvent.summary = event.summary ?? ""
                existingEvent.isAllDay = event.start?.date?.date != nil
                existingEvent.start = event.start?.date?.date ?? event.start?.dateTime?.date ?? Date.distantPast
                existingEvent.end = {
                    if existingEvent.isAllDay {
                        return Calendar.current.date(
                            byAdding: .day,
                            value: -1,
                            to: event.end?.date?.date ?? Date.distantFuture
                            )!
                    }
                    return event.end?.dateTime?.date ?? Date.distantFuture
                }()
            }
        }
    }
    
    func getJobEvents(interval: DateInterval, jobName: String) -> [Event] {
        let realm = try! Realm()
        let events = realm.objects(Event.self)
            .filter("start < %@ AND start >= %@ AND summary = %@", interval.end, interval.start, jobName)
            .sorted(byKeyPath: "start", ascending: true)
        return Array(events)
    }
    
    private func createEvent(_ event: GTLRCalendar_Event, _ calendarId: String) -> Event {
      let newEvent = Event()
      newEvent.id = event.identifier!
      newEvent.calendarId = calendarId
      newEvent.summary = event.summary ?? ""
      newEvent.isAllDay = event.start?.date?.date != nil
      newEvent.start = event.start?.date?.date ?? event.start?.dateTime?.date ?? Date.distantPast
      newEvent.end = {
        // If the event is all day, we need to subtract a day from the end date
        if newEvent.isAllDay {
          return Calendar.current.date(byAdding: .day, value: -1, to: event.end?.date?.date ?? Date.distantFuture)!
        }
        return event.end?.dateTime?.date ?? Date.distantFuture
      }()
      return newEvent
    }
}
// swiftlint:enable force_try
