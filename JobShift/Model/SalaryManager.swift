import Foundation
import GoogleAPIClientForREST
import HolidayJp

final class SalaryManager {
    static let shared = SalaryManager()
    private init() {}
    private var eventStore: EventStore? = nil
    
    func setEventStore(eventStore: EventStore) {
        self.eventStore = eventStore
    }
    
    func getSalaries(jobs: [Job], otJobs: [OneTimeJob], year: Int, month: Int?) -> [Salary] {
        var salaries: [Salary] = []
        guard let eventStore else { return salaries }
        salaries = jobs.compactMap { job in
            let (start, end) = calculateDates(year: year, month: month, day: job.salaryCutoffDay)
            let events = eventStore.getJobEventsBetweenDates(start: start, end: end, job: job)

            var forcastWage = 0
            var totalMinutes = 0
            events.forEach { e in
                let (salary, minutes) = calcSalaryAndMinutesByEvent(job: job, event: e.gEvent)
                forcastWage += salary
                totalMinutes += minutes
            }
            let commuteWage = job.isCommuteWage ? job.commuteWage * events.count : 0
            var isConfirmed = false
            let confirmedWage = {
                if let month = month, let cSalary = job.salaryHistories.first(where: { $0.year == year && $0.month == month }) {
                    isConfirmed = true
                    return cSalary.salary
                } else {
                    let cSalaries = job.salaryHistories.filter { $0.year == year }
                    if cSalaries.count != 0 {
                        isConfirmed = cSalaries.count >= 12
                        return cSalaries.reduce(0) { $0 + $1.salary }
                    }
                }
                return 0
            }()
            if events.count < 1 && !isConfirmed {
                return nil
            }
            return Salary(
                        job: job,
                        isConfirmed: isConfirmed,
                        confirmedWage: confirmedWage - commuteWage,
                        forcastWage: forcastWage,
                        commuteWage: commuteWage,
                        events: events.map { $0.gEvent },
                        count: events.count,
                        totalMinutes: totalMinutes
                    )
        }
        let (otStart, otEnd) = calculateDates(year: year, month: month, day: 31)
        let targetOtJobs = otJobs.filter { ot in
            return otStart <= ot.date && ot.date < otEnd
        }
        let otCommute = targetOtJobs.reduce(0) { $0 + ($1.isCommuteWage ? $1.commuteWage : 0) }
        let otConfirmed = targetOtJobs.reduce(0) { $0 + $1.salary }
        if targetOtJobs.count > 0 {
            salaries.append(Salary(
                isConfirmed: true, confirmedWage: otConfirmed, forcastWage: otConfirmed, commuteWage: otCommute, events: [], count: targetOtJobs.count, totalMinutes: 0
            ))
        }
        return salaries.sorted(by: { $0.forcastWage > $1.forcastWage })
    }
    
