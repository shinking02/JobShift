import GoogleAPIClientForREST
import GoogleSignIn
import RealmSwift

enum CalendarManagerError: Error {
    case errorWithText(text: String)
    case invalidSyncToken
    case eventListQueryError(String)
}

final class CalendarManager {
    static let shared: CalendarManager = .init()
    private init() {}
    
    private let service = GTLRCalendarService()
    private let appState = AppState.shared
    private let eventStore = EventStore.shared
    private var syncTokens: [String: String] = [:]
    
    func setUser (_ user: GIDGoogleUser) {
        self.service.authorizer = user.fetcherAuthorizer
        self.service.shouldFetchNextPages = true
    }
    
    func getUserCalendar() async -> [UserCalendar] {
        await withCheckedContinuation { continuation in
            let query = GTLRCalendarQuery_CalendarListList.query()
            self.service.executeQuery(query) { [self] (ticket, response, error) in
                do {
                    if let error = error {
                        throw CalendarManagerError.errorWithText(text: "Error while executing calendar list query '\(error.localizedDescription)'")
                    }
                    guard let calendarList = response as? GTLRCalendar_CalendarList, let items = calendarList.items else {
                        throw CalendarManagerError.errorWithText(text: "Error while parsing calendar list response")
                    }
                    let oldCalendars = appState.userCalendars
                    let newCalendars: [UserCalendar] = {
                        var calendar: [UserCalendar] = []
                        for item in items {
                            let existCal = oldCalendars.first { $0.id == item.identifier! }
                            if let existCal = existCal {
                                calendar.append(existCal)
                                continue
                            }
                            calendar.append(UserCalendar(id: item.identifier!, name: item.summary ?? "", isActive: true))
                        }
                        return calendar
                    }()
                    continuation.resume(returning: newCalendars)
                } catch {
                    print("GoogleCalendarManager - getUserCalendarIds - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sync() async {
        let calendarIds = appState.userCalendars.filter { $0.isActive }.map({ $0.id })
        syncTokens = appState.googleSyncToken

        await withCheckedContinuation { continuation in
            Task {
                await withTaskGroup(of: Void.self) { taskGroup in
                    for calendarId in calendarIds {
                        taskGroup.addTask {
                            await self.syncCalendar(calendarId)
                        }
                    }
                    await taskGroup.waitForAll()
                    appState.googleSyncToken = syncTokens
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
                    DispatchQueue.global(qos: .utility).async {
                        items.forEach { event in
                            if event.status == "cancelled" {
                                self.eventStore.deleteEvent(event.identifier!)
                            } else {
                                self.eventStore.syncEvent(event, calendarId)
                            }
                        }
                        continuation.resume()
                    }
                    self.syncTokens[calendarId] = (response as? GTLRCalendar_Events)?.nextSyncToken ?? ""
                    self.appState.googleSyncToken = self.syncTokens
                } catch {
                    print("GoogleCalendarManager - syncCalendar - \(error.localizedDescription)")
                }
            }
        }
    }
}

