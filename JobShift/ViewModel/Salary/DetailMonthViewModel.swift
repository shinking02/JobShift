import Observation

@Observable final class DetailMonthViewModel {
    var title: String = ""
    var forcastSalary: String = ""
    var confirmSalary: String = ""
    var avgMinutes: Int = 0
    var count: Int = 0
    var lastAvgMinutes: Int = 0
    var lastCount: Int = 0
    var details: [SalaryDetail] = []
    var yearMonth: YearMonth
    var job: Job
    private var includeCommuteWage: Bool
    
    init(job: Job, yearMonth: YearMonth, includeCommuteWage: Bool) {
        self.job = job
        self.yearMonth = yearMonth
        self.includeCommuteWage = includeCommuteWage
    }
    
    func onAppear() {
        update()
    }
    
    private func update() {
        let salary = job.getMonthSalary(year: yearMonth.year, month: yearMonth.month)
        let lastYearMonth = yearMonth.backward()
        let lastSalary = job.getMonthSalary(year: lastYearMonth.year, month: lastYearMonth.month)
        forcastSalary = String(salary.totalSalary + (includeCommuteWage ? salary.commuteWage : 0))
        confirmSalary = salary.isConfirm ? String(salary.confirmTotal + (includeCommuteWage ? salary.commuteWage : 0)) : "-"
        avgMinutes = salary.count != 0 ? Int(salary.totalMinutes / salary.count) : 0
        count = salary.count
        lastAvgMinutes = lastSalary.count != 0 ? Int(lastSalary.totalMinutes / lastSalary.count) : 0
        lastCount = lastSalary.count
        details = salary.details
        title = job.name
    }
}
