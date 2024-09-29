import Foundation
import RealmSwift

class Event: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var calendarId: String
    @Persisted var summary: String
    @Persisted var start: Date
    @Persisted var end: Date
    @Persisted var isAllDay: Bool
}
