import Foundation
import GoogleAPIClientForREST

final class EventStore {
    static let shared: EventStore = .init()
    private var events: [GTLRCalendar_Event] = []
    private let calManager = GoogleCalendarManager.shared
    private init () {}
    
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
    
    func getEventsFromDate(dateComponents: DateComponents) -> [GTLRCalendar_Event] {
        guard let targetStartDate = Calendar.current.date(from: dateComponents),
              let targetEndDate = Calendar.current.date(byAdding: .day, value: 1, to: targetStartDate) else {
            return []
        }
        let startIndex = binarySearch(events, targetStartDate, { $0.start?.dateTime?.date ?? $0.start?.date?.date ?? Date.distantFuture })
        let filteredEvents = events[startIndex..<events.endIndex].prefix { event in
            if let startDateTime = event.start?.dateTime?.date, let endDateTime = event.end?.dateTime?.date {
                return startDateTime < targetEndDate && endDateTime > targetStartDate
            } else if let startDate = event.start?.date?.date, let endDate = event.end?.date?.date {
                return startDate < targetEndDate && endDate > targetStartDate
            }
            return false
        }
        
        return Array(filteredEvents)
    }
    
    private func binarySearch<T>(_ array: [T], _ target: Date, _ key: (T) -> Date) -> Array<T>.Index {
        var low = array.startIndex
        var high = array.endIndex
        while low < high {
            let mid = low + (high - low) / 2
            if key(array[mid]) < target {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
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
