import Observation

@Observable final class OTJobAddViewModel: OTJobFormViewModel {
    required init(otJob: OneTimeJob? = nil) {
        super.init(otJob: nil)
    }
    var validationError: Bool {
        if name.isEmpty {
            return true
        }
        if isCommuteWage {
            return Int(commuteWageString) == nil
        }
        if Int(salaryString) == nil {
            return true
        }
        return false
    }
    func addButtonTapped() {
        let swiftDataSource = SwiftDataSource.shared
        let otJob = OneTimeJob(
            name: name,
            date: date,
            salary: Int(salaryString) ?? 0,
            isCommuteWage: isCommuteWage,
            commuteWage: Int(commuteWageString) ?? 0,
            summary: summary
        )
        swiftDataSource.appendOTJob(otJob)
    }
}
