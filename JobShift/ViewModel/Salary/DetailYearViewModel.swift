import Observation
import Foundation

@Observable final class DetailYearViewModel {
    var forcastSalary: String = ""
    var confirmSalary: String = ""
    var avgMinutes: Int = 0
    var count: Int = 0
    var year: Int
    var job: Job
    var yearChartDatas: [YearChartData] = []
    var monthAvg: Int = 0
    private var includeCommuteWage: Bool
    
    init(job: Job, year: Int, includeCommuteWage: Bool) {
        self.job = job
        self.year = year
        self.includeCommuteWage = includeCommuteWage
    }
    
    func onAppear() {
        update()
    }
    
    private func update() {
        var salaries: [Salary] = []
        for month in 1...12 {
            salaries.append(job.getMonthSalary(year: year, month: month))
        }
        forcastSalary = String(salaries.map { $0.totalSalary + (includeCommuteWage ? $0.commuteWage : 0) }.reduce(0, +))
        confirmSalary = String(salaries.map { $0.isConfirm ? $0.confirmTotal + (includeCommuteWage ? $0.commuteWage : 0) : 0 }.reduce(0, +))
        count = salaries.map { $0.count }.reduce(0, +)
        avgMinutes = count != 0 ? salaries.map { $0.totalMinutes }.reduce(0, +) / count : 0
        yearChartDatas = salaries.map { s in
            let salary = {
                if s.isConfirm {
                    return s.confirmTotal + (self.includeCommuteWage ? s.commuteWage : 0)
                } else {
                    return s.totalSalary + (self.includeCommuteWage ? s.commuteWage : 0)
                }
            }()
            let date = Calendar.current.date(from: DateComponents(year: year, month: s.month))!
            return YearChartData(date: date, month: s.month, salary: salary, isConfirm: s.isConfirm, count: s.count)
        }
        monthAvg = yearChartDatas.map { $0.salary }.reduce(0, +) / yearChartDatas.count
    }
}

struct YearChartData: Identifiable {
    let id = UUID()
    var date: Date
    var month: Int
    var salary: Int
    var isConfirm: Bool
    var count: Int
}

