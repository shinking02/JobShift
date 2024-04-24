import Foundation
import GoogleAPIClientForREST_Calendar

final class CalendarManager {
    static let shared: CalendarManager? = {
        do {
            return try CalendarManager()
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return nil
        }
    }()
    private let service = GTLRCalendarService()
    var calendars: [Calendar] = []
    
    private init() throws {
        if let user = AppState.shared.user {
            service.authorizer = user.fetcherAuthorizer
        } else {
            throw AppError.calendarManager(.initalizeFailed)
        }
    }
    
    private func setCalendars() async {
        await withCheckedContinuation { continuation in
            let query = GTLRCalendarQuery_CalendarListList.query()
            service.executeQuery(query) { ticket, response, error in
                if error != nil {
                    print("ERROR: \(error!.localizedDescription)")
                    continuation.resume()
                }
                let calendarList = response as! GTLRCalendar_CalendarList
                self.calendars = (calendarList.items ?? []).map { calendar in
                    return Calendar(
                        id: calendar.identifier!,
                        summary: calendar.summary!
                    )
                }
                continuation.resume()
            }
        }
    }
    
    func syncFromGoogleCalendar() async {
        await setCalendars()
    }
}
