import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

enum GoogleCalendarManagerError: Error {
    case errorWithText(text: String)
}


final class GoogleCalendarManager {
    static let shared: GoogleCalendarManager = .init()
    private let service = GTLRCalendarService()
    private init() {}
    
    func setUser (user: GIDGoogleUser) {
        self.service.authorizer = user.fetcherAuthorizer
        self.service.shouldFetchNextPages = true
    }
    func fetchCalendarIds(completion: @escaping (_ calendars: [GTLRCalendar_CalendarListEntry]) -> Void) {
        let calendarListQuery = GTLRCalendarQuery_CalendarListList.query()
        service.executeQuery(calendarListQuery) { (ticket, response, error) in
            do {
                if let error = error {
                    throw GoogleCalendarManagerError.errorWithText(text: error.localizedDescription)
                }
                
                guard let calendarEntryesResponse = response as? GTLRCalendar_CalendarList else {
                    completion([])
                    return
                }
                
                guard let entryList = calendarEntryesResponse.items, !entryList.isEmpty else {
                    completion([])
                    return
                }
                completion(entryList)
            } catch {
                print(error)
                print("GoogleCalendarManager - checkCalendar - error: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    func fetchEventsFromCalendarId(calId: String, completion: @escaping (_ events: [GTLRCalendar_Event]?) -> Void) {
        let eventsQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calId)
        eventsQuery.singleEvents = true
        service.executeQuery(eventsQuery) { (ticket, response, error) in
            do {
                if let error = error {
                    throw GoogleCalendarManagerError.errorWithText(text: "Error while executing events query '\(error.localizedDescription)'")
                }
                guard let eventsList = response as? GTLRCalendar_Events else {
                    throw GoogleCalendarManagerError.errorWithText(text: "Cannot cast response to GTLRCalendar_Events")
                }
                guard let events = eventsList.items else {
                    throw GoogleCalendarManagerError.errorWithText(text: "No events fetched")
                }
                completion(events)
            } catch {
                print("GoogleCalendarManager - fetchEventsFromCalendarId - \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func addEvent(toCalendarId calId: String, event: GTLRCalendar_Event, completion: @escaping (_ success: Bool) -> Void) {
        let insertEvent = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: calId)
        
        service.executeQuery(insertEvent) { (ticket, response, error) in
            do {
                if let error = error {
                    throw GoogleCalendarManagerError.errorWithText(text: "Error while inserting event '\(error.localizedDescription)'")
                }
                
                completion(true)
            } catch {
                print(error)
                print("GoogleCalendarManager - addEvent - \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func deleteEvent(fromCalendarId calId: String, eventId: String, completion: @escaping (_ success: Bool) -> Void) {
        let deleteEvent = GTLRCalendarQuery_EventsDelete.query(withCalendarId: calId, eventId: eventId)
        
        service.executeQuery(deleteEvent) { (ticket, response, error) in
            do {
                if let error = error {
                    throw GoogleCalendarManagerError.errorWithText(text: "Error while deleting event '\(error.localizedDescription)'")
                }
                
                completion(true)
            } catch {
                print(error)
                print("GoogleCalendarManager - deleteEvent - \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func updateEvent(inCalendarId calId: String, updatedEvent: GTLRCalendar_Event, completion: @escaping (_ success: Bool) -> Void) {
        guard let eventId = updatedEvent.identifier else { return }
        let updateEvent = GTLRCalendarQuery_EventsUpdate.query(withObject: updatedEvent, calendarId: calId, eventId: eventId)
        service.executeQuery(updateEvent) { (ticket, response, error) in
            do {
                if let error = error {
                    throw GoogleCalendarManagerError.errorWithText(text: "Error while updating event '\(error.localizedDescription)'")
                }
                completion(true)
            } catch {
                print(error)
                print("GoogleCalendarManager - updateEvent - \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
