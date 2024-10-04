import Foundation
import RealmSwift

struct JobEvent: Identifiable, Hashable {
    var id = UUID()
    var event: Event
    var salary: Int
    var minutes: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(event)
        hasher.combine(salary)
        hasher.combine(minutes)
    }

    static func == (lhs: JobEvent, rhs: JobEvent) -> Bool {
        return lhs.id == rhs.id &&
               lhs.event == rhs.event &&
               lhs.salary == rhs.salary &&
               lhs.minutes == rhs.minutes
    }
}


struct JobSalaryData: Identifiable, Hashable {
    var id = UUID()
    var job: Job
    var events: [JobEvent]
    var forecastSalary: Int
    var confirmedSalary: Int
    var isConfirmed: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(job)
        hasher.combine(events)
        hasher.combine(confirmedSalary)
        hasher.combine(isConfirmed)
    }

    static func == (lhs: JobSalaryData, rhs: JobSalaryData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.job == rhs.job &&
               lhs.events == rhs.events &&
               lhs.confirmedSalary == rhs.confirmedSalary &&
               lhs.isConfirmed == rhs.isConfirmed
    }
}


final class SalaryManager {
    static let shared: SalaryManager = .init()
    
    private init() {}
    
    private func getJobEvents(interval: DateInterval, job: Job) -> [JobEvent] {
        let realm = try! Realm()
        let jobEvents: [JobEvent] = realm.objects(Event.self).where({
            $0.start >= interval.start &&
            $0.start < interval.end &&
            $0.summary == job.name
        }).compactMap { event in
            // Get the wage that started closest to the event's start but not after it
            let applicableWage = job.jobWages
                .filter { $0.start <= event.start }
                .sorted { $0.start > $1.start }
                .first
            
            // Ensure a wage is found, otherwise skip the event
            guard let wage = applicableWage else { return nil }
            
            // Calculate regular and late-night minutes
            var (regularMinutes, nightMinutes) = calculateWorkingMinutes(event: event)
            
            // Apply breaks to the working minutes
            let breaks = job.breaks.filter { $0.isActive }
            if !breaks.isEmpty {
                let totalWorkingMinutes = regularMinutes + nightMinutes
                let breakMinutes = calculateBreakMinutes(totalWorkingMinutes: totalWorkingMinutes, breaks: breaks)
                // Subtract break time from regular and night minutes
                (regularMinutes, nightMinutes) = applyBreaks(regularMinutes: regularMinutes, nightMinutes: nightMinutes, breakMinutes: breakMinutes)
            }
            
            let salary = calculateSalary(wage: wage.wage, regularMinutes: regularMinutes, nightMinutes: nightMinutes, job: job, event: event) - (job.isCommuteWage ? -job.commuteWage : 0)
                    
            return JobEvent(event: event, salary: max(0, salary), minutes: max(0, regularMinutes + nightMinutes))
        }
        return jobEvents
    }
    
    private func calculateSalary(wage: Int, regularMinutes: Int, nightMinutes: Int, job: Job, event: Event) -> Int {
        // Calculate hourly wage for regular and night work
        let regularWage = wage
        let nightWage = job.isNightWage ? Int(Double(wage) * 1.25) : wage
        
        // Calculate regular and night salaries
        let regularSalary = (regularWage * regularMinutes) / 60
        let nightSalary = (nightWage * nightMinutes) / 60
        
        // Total salary before holiday adjustment
        var totalSalary = regularSalary + nightSalary
        
        // Apply holiday wage if applicable
        if job.isHolidayWage && event.start.isHoliday {
            totalSalary = Int(Double(totalSalary) * 1.35)
        }
        
        return totalSalary
    }

    private func calculateWorkingMinutes(event: Event) -> (regularMinutes: Int, nightMinutes: Int) {
        let calendar = Calendar.current
        var currentStart = event.start
        var totalRegularMinutes = 0
        var totalNightMinutes = 0
        
        while currentStart < event.end {
            // End of the current day (next day at 00:00)
            let nextDayStart = calendar.startOfDay(for: currentStart).addingTimeInterval(24 * 60 * 60)
            
            // Calculate working time within the current day
            let workingEnd = min(nextDayStart, event.end)
            
            // Deep night range: 22:00 - 05:00 (next day)
            let deepNightStart = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: currentStart)!
            let deepNightEnd = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: nextDayStart)!
            
