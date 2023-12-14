import Foundation
import GoogleAPIClientForREST

class EventStoreVM: ObservableObject {
    @Published var eventStore: EventStore
    
    init(eventStore: EventStore = EventStore.shared) {
        self.eventStore = eventStore
    }
    
    var events: [GTLRCalendar_Event] {
        return eventStore.getEvents()
    }
    
    func addEvents(events: [GTLRCalendar_Event]) {
        self.eventStore.addEvents(events: events)
    }
    
    func addEvent(event: GTLRCalendar_Event, toCalendarId calId: String, completion: @escaping (_ success: Bool) -> Void) {
        eventStore.addEvent(event: event, toCalendarId: calId) { success in
            completion(success)
        }
    }
    
    func deleteEvent(eventId: String, fromCalendarId calId: String, completion: @escaping (_ success: Bool) -> Void) {
        eventStore.deleteEvent(eventId: eventId, fromCalendarId: calId) { success in
            completion(success)
        }
    }
    
    func getEventsFromDate(dateComponents: DateComponents) -> [GTLRCalendar_Event] {
        return eventStore.getEventsFromDate(dateComponents: dateComponents)
    }
}
