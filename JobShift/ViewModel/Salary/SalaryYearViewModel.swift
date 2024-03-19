import Observation
import SwiftUI

@Observable final class SalaryYearViewModel: SalaryChartViewModel {
    required init(year: Int, month: Int?) {
        super.init(year: year, month: month)
    }
    
    override func update(_ includeCommuteWage: Bool) {
        withAnimation {
            chartData = []
            self.jobs = SwiftDataSource.shared.fetchJobs()
            jobs.forEach { job in
                let salaries = job.getYearSalary(year: year)
                let salary = salaries.map { $0.totalSalary + (includeCommuteWage ? $0.commuteWage : 0) }.reduce(0, +)
                let confirmSalary = salaries.map { ($0.isConfirm ? $0.confirmTotal : $0.totalSalary) + (includeCommuteWage ? $0.commuteWage : 0) }.reduce(0, +)
                let minutes = salaries.map { $0.totalMinutes }.reduce(0, +)
                let isConfirm = salaries.map { $0.isConfirm }.reduce(true, { $0 && $1 })
                let count = salaries.map { $0.count }.reduce(0, +)
                if salary > 0 {
                    chartData.append(
                        ChartEntry(
                            label: job.name,
                            salary: salary,
                            minutes: minutes,
                            color: job.color.getColor(),
                            isConfirm: isConfirm,
                            confirmSalary: confirmSalary,
                            count: count,
                            isOtJob: false,
                            job: job
                        )
                    )
                }
            }
            self.otJobs = SwiftDataSource.shared.fetchOTJobs().filter { oj in
                let ojDateComponents = Calendar.current.dateComponents([.year], from: oj.date)
                return ojDateComponents.year == year
            }
            if !otJobs.isEmpty {
                chartData.append(
                    ChartEntry(
                        label: "単発バイト",
                        salary: otJobs.map { $0.salary + (includeCommuteWage && $0.isCommuteWage ?  $0.commuteWage : 0) }.reduce(0, +),
                        minutes: 0,
                        color: .secondary,
                        isConfirm: true,
                        confirmSalary: otJobs.map { $0.salary + (includeCommuteWage && $0.isCommuteWage ?  $0.commuteWage : 0) }.reduce(0, +),
                        count: otJobs.count,
                        isOtJob: true,
                        job: nil
                    )
                )
            }
            allSalary = chartData.map { $0.salary }.reduce(0, +)
            let lastYear = year - 1
            lastAllSalary = jobs.map { $0.getYearSalary(year: lastYear).map { $0.totalSalary + (includeCommuteWage ? $0.commuteWage : 0) }.reduce(0, +) }.reduce(0, +)
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

