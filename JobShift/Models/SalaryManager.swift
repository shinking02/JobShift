import Foundation
import RealmSwift

struct SalaryData {
    let job: Job
    let salary: Int
    let count: Int
    let commuteWage: Int
    let minutes: Int
}

class SalaryManager {
    private var job: Job
    private var realm: Realm
    
    private func minutesInNightAndDay(from interval: DateInterval) -> (nightMinutes: Int, dayMinutes: Int) {
        let calendar = Calendar.current
        var dayMinutes = 0
        var currentStart = interval.start
        let end = interval.end

        while currentStart < end {
            let dayStart = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: currentStart)!
            let dayEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: currentStart)!
            if interval.contains(dayStart) && interval.contains(dayEnd) {
                let fullDayInterval = DateInterval(start: dayStart, end: dayEnd)
                dayMinutes += Int(fullDayInterval.duration / 60)
            } else {
                if interval.contains(dayStart) {
                    let partialDayInterval = DateInterval(start: dayStart, end: min(dayEnd, end))
                    dayMinutes += Int(partialDayInterval.duration / 60)
                }
                if interval.contains(dayEnd) {
                    let partialDayInterval = DateInterval(start: max(dayStart, interval.start), end: dayEnd)
                    dayMinutes += Int(partialDayInterval.duration / 60)
                }
            }
            currentStart = calendar.date(byAdding: .day, value: 1, to: currentStart)!
        }
        let totalMinutes = Int(interval.duration / 60)
        let nightMinutes = totalMinutes - dayMinutes
        return (nightMinutes, dayMinutes)
    }
    
    private func getEventSalary(_ event: Event) -> SalaryData {
        
    }
    
    
    init(job: Job) {
        // swiftlint:disable:next force_try
        self.realm = try! Realm()
        self.job = job
    }
    
    func getMonthlySalary(year: Int, month: Int) -> SalaryData {
        let events = realm.objects(Event.self)
        let interval = job.getWorkInterval(year: year, month: month)
        let jobEvents = events.filter({
            $0.start >= interval.start &&
            $0.end <= interval.end &&
            $0.summary == self.job.name
        })
        let salaries = jobEvents.map { event -> SalaryData in self.getEventSalary(event) }
        
        return salaries.reduce(SalaryData(job: job, salary: 0, count: 0, commuteWage: 0, minutes: 0)) { (result, salary) -> SalaryData in
            return SalaryData(job: job, salary: result.salary + salary.salary, count: result.count + salary.count, commuteWage: result.commuteWage + salary.commuteWage, minutes: result.minutes + salary.minutes)
        }
    }
}
