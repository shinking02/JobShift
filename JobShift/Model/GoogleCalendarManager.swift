import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

enum GoogleCalendarManagerError: Error {
    case errorWithText(text: String)
}


final class GoogleCalendarManager {
    private let service = GTLRCalendarService()
    private var calendarIds: [String] = []
    
    init() {
        let currentUser = GIDSignIn.sharedInstance.currentUser
        if let user = currentUser {
            service.authorizer = user.fetcherAuthorizer
            service.shouldFetchNextPages = true
        }
    }
    
    func fetchCalendarIds(completion: @escaping (_ calendarIds: [String]) -> Void) {
        let calendarList = GTLRCalendarQuery_CalendarListList.query()
        service.executeQuery(calendarList) { (ticket, response, error) in
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
                
                self.calendarIds = entryList.compactMap { $0.identifier }
                completion(self.calendarIds)
            } catch {
                print(error)
                print("GoogleCalendarManager - checkCalendar - error: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    func fetchEventsFromCalendarId(calId: String, completion: @escaping (_ calendarEvents: [GTLRCalendar_Event]?) -> Void) {
        let eventsQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calId)
        
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
                print(error)
                print("GoogleCalendarManager - fetchEventsFromCalendarId - \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
