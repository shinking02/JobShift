import Observation
import SwiftUI

@Observable final class SalaryMonthViewModel: SalaryChartViewModel {
    let month: Int
    
    required init(year: Int, month: Int?) {
        self.month = month ?? 1
        super.init(year: year, month: month)
    }
    
    override func update(_ includeCommuteWage: Bool) {
        withAnimation {
            chartData = []
            self.jobs = SwiftDataSource.shared.fetchJobs()
            self.otJobs = SwiftDataSource.shared.fetchOTJobs().filter { oj in
                let ojDateComponents = Calendar.current.dateComponents([.year, .month], from: oj.date)
                return ojDateComponents.year == year && ojDateComponents.month == month
            }
            jobs.forEach { job in
                let salary = job.getMonthSalary(year: year, month: month)
                if salary.attendanceCount != 0 || salary.totalSalary > 0 || salary.confirmTotal > 0 {
                    chartData.append(
                        ChartEntry(
                            label: job.name,
                            salary: salary.totalSalary + (includeCommuteWage ? salary.commuteWage : 0),
                            minutes: salary.totalMinutes,
                            color: job.color.getColor(),
                            isConfirm: salary.isConfirm,
                            confirmSalary: salary.confirmTotal + (includeCommuteWage ? salary.commuteWage : 0),
                            count: salary.attendanceCount,
                            isOtJob: false,
                            job: job
                        )
                    )
                }
            }
            if !otJobs.isEmpty {
                chartData.append(
                    ChartEntry(
                        label: "単発バイト",
                        salary: otJobs.map { $0.salary + (includeCommuteWage && $0.isCommuteWage ? $0.commuteWage : 0) }.reduce(0, +),
                        minutes: 0,
                        color: .secondary,
                        isConfirm: true,
                        confirmSalary: otJobs.map { $0.salary + (includeCommuteWage && $0.isCommuteWage ? $0.commuteWage : 0) }.reduce(0, +),
                        count: otJobs.count,
                        isOtJob: true,
                        job: nil
                    )
                )
            }
            allSalary = chartData.map { $0.isConfirm ? $0.confirmSalary : $0.salary }.reduce(0, +)
            let lastMonth = month == 1 ? 12 : month - 1
            let lastYear = month == 1 ? year - 1 : year
            lastAllSalary = jobs.map { $0.getMonthSalary(year: lastYear, month: lastMonth).totalSalary + (includeCommuteWage ? $0.commuteWage : 0) }.reduce(0, +)
            chartData.sort { $0.salary > $1.salary }
            let diff = allSalary - lastAllSalary
            if diff > 0 {
                totalColor = .green
                totalImageName = "arrow.up"
            } else if diff < 0 {
                totalColor = .red
                totalImageName = "arrow.down"
            } else {
                totalColor = .secondary
                totalImageName = "arrow.forward"
            }
        }
    }
}
