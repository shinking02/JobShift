import Observation
import RealmSwift
import Foundation

@Observable final class ShiftViewModel {
    var events: Results<Event> = Event.all()
    var selectedDate: Date = Date()
    var selectedDateEvents: Results<Event> {
        return getDateEvents(selectedDate)
    }
    var selectedDateJobEvents: [Event] {
        getJobEvents(selectedDate)
    }
    private var notificationTokens: [NotificationToken] = []
    private var jobs: [Job] = SwiftDataSource.shared.fetchJobs()
    private var otJobs: [OneTimeJob] = SwiftDataSource.shared.fetchOTJobs()
    private let calendar = Calendar.current
    
    func selectionBehavior(_ date: DateComponents?) {
        if let date = date {
            selectedDate = Calendar.current.date(from: date)!
        }
    }
    func decorationFor(_ dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let date = dateComponents.date!
        let events = getDateEvents(date)
        let paymentDayJob = jobs.first { job in
            let paymentDay = job.getSalaryPaymentDay(year: dateComponents.year!, month: dateComponents.month!)
            guard let paymentDay = paymentDay else {
                return false
            }
            return calendar.compare(date, to: paymentDay, toGranularity: .day) == .orderedSame
        }
        if let paymentDayJob = paymentDayJob {
            return .image(UIImage(systemName: "yensign"), color: UIColor(paymentDayJob.color.getColor()), size: .large)
        }
        if events.isEmpty {
            return nil
        }
        let dayJob = jobs.first { job in
            let jobEvents = events.filter { $0.summary == job.name }
            return !jobEvents.isEmpty
        }
        if let dayJob = dayJob {
            return .default(color: UIColor(dayJob.color.getColor()))
        }
        return .default(color: UIColor(.secondary))
    }
    
    private func getDateEvents(_ date: Date) -> Results<Event> {
        let realm = try! Realm()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let dateStart = calendar.date(from: dateComponents)!
        let dateEnd = calendar.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: dateStart)!
        let activeCalendarIds = AppState.shared.userCalendars.filter { $0.isActive }.map { $0.id }
        let jobNames = SwiftDataSource.shared.fetchJobs().map { $0.name }
        let filterRule = {
            if AppState.shared.isShowOnlyJobEvent {
                return "calendarId IN %@ AND (start <= %@ AND start >= %@ OR end <= %@ AND end >= %@ OR start <= %@ AND end >= %@) AND summary IN %@"
            }
            return "calendarId IN %@ AND (start <= %@ AND start >= %@ OR end <= %@ AND end >= %@ OR start <= %@ AND end >= %@)"
        }()
        return realm.objects(Event.self)
            .filter(filterRule, activeCalendarIds, dateEnd, dateStart, dateEnd, dateStart, dateStart, dateEnd, jobNames)
            .sorted(byKeyPath: "start", ascending: true)
    }
    private func getJobEvents(_ date: Date) -> [Event] {
        var events: [Event] = []
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let targetJobs = jobs.filter { job in
            let paymentDay = job.getSalaryPaymentDay(year: dateComponents.year!, month: dateComponents.month!)
            guard let paymentDay = paymentDay else {
                return false
            }
            return calendar.compare(date, to: paymentDay, toGranularity: .day) == .orderedSame
        }
        let targetOtJobs = otJobs.filter { calendar.compare($0.date, to: date, toGranularity: .day) == .orderedSame }
        targetJobs.forEach { job in
            let event = Event()
            event.summary = "\(job.name)給料支払日"
            events.append(event)
        }
        targetOtJobs.forEach { otJob in
            let event = Event()
            event.summary = otJob.name
            events.append(event)
        }
        return events
    }
}
