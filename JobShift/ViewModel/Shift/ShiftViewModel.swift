import Observation
import UIKit
import RealmSwift
import Foundation
import SwiftUI

struct DecorationData: Equatable {
    var color: UIColor
    var image: UIImage?
}

struct ShiftViewEvent: Identifiable {
    let id: String
    var color: Color
    var title: String
    var summary: String?
    var timeText1: String
    var timeText2: String?
    var canEdit: Bool
    var calendarId: String
    var isAllday: Bool
    var start: Date
    var end: Date
}

@Observable final class ShiftViewModel {
    var events: Results<Event> = Event.all()
    var selectedDate: Date = Date()
    var decorationStore: [DateComponents: DecorationData] = [:]
    var shouldUpdateDecorationsOnAppear: Bool = false
    var decorationUpdatedDates: [DateComponents] = []
    var selectedDateEvents: [ShiftViewEvent]  {
        getDateEvents(selectedDate)
    }
    var selectedDateSuggests: [ShiftViewEvent] {
        getSuggestEvents(selectedDate)
    }
    var canAddEvent: Bool {
        jobs.count > 0
    }
    private var jobs: [Job] = SwiftDataSource.shared.fetchJobs()
    private var otJobs: [OneTimeJob] = SwiftDataSource.shared.fetchOTJobs()
    
    func onAppear() {
        jobs = SwiftDataSource.shared.fetchJobs()
        otJobs = SwiftDataSource.shared.fetchOTJobs()
        shouldUpdateDecorationsOnAppear = true
    }
    
    func selectionBehavior(_ date: DateComponents?) {
        if let date = date {
            selectedDate = Calendar.current.date(from: date)!
        }
    }
    
    func updateDecoration(_ dateComponents: DateComponents) {
        DispatchQueue.global().async {
            let decoration = self.calculateDecoration(dateComponents)
            if self.decorationStore[dateComponents] != decoration {
                DispatchQueue.main.async {
                    if let decoration = decoration {
                        self.decorationStore[dateComponents] = decoration
                    } else {
                        self.decorationStore.removeValue(forKey: dateComponents)
                    }
                    self.decorationUpdatedDates.append(dateComponents)
                }
            }
        }
    }
    
    func decorationReloaded() {
        decorationUpdatedDates = []
        shouldUpdateDecorationsOnAppear = false
    }
    
    func getSuggestEvents(_ date: Date) -> [ShiftViewEvent] {
        let calendar = Calendar.current
        var suggests: [ShiftViewEvent] = []
        jobs.forEach { job in
            var dateComponents = DateComponents()
            dateComponents.month = -1
            let start = calendar.date(byAdding: dateComponents, to: date)!
            let intervalEvents = getJobEventsFromInterval(start: start, end: date, job: job)
            intervalEvents.forEach { ev in
                let (newStart, newEnd) = reWriteYMD(start: ev.start, end: ev.end, to: date)
                var newEv = ev
                newEv.start = newStart
                newEv.end = newEnd
                newEv.timeText1 = ev.isAllday ? "終日" : "\(ev.start.toHmmString()) ~ \(ev.end.toHmmString())"
                newEv.timeText2 = nil
                suggests.append(newEv)
            }
        }
        var uniqueSuggests: [ShiftViewEvent] = []
        suggests.forEach { suggest in
            if !uniqueSuggests.contains(where: {
                $0.title == suggest.title &&
                $0.start == suggest.start &&
                $0.end == suggest.end
            }) {
                uniqueSuggests.append(suggest)
            }
        }
        return uniqueSuggests
    }
    
    private func reWriteYMD(start: Date, end: Date, to: Date) -> (start: Date, end: Date) {
        let calendar = Calendar(identifier: .japanese)
        let dateDiff = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        let newDateComp = calendar.dateComponents([.year, .month, .day], from: to)
        var newStartComp = calendar.dateComponents([.hour, .minute], from: start)
        newStartComp.year = newDateComp.year
        newStartComp.month = newDateComp.month
        newStartComp.day = newDateComp.day
        let newStart = calendar.date(from: newStartComp)!
        var newEndComp = calendar.dateComponents([.hour, .minute], from: end)
        newEndComp.year = newDateComp.year
        newEndComp.month = newDateComp.month
        newEndComp.day = newDateComp.day! + dateDiff
        let newEnd = calendar.date(from: newEndComp)!
        return (newStart, newEnd)
    }
    
    private func calculateDecoration(_ dateComponents: DateComponents) -> DecorationData? {
        let calendar = Calendar.current
        let date = dateComponents.date!
        let paymentDayJob = jobs.first { job in
            if !job.displayPaymentDay {
                return false
            }
            let paymentDay = job.getSalaryPaymentDay(year: dateComponents.year!, month: dateComponents.month!)
            return paymentDay != nil && calendar.compare(date, to: paymentDay!, toGranularity: .day) == .orderedSame
        }
        if let paymentDayJob = paymentDayJob {
            return DecorationData(color: UIColor(paymentDayJob.color.getColor()), image: UIImage(systemName: "yensign"))
        }
        let dateEvents = getDateEvents(date)
        if dateEvents.isEmpty {
            return nil
        }
        let dayJob = jobs.first { job in
            !getDateJobEvent(date, job).isEmpty
        }
        if let dayJob = dayJob {
            return DecorationData(color: UIColor(dayJob.color.getColor()))
        }
        // No decorations if it is a cross day job and before 10:00 a.m. and that is the only time you are scheduled to work.
        let jobNames = jobs.map { $0.name }
        for event in dateEvents {
            if !jobNames.contains(event.title) {
                return DecorationData(color: UIColor(.secondary))
            }
        }
        return nil
    }
    
