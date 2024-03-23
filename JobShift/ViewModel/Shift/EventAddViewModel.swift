import Observation
import Foundation

@Observable final class EventAddViewModel {
    private var event: ShiftViewEvent
    var jobSelection: Job
    var calendarSelection: UserCalendar
    var start: Date
    var end: Date
    var isAllday: Bool
    var dateError: Bool {
        guard start <= end else { return true }
        return false
    }
    var apiLoading: Bool = false
    var jobs: [Job] {
        SwiftDataSource.shared.fetchJobs()
    }
    
    init(event: ShiftViewEvent) {
        self.event = event
        let job = SwiftDataSource.shared.fetchJobs().first { $0.name == event.title }
        self.jobSelection = job ?? SwiftDataSource.shared.fetchJobs().first!
        self.calendarSelection = AppState.shared.defaultCalendar ?? AppState.shared.userCalendars.first!
        self.start = event.start
        self.end = event.end
        self.isAllday = event.isAllday
    }
    
    func addButtonTapped() async {
        apiLoading = true
        let newEvent = ShiftViewEvent(
            id: UUID().uuidString,
            color: jobSelection.color.getColor(),
            title: jobSelection.name,
            summary: "",
            detailText1: "",
            canEdit: true,
            calendarId: calendarSelection.id,
            isAllday: isAllday,
            start: start,
            end: end
        )
        await CalendarManager.shared.addEvent(newEvent)
        apiLoading = false
    }
}
