import Observation

@Observable final class SalaryAddSheetViewModel {
    var jobSelection: Job = SwiftDataSource.shared.fetchJobs().first! {
        didSet {
            checkExistSalary()
        }
    }
    var jobs: [Job] {
        SwiftDataSource.shared.fetchJobs()
    }
    var existSalaryError = false
    var yearMonth: YearMonth = YearMonth.origin {
        didSet {
            checkExistSalary()
        }
    }
    var salaryString = ""
    var salaryError: Bool {
        guard let salary = Int(salaryString) else { return true }
        return salary <= 0
    }
    
    init(job: Job?) {
        if let job = job {
            jobSelection = job
        }
    }
    
    func onAppear() {
        checkExistSalary()
    }
    
    func addButtonTapped() {
        let commuteWage = jobSelection.getMonthSalary(year: yearMonth.year, month: yearMonth.month).commuteWage
        let newSalary = max(Int(salaryString)! - commuteWage, 0)
        let newHistory = SalaryHistory(salary: newSalary, year: yearMonth.year, month: yearMonth.month)
        jobSelection.salaryHistories.append(newHistory)
        SwiftDataSource.shared.save()
    }
    
    private func checkExistSalary() {
        let salary = jobSelection.salaryHistories.first { $0.year == yearMonth.year && $0.month == yearMonth.month }
        existSalaryError = salary != nil
    }
}
