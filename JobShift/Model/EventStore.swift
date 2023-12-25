import Foundation
import GoogleAPIClientForREST
import Collections

class EventStore: ObservableObject {
    @Published var events: [Event] = []
    
    private let calManager = GoogleCalendarManager.shared
    
    func addEvents(events: [Event]) {
        self.events.append(contentsOf: events)
        self.sortEventsByStartDate()
    }
    
    func getEvents() -> [Event] {
        return self.events
    }
    
    func clearCalendarStore() {
        self.events = []
    }
    
    func addEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        calManager.addEvent(toCalendarId: event.calId, event: event.gEvent) { success, insertIvent in
            if success {
                let newEvent = Event(calId: event.calId, gEvent: insertIvent!)
                self.events.append(newEvent)
                self.sortEventsByStartDate()
            }
            completion(success)
        }
    }
    
    func deleteEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        calManager.deleteEvent(fromCalendarId: event.calId, eventId: event.gEvent.identifier ?? "") { success in
            if success {
                self.events = self.events.filter { $0.gEvent.identifier != event.gEvent.identifier }
            }
            completion(success)
        }
    }
    
    func deleteNormalEvents(jobs: [Job]) {
        let jobNames = jobs.map { $0.name }
        self.events = self.events.filter { jobNames.contains($0.gEvent.summary ?? "") }
    }
    
    func updateEvent(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        calManager.updateEvent(inCalendarId: event.calId, updatedEvent: event.gEvent) { success, updateEvent in
            if success {
                self.events = self.events.filter { $0.id != event.id }
                self.events.append(Event(calId: event.calId, gEvent: updateEvent!))
                self.sortEventsByStartDate()
            }
            completion(success)
        }
    }
    
    func deleteCalendarFromStore(calendars: [GTLRCalendar_CalendarListEntry]) {
        self.events.removeAll { event in
            calendars.contains { cal in
                event.calId == cal.identifier
            }
        }
    }

    
    func updateCalendarForStore(calendars: [GTLRCalendar_CalendarListEntry], completion: @escaping (_ success: Bool) -> Void) {
        deleteCalendarFromStore(calendars: calendars)
        var newEvents: [Event] = []
        let dispatchGroup = DispatchGroup()
        calendars.forEach { calendar in
            guard let id = calendar.identifier else { return }
            dispatchGroup.enter()
            calManager.fetchEventsFromCalendarId(calId: id) { events in
                if let events = events {
                    newEvents += events.map { gEvent in
                        return Event(calId: id, gEvent: gEvent)
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.addEvents(events: newEvents)
            completion(true)
        }
    }
    
    func getEventsFromDate(dateComponents: DateComponents) -> [Event] {
        guard let targetStartDate = Calendar.current.date(from: dateComponents),
              let targetEndDate = Calendar.current.date(byAdding: .day, value: 1, to: targetStartDate) else {
            return []
        }
        let startIndex = binarySearch(events, targetStartDate, { $0.gEvent.start?.dateTime?.date ?? $0.gEvent.start?.date?.date ?? Date.distantFuture })
        let filteredEvents = events[startIndex..<events.endIndex].prefix { event in
            let startDate = event.gEvent.start?.dateTime?.date ?? event.gEvent.start?.date?.date
            let endDate = event.gEvent.end?.dateTime?.date ?? event.gEvent.end?.date?.date
            if let startDate = startDate, let endDate = endDate {
                return startDate < targetEndDate && endDate > targetStartDate
            }
            return false
        }
        // FIXME: 日付を跨いだ終日イベント, 日付を跨いだ半日以上のイベントは返却(暫定対応: 10個前のイベントまで確認)
        let additionalEvents: [Event] = {
            let pastStartIndex = startIndex < 10 ? 0 : startIndex - 10
            return events[pastStartIndex..<startIndex].filter { event in
                if let startDate = event.gEvent.start?.dateTime?.date, let endDate = event.gEvent.end?.dateTime?.date,
                   let targetHarfDate = Calendar.current.date(byAdding: .hour, value: -12, to: targetEndDate) {
                    return startDate..<endDate ~= targetHarfDate
                } else if let startDate = event.gEvent.start?.date?.date, let endDate = event.gEvent.end?.date?.date {
                    return startDate...endDate ~= targetEndDate
                }
                return false
            }
        }()
        return Array(additionalEvents + filteredEvents)
    }
    
    func getSuggest(jobs: [Job], dateComponents: DateComponents) -> [Suggest] {
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: date)!
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: date)!
        let twentyOneDaysAgo = Calendar.current.date(byAdding: .day, value: -21, to: date)!
        let jobEvents7DaysAgo = getJobEvents(events: events, job: jobs, date: sevenDaysAgo)
        let jobEvents14DaysAgo = getJobEvents(events: events, job: jobs, date: fourteenDaysAgo)
        let remainingJobEvents = events
            .filter { event in
                let eventDate = event.gEvent.start?.dateTime?.date ?? event.gEvent.start?.date?.date ?? Date.distantFuture
                guard let jobName = event.gEvent.summary else { return false}
                return jobs.contains { $0.name == jobName } && eventDate >= twentyOneDaysAgo && eventDate < date
            }
        var jobEvents: [Suggest] = []
        if let jobEvent7DaysAgo = jobEvents7DaysAgo.first, let job = jobs.first(where: { $0.name == jobEvent7DaysAgo.gEvent.summary }) {
            let start = jobEvent7DaysAgo.gEvent.start?.dateTime?.date ?? jobEvent7DaysAgo.gEvent.start?.date?.date ?? Date()
            let end = jobEvent7DaysAgo.gEvent.end?.dateTime?.date ?? jobEvent7DaysAgo.gEvent.end?.date?.date ?? Date()
            let isAllDay = jobEvent7DaysAgo.gEvent.start?.date != nil
            let colorId = jobEvent7DaysAgo.gEvent.colorId ?? ""
            jobEvents.append(Suggest(job: job, isAllDay: isAllDay, start: start, end: end, colorId: colorId))
        }
        if let jobEvent14DaysAgo = jobEvents14DaysAgo.first, let job = jobs.first(where: { $0.name == jobEvent14DaysAgo.gEvent.summary }) {
            let start = jobEvent14DaysAgo.gEvent.start?.dateTime?.date ?? jobEvent14DaysAgo.gEvent.start?.date?.date ?? Date()
            let end = jobEvent14DaysAgo.gEvent.end?.dateTime?.date ?? jobEvent14DaysAgo.gEvent.end?.date?.date ?? Date()
            let isAllDay = jobEvent14DaysAgo.gEvent.start?.date != nil
            let colorId = jobEvent14DaysAgo.gEvent.colorId ?? ""
            jobEvents.append(Suggest(job: job, isAllDay: isAllDay, start: start, end: end, colorId: colorId))
        }
        jobEvents += remainingJobEvents.compactMap { event in
            let job = jobs.first { $0.name == event.gEvent.summary }
            guard let job else { return nil }
            let start = event.gEvent.start?.dateTime?.date ?? event.gEvent.start?.date?.date ?? Date()
            let end = event.gEvent.end?.dateTime?.date ?? event.gEvent.end?.date?.date ?? Date()
            let isAllDay = event.gEvent.start?.date != nil
            let colorId = event.gEvent.colorId ?? ""
            return Suggest(job: job, isAllDay: isAllDay, start: start, end: end, colorId: colorId)
        }
        let calendar = Calendar.current
        let suggestions: [Suggest] = jobEvents.map { je -> Suggest in
            let dayDiff = calendar.dateComponents([.day], from: je.start, to: date).day ?? 0
            var addDateComponents = DateComponents()
            var (newStart, newEnd): (Date, Date)
            addDateComponents.day = dayDiff + 1
            newStart = calendar.date(byAdding: addDateComponents, to: je.start)!
            newEnd = calendar.date(byAdding: addDateComponents, to: je.end)!
            return Suggest(job: je.job, isAllDay: je.isAllDay, start: newStart, end: newEnd, colorId: je.colorId)
        }
        return Array(OrderedSet(suggestions)) //重複排除
    }
    
    func getJobEventsBetweenDates(start: Date, end: Date, job: Job) -> [Event] {
        let startIndex = binarySearch(events, start, { $0.gEvent.start?.dateTime?.date ?? $0.gEvent.start?.date?.date ?? Date.distantFuture })
        let endIndex = binarySearch(events, end, { $0.gEvent.start?.dateTime?.date ?? $0.gEvent.start?.date?.date ?? Date.distantFuture })
        let filteredEvents = events[startIndex..<endIndex].filter { $0.gEvent.summary == job.name }
        return Array(filteredEvents)
    }
    
    private func getJobEvents(events: [Event], job: [Job], date: Date) -> [Event] {
        return events.filter { event in
            let eventDate = event.gEvent.start?.dateTime?.date ?? event.gEvent.start?.date?.date ?? Date.distantFuture
            let jobName = event.gEvent.summary ?? ""
            return job.contains { $0.name == jobName } && eventDate == date
        }
    }
    
    private func binarySearch<T>(_ array: [T], _ target: Date, _ key: (T) -> Date) -> Array<T>.Index {
        var low = array.startIndex
        var high = array.endIndex
        while low < high {
            let mid = low + (high - low) / 2
            if key(array[mid]) < target {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
    
    private func sortEventsByStartDate() {
        self.events = events.sorted { event1, event2 in
            guard let start1 = event1.gEvent.start?.dateTime?.date ?? event1.gEvent.start?.date?.date,
                  let start2 = event2.gEvent.start?.dateTime?.date ?? event2.gEvent.start?.date?.date else {
                return false
            }
            return start1 < start2
        }
    }
}

struct Event: Hashable, Identifiable {
    let id: UUID = UUID()
    var calId: String
    var gEvent: GTLRCalendar_Event
    init(calId: String = "", gEvent: GTLRCalendar_Event = GTLRCalendar_Event()) {
        self.calId = calId
        if gEvent.summary == nil {
            gEvent.summary = "新規イベント"
        }
        self.gEvent = gEvent
    }
}

struct Suggest: Hashable, Identifiable, Equatable {
    let id = UUID()
    var job: Job
    var isAllDay: Bool = false
    var start: Date
    var end: Date
    var colorId: String
    func hash(into hasher: inout Hasher) {
        hasher.combine(job.id)
        hasher.combine(start)
        hasher.combine(end)
        hasher.combine(isAllDay)
    }
    static func == (lhs: Suggest, rhs: Suggest) -> Bool {
        if lhs.job.id != rhs.job.id { return false }
        return lhs.start == rhs.start && lhs.end == lhs.end && lhs.isAllDay == rhs.isAllDay
    }
}
