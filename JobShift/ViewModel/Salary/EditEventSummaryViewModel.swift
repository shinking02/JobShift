import Observation

@Observable final class EditEventSummaryViewModel {
    var job: Job
    var eventId: String
    var summary: String = ""
    var adjustString: String = ""
    
    init(job: Job, eventId: String) {
        self.job = job
        self.eventId = eventId
        let target = job.newEventSummaries.first { $0.eventId == eventId }
        summary = target != nil ? target!.summary : ""
        adjustString = target != nil && target!.adjustment != nil ? String(target!.adjustment!) : ""
    }
    
    func onDisappear() {
        job.newEventSummaries.removeAll { $0.eventId == eventId }
        job.newEventSummaries.append(EventSummary(eventId: eventId, summary: summary, adjustment: Int(adjustString)))
        SwiftDataSource.shared.save()
    }
}
