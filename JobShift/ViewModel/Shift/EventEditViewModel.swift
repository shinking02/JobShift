import Observation
import Foundation

@Observable final class EventEditViewModel {
    private var event: ShiftViewEvent
    var title: String
    var start: Date
    var end: Date
    var isAllday: Bool
    var dateError: Bool {
        guard start <= end else { return true }
        return false
    }
    var apiLoading: Bool = false
    
    init(event: ShiftViewEvent) {
        self.event = event
        self.title = event.title
        self.start = event.start
        self.end = event.end
        self.isAllday = event.isAllday
    }
    
    func updateButtonTapped() async {
        apiLoading = true
        event.title = title
        event.start = start
        event.end = end
        event.isAllday = isAllday
        await CalendarManager.shared.updateEvent(event)
        apiLoading = false
    }
    
    func deleteButtonTapped() async {
        apiLoading = true
        await CalendarManager.shared.deleteEvent(event)
        apiLoading = false
    }
}
