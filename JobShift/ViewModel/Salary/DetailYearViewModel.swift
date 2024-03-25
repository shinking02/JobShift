import Foundation
import Observation

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
        let attendanceCount = salaries.map { $0.attendanceCount }.reduce(0, +)
        avgMinutes = attendanceCount == 0 ? salaries.map { $0.totalMinutes }.reduce(0, +) / count : 0
        yearChartDatas = salaries.map { salary in
            let yearSalary = {
                if salary.isConfirm {
                    return salary.confirmTotal + (self.includeCommuteWage ? salary.commuteWage : 0)
                } else {
                    return salary.totalSalary + (self.includeCommuteWage ? salary.commuteWage : 0)
                }
            }()
            let date = Calendar.current.date(from: DateComponents(year: year, month: salary.month))!
            return YearChartData(date: date, month: salary.month, salary: yearSalary, isConfirm: salary.isConfirm, count: salary.attendanceCount)
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