            // Calculate regular and night minutes for the current day
            totalRegularMinutes += getMinutesInRange(from: currentStart, to: workingEnd, within: calendar.date(bySettingHour: 5, minute: 0, second: 0, of: currentStart)!, and: deepNightStart)
            totalNightMinutes += getMinutesInRange(from: currentStart, to: workingEnd, within: deepNightStart, and: deepNightEnd)
            
            // Move to the next day
            currentStart = nextDayStart
        }
        
        return (totalRegularMinutes, totalNightMinutes)
    }

    private func getMinutesInRange(from start: Date, to end: Date, within rangeStart: Date, and rangeEnd: Date) -> Int {
        let calendar = Calendar.current
        let actualStart = max(start, rangeStart)
        let actualEnd = min(end, rangeEnd)
        
        if actualStart >= actualEnd {
            return 0
        }
        
        let minutes = calendar.dateComponents([.minute], from: actualStart, to: actualEnd).minute ?? 0
        return minutes
    }

    // Calculate the total break minutes to be applied based on the working time and break intervals
    private func calculateBreakMinutes(totalWorkingMinutes: Int, breaks: [JobBreak]) -> Int {
        var totalBreakMinutes = Int.max
        for jobBreak in breaks {
            if totalWorkingMinutes >= jobBreak.intervalMinutes {
                totalBreakMinutes = min(totalBreakMinutes, jobBreak.breakMinutes)
            }
        }
        return totalBreakMinutes == Int.max ? 0 : totalBreakMinutes
    }

    // Apply breaks first to regular minutes, then to night minutes if necessary
    private func applyBreaks(regularMinutes: Int, nightMinutes: Int, breakMinutes: Int) -> (Int, Int) {
        var remainingBreakMinutes = breakMinutes
        var updatedRegularMinutes = regularMinutes
        var updatedNightMinutes = nightMinutes
        
        if remainingBreakMinutes > updatedRegularMinutes {
            remainingBreakMinutes -= updatedRegularMinutes
            updatedRegularMinutes = 0
            updatedNightMinutes = max(0, updatedNightMinutes - remainingBreakMinutes)
        } else {
            updatedRegularMinutes -= remainingBreakMinutes
        }
        
        return (updatedRegularMinutes, updatedNightMinutes)
    }
    
    func getSalaryData(date: Date, jobs: [Job], dateMode: DateMode) -> [JobSalaryData] {
        let jobSalaryData: [JobSalaryData] = jobs.map { job in
            if dateMode == .month {
                let jobWorkInterval = job.getWorkInterval(year: date.year, month: dateMode == .month ? date.month : nil)
                let jobStartDate = job.jobWages.sorted(by: { $0.start < $1.start }).first!.start
                if jobStartDate > jobWorkInterval.end {
                    return JobSalaryData(job: job, events: [], forecastSalary: 0, confirmedSalary: 0, isConfirmed: true)
                }
                
                let events: [JobEvent] = getJobEvents(interval: jobWorkInterval, job: job)
                let history = job.salary.histories.first { $0.year == date.year && $0.month == date.month }
                let isConfirmed = history != nil
                let confirmedSalary = max((history?.salary ?? 0) - (job.isCommuteWage ? job.commuteWage * events.count : 0), 0)
                let forecastSalary = events.map(\.salary).reduce(0, +)
                return JobSalaryData(job: job, events: events, forecastSalary: forecastSalary, confirmedSalary: confirmedSalary, isConfirmed: isConfirmed)
            } else {
                var totalConfirmedSalary = 0
                var totalForecastSalary = 0
                var allMonthsConfirmed = true
                var allEvents: [JobEvent] = []
                
                for month in 1...12 {
                    let jobWorkInterval = job.getWorkInterval(year: date.year, month: month)
                    let events: [JobEvent] = getJobEvents(interval: jobWorkInterval, job: job)
                    let history = job.salary.histories.first { $0.year == date.year && $0.month == month }
                    
                    totalForecastSalary += history != nil ? history!.salary : events.map(\.salary).reduce(0, +)
                    let jobStartDate = job.jobWages.sorted(by: { $0.start < $1.start }).first!.start
                    if let confirmedSalary = history?.salary {
                        totalConfirmedSalary += confirmedSalary
                    } else if jobStartDate < jobWorkInterval.end {
                        allMonthsConfirmed = false
                    }
                    allEvents.append(contentsOf: events)
                }
                return JobSalaryData(job: job, events: allEvents, forecastSalary: totalForecastSalary, confirmedSalary: totalConfirmedSalary, isConfirmed: allMonthsConfirmed)
            }
        }
        return jobSalaryData
    }
}
