import Observation
import RealmSwift
import GoogleAPIClientForREST

class Event: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var calendarId: String
    @Persisted var summary: String
    @Persisted var isAllDay: Bool
    @Persisted var start: Date
    @Persisted var end: Date
}

@Observable final class EventStore {
    static let shared: EventStore = .init()
    private var notificationTokens: [NotificationToken] = []
    private let appState = AppState.shared
    
    
    func addEvent(_ event: Event) {
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(event)
            }
        } catch {
            print("Error adding event: \(error)")
        }
    }

    func syncEvent(_ gtlrEvent: GTLRCalendar_Event, _ calendarId: String) {
        let realm = try! Realm()
        // Delete existing event if any
        let existingEvent = realm.objects(Event.self).filter("id = %@", gtlrEvent.identifier!).first
        if let existingEvent = existingEvent {
            try! realm.write {
                realm.delete(existingEvent)
            }
        }
        // Add new event
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
        let realm = try! Realm()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let dateStart = calendar.date(from: dateComponents)!
        let dateEnd = calendar.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: dateStart)!
        let activeCalendarIds = appState.userCalendars.filter { $0.isActive }.map { $0.id }
        let jobNames = SwiftDataSource.shared.fetchJobs().map { $0.name }
        let filterRule = {
            if appState.isShowOnlyJobEvent {
                return "calendarId IN %@ AND (start <= %@ AND start >= %@ OR end <= %@ AND end >= %@ OR start <= %@ AND end >= %@) AND summary IN %@"
            }
            return "calendarId IN %@ AND (start <= %@ AND start >= %@ OR end <= %@ AND end >= %@ OR start <= %@ AND end >= %@)"
        }()
        let events = realm.objects(Event.self)
            .filter(filterRule, activeCalendarIds, dateEnd, dateStart, dateEnd, dateStart, dateStart, dateEnd, jobNames)
            .sorted(byKeyPath: "start", ascending: true)
        return events;
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