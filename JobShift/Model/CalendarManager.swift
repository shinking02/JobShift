import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

enum CalendarManagerError: Error {
    case errorWithText(text: String)
}

final class CalendarManager {
    static let shared: CalendarManager = .init()
    private init() {}
    
    private let service = GTLRCalendarService()
    private let appState = AppState.shared
    private let eventStore = EventStore.shared
    private let userDefaultsData = UserDefaultsData.shared
    private var syncTokens: [String: String] = [:]
    
    func setUser (_ user: GIDGoogleUser) {
        self.service.authorizer = user.fetcherAuthorizer
        self.service.shouldFetchNextPages = true
    }
    
    func getUserCalendarIds() async -> [String] {
        await withCheckedContinuation { continuation in
            let query = GTLRCalendarQuery_CalendarListList.query()
            self.service.executeQuery(query) { (ticket, response, error) in
                do {
                    if let error = error {
                        throw CalendarManagerError.errorWithText(text: "Error while executing calendar list query '\(error.localizedDescription)'")
                    }
                    guard let calendarList = response as? GTLRCalendar_CalendarList, let items = calendarList.items else {
                        throw CalendarManagerError.errorWithText(text: "Error while parsing calendar list response")
                    }
                    let calendarIds = items.compactMap { $0.identifier }
                    continuation.resume(returning: calendarIds)
                } catch {
                    print("GoogleCalendarManager - getUserCalendarIds - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sync() async {
        let calendarIds = userDefaultsData.getActiveCalIds()
        syncTokens = userDefaultsData.getGoogleSyncTokens()

        await withCheckedContinuation { continuation in
            Task {
                await withTaskGroup(of: Void.self) { taskGroup in
                    for calendarId in calendarIds {
                        taskGroup.addTask {
                            await self.syncCalendar(calendarId)
                        }
                    }
                    await taskGroup.waitForAll()
                    self.userDefaultsData.setGoogleSyncTokens(self.syncTokens)
                    continuation.resume()
                }
            }
        }
    }
    
    func syncCalendar(_ calendarId: String) async {
        let eventsQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        let syncToken = syncTokens[calendarId] ?? ""
        eventsQuery.singleEvents = true
        eventsQuery.syncToken = syncToken
        
        await withCheckedContinuation { continuation in
            self.service.executeQuery(eventsQuery) { (ticket, response, error) in
                do {
                    if let error = error {
                        if ticket.statusCode == 410 {
                            // 410 = invalid sync token
                            self.syncTokens[calendarId] = ""
                            self.eventStore.deleteEventForCalendar(calendarId)
                            Task {
                                await self.syncCalendar(calendarId)
                            }
                        } else {
                            throw CalendarManagerError.errorWithText(text: "Error while executing events list query '\(error.localizedDescription)'")
                        }
                    }
                    let items = (response as? GTLRCalendar_Events)?.items ?? []
                    items.forEach { event in
                        DispatchQueue.global(qos: .utility).async {
                            if event.status == "cancelled" {
                                self.eventStore.deleteEvent(event.identifier!)
                            } else {
                                self.eventStore.addEvent(event, calendarId)
                            }
                        }
                    }
                    self.syncTokens[calendarId] = (response as? GTLRCalendar_Events)?.nextSyncToken ?? ""
                    continuation.resume()
                } catch {
                    print("GoogleCalendarManager - syncCalendar - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func clear() {
        eventStore.clear()
    }
    
    func addEvent(_ event: Event) {
        
    }
    
    func deleteEvent(_ id: String) {
        
    }
    
    func updateEvent(_ event: Event) {
        
    }
}

