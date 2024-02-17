import Foundation
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

final class EventStore {
    static let shared: EventStore = .init()
    private init() {}
    
    func addEvent(_ event: Event) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(event)
        }
    }

    func addEvent(_ event: GTLRCalendar_Event, _ calendarId: String) {
        let realm = try! Realm()
        let newEvent = Event()
        newEvent.id = event.identifier!
        newEvent.calendarId = calendarId
        newEvent.summary = event.summary ?? ""
        newEvent.isAllDay =  event.start?.date?.date != nil
        newEvent.start = event.start?.date?.date ?? event.start?.dateTime?.date ?? Date.distantPast
        newEvent.end = event.end?.date?.date ?? event.end?.dateTime?.date ?? Date.distantFuture
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
}
