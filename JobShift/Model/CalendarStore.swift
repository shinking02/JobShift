import Foundation
import GoogleAPIClientForREST

final class CalendarStore {
    static let shared: CalendarStore = .init()
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
}