    private func getDateEvents(_ date: Date) -> [ShiftViewEvent] {
        let realm = try! Realm()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let dateStart = calendar.date(from: dateComponents)!
        let dateEnd = calendar.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: dateStart)!
        let activeCalendarIds = AppState.shared.userCalendars.filter { $0.isActive }.map { $0.id }
        let jobNames = SwiftDataSource.shared.fetchJobs().map { $0.name }
        let filterRule = {
            if AppState.shared.isShowOnlyJobEvent {
                return "calendarId IN %@ AND (start <= %@ AND start >= %@ OR end <= %@ AND end > %@ OR start <= %@ AND end >= %@) AND summary IN %@"
            }
            return "calendarId IN %@ AND (start <= %@ AND start >= %@ OR end <= %@ AND end > %@ OR start <= %@ AND end >= %@)"
        }()
        
        var dateEvents: [ShiftViewEvent] = []
        let eventHelper = EventHelper()
        let paymentDayJobs = jobs.filter { job in
            let paymentDay = job.getSalaryPaymentDay(year: dateComponents.year!, month: dateComponents.month!)
            return paymentDay != nil && calendar.compare(date, to: paymentDay!, toGranularity: .day) == .orderedSame && job.displayPaymentDay
        }
        realm.objects(Event.self)
            .filter(filterRule, activeCalendarIds, dateEnd, dateStart, dateEnd, dateStart, dateStart, dateEnd, jobNames)
            .sorted(byKeyPath: "start", ascending: true)
            .forEach { event in
                let color = eventHelper.getEventColor(event)
                let (timeText1, timeText2) = eventHelper.getIntervalText(event, self.selectedDate)
                dateEvents.append(ShiftViewEvent(
                    id: event.id,
                    color: color,
                    title: event.summary,
                    summary: event.description,
                    timeText1: timeText1,
                    timeText2: timeText2,
                    canEdit: true,
                    calendarId: event.calendarId,
                    isAllday: event.isAllDay,
                    start: event.start,
                    end: event.end
                ))
            }
        paymentDayJobs.forEach { job in
            dateEvents.append(ShiftViewEvent(
                id: UUID().uuidString,
                color: Color(job.color.getColor()),
                title: "給料日: \(job.name)",
                summary: nil,
                timeText1: "",
                timeText2: nil,
                canEdit: false,
                calendarId: "",
                isAllday: true,
                start: Date(),
                end: Date()
            ))
        }
        let dateOtJobs = otJobs.filter { calendar.compare($0.date, to: date, toGranularity: .day) == .orderedSame }
        dateOtJobs.forEach { otJob in
            dateEvents.append(ShiftViewEvent(
                id: UUID().uuidString,
                color: .secondary,
                title: otJob.name,
                summary: nil,
                timeText1: "",
                timeText2: nil,
                canEdit: false,
                calendarId: "",
                isAllday: true,
                start: Date(),
                end: Date()
            ))
        }
        return dateEvents
    }
    
    private func getDateJobEvent(_ date: Date, _ job: Job) -> Results<Event> {
        let realm = try! Realm()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let dateStart = calendar.date(from: dateComponents)!
        let dateEnd = calendar.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: dateStart)!
        let displayableDateEnd = calendar.date(byAdding: DateComponents(hour: 10), to: dateStart)!
        let activeCalendarIds = AppState.shared.userCalendars.filter { $0.isActive }.map { $0.id }
        let filterRule = "calendarId IN %@ AND (start <= %@ AND start >= %@ OR start <= %@ AND end > %@) AND summary == %@"
        return realm.objects(Event.self)
            .filter(filterRule, activeCalendarIds, dateEnd, dateStart, dateStart, displayableDateEnd, job.name)
            .sorted(byKeyPath: "start", ascending: true)
    }
    
    private func getJobEventsFromInterval(start: Date, end: Date, job: Job) -> [ShiftViewEvent] {
        let realm = try! Realm()
        let activeCalendarIds = AppState.shared.userCalendars.filter { $0.isActive }.map { $0.id }
        let eventHelper = EventHelper()
        var intervalEvents: [ShiftViewEvent] = []
        
        realm.objects(Event.self)
            .filter("calendarId IN %@ AND start <= %@ AND start >= %@ AND summary == %@",
                    activeCalendarIds, end, start, job.name)
            .forEach { e in
                let color = eventHelper.getEventColor(e)
                let (timeText1, timeText2) = eventHelper.getIntervalText(e, self.selectedDate)
                intervalEvents.append(ShiftViewEvent(
                    id: e.id,
                    color: color,
                    title: e.summary,
                    summary: e.description,
                    timeText1: timeText1,
                    timeText2: timeText2,
                    canEdit: true,
                    calendarId: e.calendarId,
                    isAllday: e.isAllDay,
                    start: e.start,
                    end: e.end
                ))
            }
        return intervalEvents
    }
}
