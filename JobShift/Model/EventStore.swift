import Foundation
import GoogleAPIClientForREST

class EventStore: ObservableObject {
    @Published var events: [GTLRCalendar_Event] = []

    private let calManager = GoogleCalendarManager.shared
    
    func addEvents(events: [GTLRCalendar_Event]) {
        self.events.append(contentsOf: events)
        self.sortEventsByStartDate()
    }
    
    func getEvents() -> [GTLRCalendar_Event] {
        return self.events
    }
    
    func clearCalendarStore() {
        self.events = []
    }
    
    func addEvent(event: GTLRCalendar_Event, toCalendarId calId: String, completion: @escaping (_ success: Bool) -> Void) {
        calManager.addEvent(toCalendarId: calId, event: event) { success in
            if success {
                self.events.append(event)
                self.sortEventsByStartDate()
            }
            completion(success)
        }
    }
    
    func deleteEvent(eventId: String, fromCalendarId calId: String, completion: @escaping (_ success: Bool) -> Void) {
        calManager.deleteEvent(fromCalendarId: calId, eventId: eventId) { success in
            if success {
                self.events = self.events.filter { $0.identifier != eventId }
            }
            completion(success)
        }
    }
    
    func updateEventStore(calendars: [GTLRCalendar_CalendarListEntry], completion: @escaping (_ success: Bool) -> Void) {
        var newEvents: [GTLRCalendar_Event] = []
        let dispatchGroup = DispatchGroup()
        calendars.forEach { calendar in
            dispatchGroup.enter()
            guard let id = calendar.identifier else { return }
            calManager.fetchEventsFromCalendarId(calId: id) { events in
                if let events = events {
                    newEvents += events
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.clearCalendarStore()
            self.addEvents(events: newEvents)
            completion(true)
        }
    }
    
    private func sortEventsByStartDate() {
        self.events = events.sorted { event1, event2 in
            guard let start1 = event1.start?.dateTime?.date ?? event1.start?.date?.date,
                  let start2 = event2.start?.dateTime?.date ?? event2.start?.date?.date else {
                return false
            }
            return start1 < start2
        }
    }
}
