import SwiftUI
import RealmSwift

struct SalaryData {
    
}

class SalaryManager {
    private var jobs: [Job]
    private var otJobs: [OneTimeJob]
    
    init(jobs: [Job], otJobs: [OneTimeJob]) {
        self.jobs = jobs
        self.otJobs = otJobs
    }
    
    private func minutesInTimeRange(start: Date, end: Date) -> (daytimeMinutes: Int, nighttimeMinutes: Int) {
        var daytimeMinutes = 0
        var nighttimeMinutes = 0

        let calendar = Calendar(identifier: .gregorian)
        let fiveAM = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: start)!
        let tenPM = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: start)!

        var current = start

        while current < end {
            let next = calendar.date(byAdding: .minute, value: 1, to: current)!

            if calendar.compare(current, to: fiveAM, toGranularity: .minute) != .orderedAscending &&
               calendar.compare(current, to: tenPM, toGranularity: .minute) == .orderedAscending {
                daytimeMinutes += 1
            } else {
                nighttimeMinutes += 1
            }

            current = next
        }

        return (daytimeMinutes, nighttimeMinutes)
    }
    
    private func getEventsSalary(_ events: Results<Event>) -> SalaryData {
        
    }
    
    private func getMonthlySalary(year: Int, month: Int) -> [SalaryData] {
        var salaries: [SalaryData] = []
        // swiftlint:disable:next force_try
        let realm = try! Realm()
        let events = realm.objects(Event.self)
        
        jobs.forEach { job in
            let workInterval = job.getWorkInterval(year: year, month: month)
            let jobEvents = events.where({
                $0.start >= workInterval.start &&
                $0.start < workInterval.start &&
                $0.summary == job.name
            })
            let salary = getEventsSalary(jobEvents)
            salaries.append(salary)
        }
        return salaries
    }
}
