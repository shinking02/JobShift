import Observation
import Foundation

@Observable final class DetailSalaryOTJobViewModel {
    var confirmSalary: String = ""
    var year: Int
    var month: Int
    var otJobs: [OneTimeJob] = []
    private var includeCommuteWage: Bool
    
    init(year: Int, month: Int, includeCommuteWage: Bool) {
        self.year = year
        self.month = month
        self.includeCommuteWage = includeCommuteWage
    }
    
    func onAppear() {
        update()
    }
    
    private func update() {
        otJobs = SwiftDataSource.shared.fetchOTJobs().filter { oj in
            let ojDateComponents = Calendar.current.dateComponents([.year, .month], from: oj.date)
            if month != 0 {
                return ojDateComponents.year == year && ojDateComponents.month == month
            } else {
                return ojDateComponents.year == year
            }
        }
        confirmSalary = String(otJobs.map { $0.salary + (includeCommuteWage && $0.isCommuteWage ?  $0.commuteWage : 0) }.reduce(0, +))
    }
}
