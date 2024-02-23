import Foundation

class OTJobEditViewModel: ObservableObject {
    @Published var name: String
    @Published var salary: String
    @Published var isCommuteWage: Bool
    @Published var commuteWage: String
    
    private var otJob: OneTimeJob
    private var dataSource = SwiftDataSource.shared
    
    init(otJob: OneTimeJob) {
        self.name = otJob.name
        self.salary = String(otJob.salary)
        self.isCommuteWage = otJob.isCommuteWage
        self.commuteWage = otJob.commuteWage == 0 ? "" : String(otJob.commuteWage)
        self.otJob = otJob
    }
    
    func delete() {
        dataSource.removeOTJob(otJob)
    }
    
    func validateAndUpdate() {
        if name.isEmpty {
            return
        }
        if Int(salary) == nil {
            return
        }
        if isCommuteWage && Int(commuteWage) == nil {
            return
        }
        otJob.name = name
        otJob.salary = Int(salary)!
        otJob.isCommuteWage = isCommuteWage
        otJob.commuteWage = Int(commuteWage) ?? 0
    }
}
