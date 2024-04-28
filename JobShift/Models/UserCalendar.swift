import Observation

@Observable
final class UserCalendar: Identifiable, Hashable {
    init(id: String, summary: String) {
        self.id = id
        self.summary = summary
        self.isActive = !Storage.getDisableCalendarIds().contains(id)
    }
    let id: String
    let summary: String
    var isActive: Bool {
        didSet {
            let disableCalendarIds = Storage.getDisableCalendarIds()
            if isActive {
                Storage.setDisableCalendarIds(disableCalendarIds.filter { $0 != id })
            } else {
                Storage.setDisableCalendarIds(disableCalendarIds + [id])
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
    static func == (lhs: UserCalendar, rhs: UserCalendar) -> Bool {
        return lhs.id == rhs.id
    }
}
