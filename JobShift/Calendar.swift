import Observation

@Observable
final class Calendar {
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
                Storage.setDisableCalendarIds(ids: disableCalendarIds.filter { $0 != id })
            } else {
                Storage.setDisableCalendarIds(ids: disableCalendarIds + [id])
            }
        }
    }
}
