import Foundation
import Observation

@Observable final class EditSalaryHistoryViewModel {
    var job: Job
    var yearGroupedHistories: [Int: [SalaryHistory]] = [:]
    var expanded: Set<Int> = []
    var histories: [SalaryHistory] = []
    
    init(job: Job) {
        self.job = job
    }
    
    func onAppear() {
        yearGroupedHistories = Dictionary(grouping: job.salaryHistories, by: { $0.year })
        expanded.insert(Calendar.current.component(.year, from: Date()))
    }
    
    func onDisAppear() {
        SwiftDataSource.shared.save()
    }
    
    func deleteSalary(indexSet: IndexSet, year: Int) {
        if let yearHistories = yearGroupedHistories[year] {
            let sortedHistories = yearHistories.sorted { $0.month < $1.month }
            for index in indexSet {
                let salaryToDelete = sortedHistories[index]
                job.salaryHistories.removeAll { $0.year == salaryToDelete.year && $0.month == salaryToDelete.month }
            }
            yearGroupedHistories[year] = job.salaryHistories.filter { $0.year == year }
        }
    }
}
