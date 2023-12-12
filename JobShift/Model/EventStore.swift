import Foundation
import GoogleAPIClientForREST

final class EventStore {
    static let shared: EventStore = .init()
    private var events: [GTLRCalendar_Event] = []
    private let calManager = GoogleCalendarManager.shared
    private init () {}
    
    func addEvents(events: [GTLRCalendar_Event]) {
        self.events.append(contentsOf: events)
    }
    
    func getEvents() -> [GTLRCalendar_Event] {
        return self.events
    }
    
    func addEvent(event: GTLRCalendar_Event, toCalendarId calId: String, completion: @escaping (_ success: Bool) -> Void) {
        calManager.addEvent(toCalendarId: calId, event: event) { success in
            if success {
                self.events.append(event)
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
    
    func getEventsFromDate(dateComponents: DateComponents) -> [GTLRCalendar_Event] {
        guard let targetDate = Calendar.current.date(from: dateComponents) else {
            return []
        }
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        let filteredEvents = events.filter { event in
            if let startDate = event.start?.dateTime?.date, let endDate = event.end?.dateTime?.date {
                return startOfDay >= Calendar.current.startOfDay(for: startDate) && startOfDay <= Calendar.current.startOfDay(for: endDate)
            }
            return false
        }
        return filteredEvents
    }
    
    func clearCalendarStore() {
        self.events = []
    }
}
