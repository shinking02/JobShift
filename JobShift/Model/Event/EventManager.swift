import Foundation
import GoogleAPIClientForREST
import Collections

struct EventManager {
    static func getEventsFromDate(events: [Event], dateComponents: DateComponents) -> [Event] {
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
    
    static func getSuggest(events: [Event], jobs: [Job], dateComponents: DateComponents) -> [Suggest] {
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: date)!
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: date)!
        let jobEvents7DaysAgo = getJobEvents(events: events, job: jobs, date: sevenDaysAgo)
        let jobEvents14DaysAgo = getJobEvents(events: events, job: jobs, date: fourteenDaysAgo)
        let remainingJobEvents = events
            .filter { event in
                let eventDate = event.gEvent.start?.dateTime?.date ?? event.gEvent.start?.date?.date ?? Date.distantFuture
                guard let jobName = event.gEvent.summary else { return false}
                return jobs.contains { $0.name == jobName } && eventDate >= fourteenDaysAgo && eventDate < date
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
            let gtlrEvent = GTLRCalendar_Event()
            var (newStart, newEnd): (Date, Date)
            addDateComponents.day = dayDiff + 1
            newStart = calendar.date(byAdding: addDateComponents, to: je.start)!
            newEnd = calendar.date(byAdding: addDateComponents, to: je.end)!
            return Suggest(job: je.job, isAllDay: je.isAllDay, start: newStart, end: newEnd, colorId: je.colorId)
        }
        return Array(OrderedSet(suggestions)) //重複排除
    }
    
    private static func getJobEvents(events: [Event], job: [Job], date: Date) -> [Event] {
        return events.filter { event in
            let eventDate = event.gEvent.start?.dateTime?.date ?? event.gEvent.start?.date?.date ?? Date.distantFuture
            let jobName = event.gEvent.summary ?? ""
            return job.contains { $0.name == jobName } && eventDate == date
        }
    }
    
    static private func binarySearch<T>(_ array: [T], _ target: Date, _ key: (T) -> Date) -> Array<T>.Index {
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
