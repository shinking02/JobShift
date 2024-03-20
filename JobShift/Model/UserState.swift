import Foundation
import GoogleAPIClientForREST

class UserState: ObservableObject {
    @Published var email: String = ""
    @Published var imageURL: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var calendars: [GTLRCalendar_CalendarListEntry] = []
    @Published var mainCal: GTLRCalendar_CalendarListEntry? = nil
    @Published var selectedCalendars: [GTLRCalendar_CalendarListEntry] = []
}
