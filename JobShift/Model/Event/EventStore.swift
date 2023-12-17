import Foundation
import GoogleAPIClientForREST

class EventStore: ObservableObject {
    @Published var events: [Event] = []
    
    private let calManager = GoogleCalendarManager.shared
    
    func addEvents(events: [Event]) {
        self.events.append(contentsOf: events)
        self.sortEventsByStartDate()
    }
    
    func getEvents() -> [Event] {
        return self.events
    }
    
    func clearCalendarStore() {
        self.events = []
    }
    
    func addEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        calManager.addEvent(toCalendarId: event.calId, event: event.gEvent) { success in
            if success {
                self.events.append(event)
                self.sortEventsByStartDate()
            }
            completion(success)
        }
    }
    
    func deleteEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        calManager.deleteEvent(fromCalendarId: event.calId, eventId: event.gEvent.identifier ?? "") { success in
            if success {
                self.events = self.events.filter { $0.gEvent.identifier != event.gEvent.identifier }
            }
            completion(success)
        }
    }
    
    func deleteNormalEvents(jobs: [Job]) {
        let jobNames = jobs.map { $0.name }
        self.events = self.events.filter { jobNames.contains($0.gEvent.summary ?? "") }
    }
    
    func updateEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        calManager.updateEvent(inCalendarId: event.calId, updatedEvent: event.gEvent) { success in
            self.events = self.events.filter { $0.gEvent.identifier != event.gEvent.identifier }
            self.events.append(event)
            self.sortEventsByStartDate()
        }
    }
    
    func deleteCalendarFromStore(calendars: [GTLRCalendar_CalendarListEntry]) {
        self.events.removeAll { event in
            calendars.contains { cal in
                event.calId == cal.identifier
            }
        }
    }
    
    func updateCalendarForStore(calendars: [GTLRCalendar_CalendarListEntry], completion: @escaping (_ success: Bool) -> Void) {
        deleteCalendarFromStore(calendars: calendars)
        var newEvents: [Event] = []
        let dispatchGroup = DispatchGroup()
        calendars.forEach { calendar in
            guard let id = calendar.identifier else { return }
            dispatchGroup.enter()
            calManager.fetchEventsFromCalendarId(calId: id) { events in
                if let events = events {
                    newEvents += events.map { gEvent in
                        return Event(calId: id, gEvent: gEvent)
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.addEvents(events: newEvents)
            completion(true)
        }
    }
    
    private func sortEventsByStartDate() {
        self.events = events.sorted { event1, event2 in
            guard let start1 = event1.gEvent.start?.dateTime?.date ?? event1.gEvent.start?.date?.date,
                  let start2 = event2.gEvent.start?.dateTime?.date ?? event2.gEvent.start?.date?.date else {
                return false
            }
            return start1 < start2
        }
    }
}

struct Event: Hashable {
    let id: UUID = UUID()
    var calId: String
    var gEvent: GTLRCalendar_Event
}