    func calcSalaryAndMinutesByEvent(job: Job, event: GTLRCalendar_Event) -> (salary: Int, minutes: Int) {
        let calendar = Calendar.current
        let start = event.start?.dateTime?.date ?? event.start?.date?.date
        let end = event.end?.dateTime?.date ?? event.end?.date?.date
        guard let start, let end else { return (0, 0) }
        let wage = job.wages.first { w in
            let wageStart = w.start
            let wageEnd = w.end
            return wageStart <= start && start <= wageEnd
        }
        guard let wage else { return (0, 0) }
        
        let (dayWorkMinutes, nightWorkMinutes): (Int, Int) = {
            let nightDateComp = calendar.dateComponents([.year, .month, .day], from: start)
            let nightTimeComp = calendar.dateComponents([.hour, .minute], from: job.nightWageStartTime)
            let nightStartDate = {
                if job.isNightWage {
                    return calendar.date(bySettingHour: nightTimeComp.hour!, minute: nightTimeComp.minute!, second: 0, of: calendar.date(from: nightDateComp)!)!
                }
                return end
            }()
            
            let breakMinutes: Int = {
                let (break1, break2): (Break?, Break?) = {
                    let breaks = [job.isBreak1 ? job.break1 : nil, job.isBreak2 ? job.break2 : nil].compactMap { $0 }.sorted(by: {$0.breakIntervalMinutes < $1.breakIntervalMinutes})
                    return (breaks.first, breaks.dropFirst().first)
                }()
                guard let break1 else { return 0 }
                var totalWorkMinutes = Int(end.timeIntervalSince(start) / 60)
                var totalBreakMinutes = 0
                while totalWorkMinutes >= break1.breakIntervalMinutes {
                    if let break2 = break2, totalWorkMinutes >= break2.breakIntervalMinutes {
                        totalWorkMinutes -= break2.breakIntervalMinutes
                        totalBreakMinutes += break2.breakMinutes
                    } else {
                        totalWorkMinutes -= break1.breakIntervalMinutes
                        totalBreakMinutes += break1.breakMinutes
                    }
                }
                return totalBreakMinutes
            }()
            let nightMin = Int(end.timeIntervalSince(max(start, nightStartDate)) / 60) > 0 ? Int(end.timeIntervalSince(max(start, nightStartDate)) / 60) : 0
            let dayMin = Int(min(end, nightStartDate).timeIntervalSince(start) / 60) - breakMinutes
            return (dayMin, nightMin)
        }()
        if job.isDailyWage {
            return (wage.dailyWage, dayWorkMinutes + nightWorkMinutes)
        }
        let dayOfWeek = calendar.component(.weekday, from: start)
        let isHoliday = HolidayJp.isHoliday(start) || dayOfWeek == 1 || dayOfWeek == 7
        
        if job.isHolidayWage && isHoliday {
            return ((dayWorkMinutes / 60) * wage.holidayHourlyWage + (nightWorkMinutes / 60) * wage.holidayHourlyNightWage,
                    dayWorkMinutes + nightWorkMinutes)
        }
        return ((dayWorkMinutes / 60) * wage.hourlyWage + (nightWorkMinutes / 60) * wage.nightHourlyWage,
                dayWorkMinutes + nightWorkMinutes)
    }
    
    func calculateDates(year: Int, month: Int?, day: Int) -> (salaryStart: Date, salaryEnd: Date) {
        let currendar = Calendar.current
        if let month = month {
            let startComponents = {
                let tempStart = DateComponents(year: year, month: month - 1, day: 1)
                let startMonthDays = currendar.daysInMonth(for: currendar.date(from: tempStart)!)
                if startMonthDays < day + 1 {
                    return DateComponents(year: year, month: month, day: 1)
                } else {
                    return DateComponents(year: year, month: month - 1, day: day + 1)
                }
            }()
            let endComponents = {
                let tempEnd = DateComponents(year: year, month: month,  day: 1)
                let endMonthDays = currendar.daysInMonth(for: currendar.date(from: tempEnd)!)
                if endMonthDays < day {
                    return DateComponents(year: year, month: month + 1, day: 0, hour: 23, minute: 59)
                } else {
                    return DateComponents(year: year, month: month, day: day, hour: 23, minute: 59)
                }
            }()
            return (currendar.date(from: startComponents)!, currendar.date(from: endComponents)!)
        } else {
            let startComponents = DateComponents(year: year - 1, month: 12, day: day + 1)
            let endComponents = DateComponents(year: year, month: 12, day: day)
            return (currendar.date(from: startComponents)!, currendar.date(from: endComponents)!)
        }
    }

}


struct Salary: Hashable {
    let id = UUID()
    var job: Job?
    var isConfirmed: Bool
    var confirmedWage: Int
    var forcastWage: Int
    var commuteWage: Int
    var events: [GTLRCalendar_Event]
    var count: Int
    let totalMinutes: Int
}

extension Calendar {
    func daysInMonth(for date:Date) -> Int {
        return range(of: .day, in: .month, for: date)!.count
    }
}
